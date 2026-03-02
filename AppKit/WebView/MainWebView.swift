//
//  MainWebView.swift
//  AeroBrowser
//
//  Created by Falsy on 5/24/25.
//

import SwiftUI
@preconcurrency import WebKit
import ContentBlockRuleList

struct MainWebView: NSViewRepresentable {
  @ObservedObject var service: Service
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  @State private var isSinglePageUpdate: Bool = false
  
  @ViewBuilder
  private func errorPageView(for errorType: ErrorPageType, failingURL: String) -> some View {
    ErrorPageView(
      errorType: errorType,
      failingURL: failingURL
    ) {
      // 새로고침 액션
      guard let _ = tab.webview else { return }
      if let url = URL(string: failingURL) {
        DispatchQueue.main.async {
          self.tab.updateURLBySearch(url: url)
        }
      }
    }
  }
  
  func makeCoordinator() -> MainWebViewCoordinator {
    MainWebViewCoordinator(self)
  }
  
  func makeNSView(context: Context) -> WKWebView {
    guard let webView = tab.webview else {
      return WKWebView()
    }
    
    // 각 Coordinator를 WebView delegate로 설정
    webView.navigationDelegate = context.coordinator.navigationCoordinator
    webView.uiDelegate = context.coordinator.javascriptCoordinator
    webView.allowsBackForwardNavigationGestures = true
    webView.isInspectable = true
    webView.setValue(false, forKey: "drawsBackground")
    
    // User Agent 설정
    context.coordinator.navigationCoordinator.setUserAgent(for: webView)
    
    // Tracker Blocking 설정
    if tab.isTrackerBlocking == nil {
      tab.isTrackerBlocking = service.isTrackerBlocking
      ContentBlockRuleList(webView: webView).updateRules(isBlocking: service.isTrackerBlocking)
    }
    
    return webView
  }
  
  func updateNSView(_ webView: WKWebView, context: Context) {
    // 에러 페이지가 표시 중이면 WebView 업데이트 중지
    if tab.showErrorPage {
      return
    }
    
    // Tracker Blocking 업데이트
    if let isTrackerBlocking = tab.isTrackerBlocking, isTrackerBlocking != service.isTrackerBlocking {
      tab.isTrackerBlocking = service.isTrackerBlocking
      ContentBlockRuleList(webView: webView).updateRules(isBlocking: service.isTrackerBlocking)
    }
    
    // 각 기능별 업데이트를 해당 Coordinator에 위임
    context.coordinator.geoLocationCoordinator.handleLocationUpdates()
    
    // isSinglePageUpdate를 Coordinator에 전달하여 처리
    let shouldUpdateSinglePage = context.coordinator.navigationCoordinator.handleNavigationUpdates(
      webView: webView,
      currentIsSinglePageUpdate: isSinglePageUpdate
    )
    
    // 필요한 경우 isSinglePageUpdate 상태 업데이트
    if shouldUpdateSinglePage != isSinglePageUpdate {
      DispatchQueue.main.async {
        self.isSinglePageUpdate = shouldUpdateSinglePage
      }
    }
    
    context.coordinator.javascriptCoordinator.handleUIUpdates(webView: webView)
  }
}
