//
//  GeoLocationCoordinator.swift
//  AeroBrowser
//
//  Created by Falsy on 5/24/25.
//

import SwiftUI
import CoreLocation
import WebKit

class GeoLocationCoordinator: NSObject, @preconcurrency CLLocationManagerDelegate {
  var parent: MainWebView!
  var locationManager: CLLocationManager?
  
  init(parent: MainWebView) {
    self.parent = parent
    super.init()
  }
  
  func cleanup() {
    locationManager?.stopUpdatingLocation()
    locationManager = nil
  }
  
  func handleLocationUpdates() {
    // System-level permission request
    if parent.tab.isRequestGeoLocation {
      DispatchQueue.main.async {
        self.parent.tab.isRequestGeoLocation = false
        self.parent.tab.isLocationDialogIcon = true
        self.parent.tab.isLocationDialog = true
        self.requestGeoLocationPermission()
      }
    }
    
    // After host dialog closes → re-fetch location
    if parent.tab.isUpdateLocation {
      DispatchQueue.main.async {
        self.parent.tab.isUpdateLocation = false
        self.deliverLocationOrDeny()
      }
    }
  }
  
  @MainActor func initGeoPositions() {
    guard let webview = parent.tab.webview else { return }
    locationManager = CLLocationManager()
    locationManager!.desiredAccuracy = kCLLocationAccuracyBest
    locationManager!.distanceFilter = kCLDistanceFilterNone
    locationManager!.delegate = self

    switch locationManager!.authorizationStatus {
    case .authorizedWhenInUse, .authorizedAlways:
      if let url = webview.url,
         let locationPermission = PermissionManager.getLocationPermissionByURL(url: url),
         !locationPermission.isDenied {
        // System + host both allowed → inject position fetcher
        injectGeoPositionBridge(webview: webview, allowed: true)
        locationManager!.startUpdatingLocation()
      } else if let url = webview.url, PermissionManager.getLocationPermissionByURL(url: url) == nil {
        // System allowed but no host permission yet → show host dialog when page asks
        injectGeoPositionBridge(webview: webview, allowed: false, showHostDialog: true)
      } else {
        // System allowed but host denied
        injectGeoPositionBridge(webview: webview, allowed: false, showHostDialog: true)
      }
    case .denied, .restricted, .notDetermined:
      injectGeoPositionBridge(webview: webview, allowed: false, showHostDialog: false)
    @unknown default:
      break
    }
  }
  
  // MARK: - JS Bridge Injection
  
  /// Injects a JS bridge that intercepts getCurrentPosition.
  /// - `allowed`: if true, position will be delivered via native → JS callback
  /// - `showHostDialog`: if true, prompts the host permission dialog instead of just erroring
  private func injectGeoPositionBridge(webview: WKWebView, allowed: Bool, showHostDialog: Bool = false) {
    if allowed {
      // When allowed, we store the pending callback and wait for native to deliver coords
      let script = """
        (function() {
          window.__aeroPendingGeoCallbacks = [];
          var origGetCurrentPosition = navigator.geolocation.getCurrentPosition;
          navigator.geolocation.getCurrentPosition = function(success, error, options) {
            window.__aeroPendingGeoCallbacks.push({ success: success, error: error });
            window.webkit.messageHandlers.aeroBrowser.postMessage({ name: "showGeoLocaitonHostPermissionIcon", value: "false" });
          };
          navigator.geolocation.watchPosition = function(success, error, options) {
            window.__aeroPendingGeoCallbacks.push({ success: success, error: error });
            return 0;
          };
        })();
      """
      webview.evaluateJavaScript(script, completionHandler: nil)
    } else if showHostDialog {
      // System permission granted but no host permission → show host dialog
      let script = """
        (function() {
          window.__aeroPendingGeoCallbacks = [];
          navigator.geolocation.getCurrentPosition = function(success, error, options) {
            window.__aeroPendingGeoCallbacks.push({ success: success, error: error });
            window.webkit.messageHandlers.aeroBrowser.postMessage({ name: "showGeoLocaitonHostPermissionIcon", value: "true" });
          };
          navigator.geolocation.watchPosition = function(success, error, options) {
            window.__aeroPendingGeoCallbacks.push({ success: success, error: error });
            window.webkit.messageHandlers.aeroBrowser.postMessage({ name: "showGeoLocaitonHostPermissionIcon", value: "true" });
            return 0;
          };
        })();
      """
      webview.evaluateJavaScript(script, completionHandler: nil)
    } else {
      // No system permission → request it when page asks
      let script = """
        (function() {
          window.__aeroPendingGeoCallbacks = [];
          navigator.geolocation.getCurrentPosition = function(success, error, options) {
            window.__aeroPendingGeoCallbacks.push({ success: success, error: error });
            window.webkit.messageHandlers.aeroBrowser.postMessage({ name: "requestWhenInUseAuthorization" });
          };
          navigator.geolocation.watchPosition = function(success, error, options) {
            window.__aeroPendingGeoCallbacks.push({ success: success, error: error });
            window.webkit.messageHandlers.aeroBrowser.postMessage({ name: "requestWhenInUseAuthorization" });
            return 0;
          };
        })();
      """
      webview.evaluateJavaScript(script, completionHandler: nil)
    }
  }
  
  /// Deliver real coordinates to all pending JS callbacks
  private func deliverPosition(webview: WKWebView, latitude: Double, longitude: Double) {
    let script = """
      (function() {
        var cbs = window.__aeroPendingGeoCallbacks || [];
        window.__aeroPendingGeoCallbacks = [];
        var pos = {
          coords: {
            latitude: \(latitude),
            longitude: \(longitude),
            accuracy: 10,
            altitude: null,
            altitudeAccuracy: null,
            heading: null,
            speed: null
          },
          timestamp: Date.now()
        };
        for (var i = 0; i < cbs.length; i++) {
          try { cbs[i].success(pos); } catch(e) {}
        }
        navigator.geolocation.getCurrentPosition = function(success, error, options) {
          try { success(pos); } catch(e) {}
        };
      })();
    """
    webview.evaluateJavaScript(script, completionHandler: nil)
  }
  
  /// Deliver error to all pending JS callbacks
  private func deliverError(webview: WKWebView) {
    let script = """
      (function() {
        var cbs = window.__aeroPendingGeoCallbacks || [];
        window.__aeroPendingGeoCallbacks = [];
        var err = { code: 1, message: 'User denied geolocation' };
        for (var i = 0; i < cbs.length; i++) {
          try { if (cbs[i].error) cbs[i].error(err); } catch(e) {}
        }
      })();
    """
    webview.evaluateJavaScript(script, completionHandler: nil)
  }
  
  // MARK: - After host dialog closes
  
  /// Called when the host permission dialog closes (Allow or Deny).
  /// Re-checks the permission and either delivers location or error.
  @MainActor private func deliverLocationOrDeny() {
    guard let locationManager = locationManager, let webview = parent.tab.webview, let url = webview.url else { return }
    
    switch locationManager.authorizationStatus {
    case .authorizedWhenInUse, .authorizedAlways:
      if let permission = PermissionManager.getLocationPermissionByURL(url: url), !permission.isDenied {
        // Host allowed → start fetching location
        injectGeoPositionBridge(webview: webview, allowed: true)
        locationManager.startUpdatingLocation()
      } else {
        // Host denied → deliver error to pending callbacks
        deliverError(webview: webview)
        injectGeoPositionBridge(webview: webview, allowed: false, showHostDialog: true)
      }
    default:
      deliverError(webview: webview)
    }
  }
  
  func requestGeoLocationPermission() {
    guard let locationManager = locationManager else { return }
    locationManager.requestWhenInUseAuthorization()
  }
  
  // MARK: - CLLocationManagerDelegate
  
  @MainActor func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    print("didChangeAuthorization: \(status.rawValue)")
    guard let webview = parent.tab.webview, let url = webview.url else { return }
    
    switch status {
    case .authorizedWhenInUse, .authorizedAlways:
      DispatchQueue.main.async {
        self.parent.tab.isLocationDialogIcon = false
        self.parent.tab.isLocationDialogIconByHost = false
      }
      // System permission granted. Check host permission.
      if let permission = PermissionManager.getLocationPermissionByURL(url: url) {
        if !permission.isDenied {
          injectGeoPositionBridge(webview: webview, allowed: true)
          locationManager?.startUpdatingLocation()
        } else {
          injectGeoPositionBridge(webview: webview, allowed: false, showHostDialog: true)
        }
      } else {
        // No host permission record yet → show host dialog when page asks
        injectGeoPositionBridge(webview: webview, allowed: false, showHostDialog: true)
      }
      
    case .denied, .restricted:
      DispatchQueue.main.async {
        self.parent.tab.isLocationDialogIcon = false
      }
      deliverError(webview: webview)
      
    default:
      break
    }
  }
  
  @MainActor func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first, let webview = parent.tab.webview, let url = webview.url else { return }
    
    if let permission = PermissionManager.getLocationPermissionByURL(url: url), !permission.isDenied {
      deliverPosition(webview: webview, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
      locationManager?.stopUpdatingLocation()
    } else {
      deliverError(webview: webview)
      locationManager?.stopUpdatingLocation()
    }
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("didFailWithError: \(error)")
    guard let webview = self.parent.tab.webview else { return }
    let script = """
      (function() {
        var cbs = window.__aeroPendingGeoCallbacks || [];
        window.__aeroPendingGeoCallbacks = [];
        var err = { code: 2, message: 'Location retrieval failed: \(error.localizedDescription)' };
        for (var i = 0; i < cbs.length; i++) {
          try { if (cbs[i].error) cbs[i].error(err); } catch(e) {}
        }
      })();
    """
    webview.evaluateJavaScript(script, completionHandler: nil)
  }
}
