//
//  AeroBrowserScriptHandler.swift
//  AeroBrowser
//
//  Created by Falsy on 4/5/24.
//

import SwiftUI
import SwiftData

final class AeroBrowserScriptHandler {
  @ObservedObject var tab: Tab
  
  init(tab: Tab) {
    self.tab = tab
  }
  
  private func dateFromString(_ dateString: String) -> Date? {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM"
      dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
      return dateFormatter.date(from: dateString)
  }
  
  private func decodeJSON<T: Decodable>(from jsonString: String, to type: T.Type) throws -> T {
    guard let jsonData = jsonString.data(using: .utf8) else {
      throw NSError(domain: "Invalid JSON", code: 0, userInfo: nil)
    }
    
    let decoder = JSONDecoder()
    let decodedData = try decoder.decode(T.self, from: jsonData)
    return decodedData
  }
  
  private func encodeJSON<T: Encodable>(from instance: T) throws -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    
    let encodedData = try encoder.encode(instance)
    guard let jsonString = String(data: encodedData, encoding: .utf8) else {
      throw NSError(domain: "Invalid JSON", code: 1, userInfo: nil)
    }
    
    return jsonString
  }
  
  
  func messages(name: String, value: String?) {
    var script: String?
    
    if let value = value {
      switch name {
        case "goPage":
          script = goPage(value)
          break
        case "getPageStrings":
          script = getPageStrings(value)
          break
        case "cratedFavorite":
          script = cratedFavorite(value)
          break
        case "deleteFavorite":
          script = deleteFavorite(value)
          break
        case "updateFavorite":
          script = updateFavorite(value)
          break
        case "updateSearchEngine":
          script = updateSearchEngine(value)
          break
        case "updateScreenMode":
          script = updateScreenMode(value)
          break
        case "updateRetentionPeriod":
          script = updateRetentionPeriod(value)
          break
        case "updateTrackerBlocking":
          script = updateTrackerBlocking(value)
          break
        case "setBlockingTracker": // Deprecated
          script = setBlockingTracker(value)
          break
        case "setAdBlocking": // Deprecated
          script = setAdBlocking(value)
          break
        case "getSearchHistoryList":
          script = getSearchHistoryList(value)
          break
        case "getVisitHistoryList":
          script = getVisitHistoryList(value)
          break
        case "deleteSearchHistory":
          script = deleteSearchHistory(value)
          break
        case "deleteVisitHistory":
          script = deleteVisitHistory(value)
          break
        case "deletePermissions":
          script = deletePermissions(value)
          break
        case "updateLanguage":
          script = updateLanguage(value)
          break
        default: break
      }
    } else {
      switch name {
        case "getLanguage":
          script = getLanguage()
          break
        case "getScreenMode":
          script = getScreenMode()
          break
        case "getScreenModeList":
          script = getScreenModeList()
          break
        case "getSearchEngine":
          script = getSearchEngine()
          break
        case "getSearchEngineList":
          script = getSearchEngineList()
          break
        case "getRetentionPeriod":
          script = getRetentionPeriod()
          break
        case "getRetentionPeriodList":
          script = getRetentionPeriodList()
          break
        case "getTrackerBlocking":
          script = getTrackerBlocking()
          break
        case "getLocationPermissions":
          script = getLocationPermissions()
          break
        case "getNotificationPermissions":
          script = getNotificationPermissions()
          break
        case "getFavoriteList":
          script = getFavoriteList()
          break
        case "deleteAllSearchHistory":
          script = deleteAllSearchHistory()
          break
        case "deleteAllVisitHistory":
          script = deleteAllVisitHistory()
          break
        default: break
      }
    }
    
    if let webview = tab.webview, let script = script {
      webview.evaluateJavaScript(script, completionHandler: nil)
    }
  }

  func deleteAllSearchHistory() -> String {
    SearchManager.deleteAllSearchHistory()
    return """
      window.aeroBrowserResponse.deleteAllSearchHistory({
        data: "success"
      })
    """
  }
  
  func deleteAllVisitHistory() -> String {
    VisitManager.deleteAllVisitHistory()
    return """
      window.aeroBrowserResponse.deleteAllVisitHistory({
        data: "success"
      })
    """
  }
  
  func deletePermissions(_ permissionId: String) -> String? {
    if let uuid = UUID(uuidString: permissionId) {
      PermissionManager.deletePermissionById(uuid)
    }
    return """
      window.aeroBrowserResponse.deletePermissions({
        data: "success"
      })
    """
  }
  
  func deleteVisitHistory(_ historyId: String) -> String? {
    if let uuid = UUID(uuidString: historyId) {
      VisitManager.deleteVisitHistoryById(uuid)
    }
    
    return """
      window.aeroBrowserResponse.deleteVisitHistory({
        data: "success"
      })
    """
  }
  
  func deleteSearchHistory(_ historyId: String) -> String? {
    if let uuid = UUID(uuidString: historyId) {
      SearchManager.deleteSearchHistoryById(uuid)
    }
    
    return """
      window.aeroBrowserResponse.deleteSearchHistory({
        data: "success"
      })
    """
  }
  
  func getVisitHistoryList(_ yearMonth: String) -> String? {
    if let targetDate = dateFromString(yearMonth) {
      let descriptor = FetchDescriptor<VisitHistory>()
      do {
        let calendar = Calendar.current
        let visitHistoryList = try AppDelegate.shared.modelContainer.mainContext.fetch(descriptor)

        var firstDateString = ""
        if let firstData = visitHistoryList.first {
          let firstDateYearMonth = calendar.dateComponents([.year, .month], from: firstData.createDate)
          if let fYear = firstDateYearMonth.year, let fMonth = firstDateYearMonth.month {
            let padStartMonth = String(describing: fMonth).count == 2 ? String(describing: fMonth) : "0\(String(describing: fMonth))"
            firstDateString = "\(String(describing: fYear))-\(padStartMonth)"
          }
        }
        let filterHistoryList = visitHistoryList.filter {
          let components = calendar.dateComponents([.year, .month], from: $0.createDate)
          let targetComponents = calendar.dateComponents([.year, .month], from: targetDate)
          return components.year == targetComponents.year && components.month == targetComponents.month
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var visitHistories: [VisitHistorySettings] = []
        for sh in filterHistoryList {
          visitHistories.append(VisitHistorySettings(id: sh.id, title: sh.visitHistoryGroup?.title, url: sh.visitHistoryGroup!.url, createDate: dateFormatter.string(from: sh.createDate)))
        }
        let jsonString = try encodeJSON(from: visitHistories)
        return """
          window.aeroBrowserResponse.getVisitHistoryList({
            data: {
              firstDate: "\(firstDateString)",
              list: \(jsonString)
            }
          })
        """
      } catch {
        print("JSONEncodeError getVisitHistoryList")
      }
    }
      
    return """
      window.aeroBrowserResponse.getVisitHistoryList({
        data: "error"
      })
    """
  }
  
  func getSearchHistoryList(_ yearMonth: String) -> String? {
    if let targetDate = dateFromString(yearMonth) {
      let descriptor = FetchDescriptor<SearchHistory>()
      
      do {
        let calendar = Calendar.current
        let searchHistoryList = try AppDelegate.shared.modelContainer.mainContext.fetch(descriptor)
        
        var firstDateString = ""
        if let firstData = searchHistoryList.first {
          let firstDateYearMonth = calendar.dateComponents([.year, .month], from: firstData.createDate)
          if let fYear = firstDateYearMonth.year, let fMonth = firstDateYearMonth.month {
            let padStartMonth = String(describing: fMonth).count == 2 ? String(describing: fMonth) : "0\(String(describing: fMonth))"
            firstDateString = "\(String(describing: fYear))-\(padStartMonth)"
          }
        }
        let filterHistoryList = searchHistoryList.filter {
          let components = calendar.dateComponents([.year, .month], from: $0.createDate)
          let targetComponents = calendar.dateComponents([.year, .month], from: targetDate)
          return components.year == targetComponents.year && components.month == targetComponents.month
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var searchHistories: [SearchHistorySettings] = []
        for sh in filterHistoryList {
          searchHistories.append(SearchHistorySettings(id: sh.id, title: sh.searchHistoryGroup!.searchText, createDate: dateFormatter.string(from: sh.createDate)))
        }
        
        let jsonString = try encodeJSON(from: searchHistories)
        return """
          window.aeroBrowserResponse.getSearchHistoryList({
            data: {
              firstDate: "\(firstDateString)",
              list: \(jsonString)
            }
          })
        """
      } catch {
        print("JSONEncodeError getSearchHistoryList")
      }
    }
      
    return """
      window.aeroBrowserResponse.getSearchHistoryList({
        data: "error"
      })
    """
  }
  
  func updateTrackerBlocking(_ value: String) -> String? {
    guard let boolValue = Bool(value) else {
      return """
        window.aeroBrowserResponse.updateTrackerBlocking({
          data: "error"
        })
      """
    }
    SettingsManager.setIsTrackerBlocking(boolValue)
    AppDelegate.shared.service.isTrackerBlocking = boolValue
    return """
    window.aeroBrowserResponse.updateTrackerBlocking({
      data: "success"
    })
  """
  }
  
  // Deprecated
  func setBlockingTracker(_ value: String) -> String? {
    SettingsManager.setBlockingTracker(value)
    AppDelegate.shared.service.blockingLevel = value
    return """
    window.aeroBrowserResponse.setBlockingTracker({
      data: "success"
    })
  """
  }
  
  // Deprecated
  func setAdBlocking(_ value: String) -> String? {
    guard let boolValue = Bool(value) else {
      return """
        window.aeroBrowserResponse.setAdBlocking({
          data: "error"
        })
      """
    }
    
    SettingsManager.setAdBlocking(boolValue)
    AppDelegate.shared.service.isAdBlocking = boolValue
    return """
      window.aeroBrowserResponse.setAdBlocking({
        data: "success"
      })
    """
  }
  
  func updateRetentionPeriod(_ value: String) -> String? {
    SettingsManager.setRetentionPeriod(value)
    return """
      window.aeroBrowserResponse.updateRetentionPeriod({
        data: "success"
      })
    """
  }
  
  func updateScreenMode(_ value: String) -> String? {
    SettingsManager.setScreenMode(value)
    return """
      window.aeroBrowserResponse.updateScreenMode({
        data: "success"
      })
    """
  }
  
  func updateSearchEngine(_ value: String) -> String? {
    SettingsManager.setSearchEngine(value)
    return """
      window.aeroBrowserResponse.updateSearchEngine({
        data: "success"
      })
    """
  }
  
  func deleteFavorite(_ favoriteId: String) -> String? {
    let isSuccess = FavoriteManager.deleteFavoriteById(favoriteId)
    
    if isSuccess {
      return """
      window.aeroBrowserResponse.deleteFavorite({
        data: "success"
      })
    """
    }
    
    return """
      window.aeroBrowserResponse.deleteFavorite({
        data: "error"
      })
    """
  }
  
  func cratedFavorite(_ favoriteData: String) -> String? {
    do {
      let favoriteItem = try decodeJSON(from: favoriteData, to: FavoriteItemParams.self)
      let favorite = Favorite(title: favoriteItem.title, address: favoriteItem.address)
      let isSuccess = FavoriteManager.addFavorite(favorite)
      
      if isSuccess {
        return """
        window.aeroBrowserResponse.cratedFavorite({
          data: "success"
        })
      """
      }
    } catch {
      print("JSONDecodeError cratedFavorite")
    }
    
    return """
      window.aeroBrowserResponse.cratedFavorite({
        data: "error"
      })
    """
  }
  
  func updateFavorite(_ favoriteData: String) -> String? {
    do {
      let favoriteItem = try decodeJSON(from: favoriteData, to: FavoriteItem.self)
      print(favoriteData)
      let isSuccess = FavoriteManager.editFavoriteById(favoriteItem.id, newTitle: favoriteItem.title, newAddress: favoriteItem.address)
      print(isSuccess)
      if isSuccess {
        return """
        window.aeroBrowserResponse.updateFavorite({
          data: "success"
        })
      """
      }
    } catch {
      print("JSONDecodeError updateFavorite")
    }
    
    return """
      window.aeroBrowserResponse.updateFavorite({
        data: "error"
      })
    """
  }
  
  func updateLanguage(_ language: String) -> String? {
    UserDefaults.standard.set([language], forKey: "AppleLanguages")
    UserDefaults.standard.synchronize()

    return """
      window.aeroBrowserResponse.updateLanguage({
        data: "success"
      })
    """
  }
  
  func getFavoriteList() -> String? {
    do {
      if let favoriteList = FavoriteManager.getFavoriteList() {
        var jsonDataList: [FavoriteItem] = []
        for favorite in favoriteList {
          jsonDataList.append(FavoriteItem(id: favorite.id, title: favorite.title, address: favorite.address))
        }
        
        let jsonString = try encodeJSON(from: jsonDataList)
        return """
          window.aeroBrowserResponse.getFavoriteList({
            data: \(jsonString)
          })
        """
      }
    } catch {
      print("JSONEncodeError getFavoriteList")
    }
    
    return """
      window.aeroBrowserResponse.getFavoriteList({
        data: "error"
      })
    """
  }
  
  func getLocationPermissions() -> String? {
    if let locaitonPermitions = PermissionManager.getLocationPermissions() {
      var jsonDataList: [PermissionItem] = []
      for noti in locaitonPermitions {
        jsonDataList.append(PermissionItem(id: noti.id, domain: noti.domain, permission: noti.permission, isDenied: noti.isDenied))
      }
      do {
        let jsonString = try encodeJSON(from: jsonDataList)
        return """
          window.aeroBrowserResponse.getLocationPermissions({
            data: \(jsonString)
          })
        """
      } catch {
        print("JSONEncodeError getLocationPermissions")
      }
    }

    return """
      window.aeroBrowserResponse.getLocationPermissions({
        data: "error"
      })
    """
  }
  
  func getNotificationPermissions() -> String? {
    if let notificationPermitions = PermissionManager.getNotificationPermissions() {
      var jsonDataList: [PermissionItem] = []
      for noti in notificationPermitions {
        jsonDataList.append(PermissionItem(id: noti.id, domain: noti.domain, permission: noti.permission, isDenied: noti.isDenied))
      }
      do {
        let jsonString = try encodeJSON(from: jsonDataList)
        return """
          window.aeroBrowserResponse.getNotificationPermissions({
            data: \(jsonString)
          })
        """
      } catch {
        print("JSONEncodeError getNotificationPermissions")
      }
    }

    return """
      window.aeroBrowserResponse.getNotificationPermissions({
        data: "error"
      })
    """
  }
  
  func getScreenMode() -> String? {
    if let browserSettings = SettingsManager.getGeneralSettings() {
      return """
        window.aeroBrowserResponse.getScreenMode({
          data: {
            id: "\(browserSettings.screenMode)",
            name: "\(NSLocalizedString(browserSettings.screenMode, comment: ""))"
          }
        })
      """
    }
    
    return """
      window.aeroBrowserResponse.getScreenMode({
        data: "error"
      })
    """
  }
  
  func getScreenModeList() -> String? {
    var screenModeList: [SettingListItem] = []
    for screenModeItem in SCREEN_MODE_LIST {
      screenModeList.append(SettingListItem(id: screenModeItem, name: NSLocalizedString(screenModeItem, comment: "")))
    }
    do {
      let screenModeString = try encodeJSON(from: screenModeList)
      return """
        window.aeroBrowserResponse.getScreenModeList({
          data: \(screenModeString)
        })
     """
    } catch {
      print("JSONEncodeError getScreenModeList")
    }
    
    return """
      window.aeroBrowserResponse.getScreenModeList({
        data: "error"
      })
    """
  }
  
  func getSearchEngine() -> String? {
    if let browserSettings = SettingsManager.getGeneralSettings() {
      return """
        window.aeroBrowserResponse.getSearchEngine({
          data: {
            id: "\(browserSettings.searchEngine)",
            name: "\(NSLocalizedString(browserSettings.searchEngine, comment: ""))"
          }
        })
      """
    }
    
    return """
      window.aeroBrowserResponse.getSearchEngine({
        data: "error"
      })
    """
  }
  
  func getSearchEngineList() -> String? {
    var searchEngineList: [SettingListItem] = []
    for engine in SEARCH_ENGINE_LIST {
      searchEngineList.append(SettingListItem(id: engine.name, name: engine.name))
    }
    do {
      let searchString = try encodeJSON(from: searchEngineList)
      return """
        window.aeroBrowserResponse.getSearchEngineList({
          data: \(searchString)
        })
     """
    } catch {
      print("JSONEncodeError getSearchEngineList")
    }
    
    return """
      window.aeroBrowserResponse.getSearchEngineList({
        data: "error"
      })
    """
  }
  
  func getRetentionPeriod() -> String {
    if let browserSettings = SettingsManager.getGeneralSettings() {
      return """
        window.aeroBrowserResponse.getRetentionPeriod({
          data: {
            id: "\(browserSettings.retentionPeriod)",
            name: "\(NSLocalizedString(browserSettings.retentionPeriod, comment: ""))"
          }
        })
      """
    }
    
    return """
      window.aeroBrowserResponse.getRetentionPeriod({
        data: "error"
      })
    """
  }
  
  func getRetentionPeriodList() -> String {
    var periodList: [SettingListItem] = []
    for periodItem in RETENTION_PERIOD_LIST {
      periodList.append(SettingListItem(id: periodItem, name: NSLocalizedString(periodItem, comment: "")))
    }
    
    do {
      let periodString = try encodeJSON(from: periodList)
      return """
        window.aeroBrowserResponse.getRetentionPeriodList({
          data: \(periodString)
        })
     """
    } catch {
      print("JSONEncodeError getRetentionPeriodList")
    }
    
    return """
      window.aeroBrowserResponse.getRetentionPeriodList({
        data: "error"
      })
    """
  }
  
  func getTrackerBlocking() -> String? {
    if let browserSettings = SettingsManager.getGeneralSettings() {
      return """
        window.aeroBrowserResponse.getTrackerBlocking({
          data: \(browserSettings.isTrackerBlocking)
        })
      """
    }
    
    return """
      window.aeroBrowserResponse.getTrackerBlocking({
        data: "error"
      })
    """
  }
  
  func goPage(_ address: String) -> String? {
    let newAddress = tab.changeKeywordToURL(address)
    tab.updateURLBySearch(url: URL(string: newAddress)!)
    
    return """
      window.aeroBrowserResponse.goPage({
        data: "success"
      })
    """
  }
  
  func getLanguage() -> String? {
    let lang = Locale.current.language.languageCode?.identifier ?? "en"
    
    return """
      window.aeroBrowserResponse.getLanguage({
        data: "\(lang)"
      })
    """
  }

  func getPageStrings(_ pageName: String) -> String? {
    let lang = Locale.current.language.languageCode?.identifier ?? "en"
    switch pageName {
      case "new-tab":
        return """
        window.aeroBrowserResponse.getPageStrings({
          data: {
            "Add Favorite": '\(NSLocalizedString("Add Favorite", comment: ""))',
            "Edit Favorite": '\(NSLocalizedString("Edit Favorite", comment: ""))',
            "Title": '\(NSLocalizedString("Title", comment: ""))',
            "Address": '\(NSLocalizedString("Address", comment: ""))',
            "Edit": '\(NSLocalizedString("Edit", comment: ""))',
            "Delete": '\(NSLocalizedString("Delete", comment: ""))',
            "Save": '\(NSLocalizedString("Save", comment: ""))',
            "Cancel": '\(NSLocalizedString("Cancel", comment: ""))'
          }
        })
      """
      case "settings":
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
          return """
          window.aeroBrowserResponse.getPageStrings({
            data: {
              "lang": '\(lang)',
              "Settings": '\(NSLocalizedString("Settings", comment: ""))',
              "General": '\(NSLocalizedString("General", comment: ""))',
              "Search History": '\(NSLocalizedString("Search History", comment: ""))',
              "Visit History": '\(NSLocalizedString("Visit History", comment: ""))',
              "Permissions": '\(NSLocalizedString("Permissions", comment: ""))',
              "Language": '\(NSLocalizedString("Language", comment: ""))',
              "Search Engine": '\(NSLocalizedString("Search Engine", comment: ""))',
              "Screen Mode": '\(NSLocalizedString("Screen Mode", comment: ""))',
              "Retention Period": '\(NSLocalizedString("Retention Period", comment: ""))',
              "Show More": '\(NSLocalizedString("Show More", comment: ""))',
              "Delete": '\(NSLocalizedString("Delete", comment: ""))',
              "Cancel": '\(NSLocalizedString("Cancel", comment: ""))',
              "Notification": '\(NSLocalizedString("Notification", comment: ""))',
              "Location": '\(NSLocalizedString("Location", comment: ""))',
              "allowed": '\(NSLocalizedString("allowed", comment: ""))',
              "denied": '\(NSLocalizedString("denied", comment: ""))',
              "There is no domain with permissions set.": '\(NSLocalizedString("There is no domain with permissions set.", comment: ""))',
              "There is no search history.": '\(NSLocalizedString("There is no search history.", comment: ""))',
              "There is no visit history.": '\(NSLocalizedString("There is no visit history.", comment: ""))',
              "Tracker Blocking": '\(NSLocalizedString("Tracker Blocking", comment: ""))',
              "Learn More": '\(NSLocalizedString("Learn More", comment: ""))',
              "Clear All": '\(NSLocalizedString("Clear All", comment: ""))',
              "Library": '\(NSLocalizedString("Library", comment: ""))',
              "version": "\(version)",
              "Korean": '\(NSLocalizedString("Korean", comment: ""))',
              "English": '\(NSLocalizedString("English", comment: ""))',
              "German": '\(NSLocalizedString("German", comment: ""))',
              "Spanish": '\(NSLocalizedString("Spanish", comment: ""))',
              "Japanese": '\(NSLocalizedString("Japanese", comment: ""))',
              "Chinese": '\(NSLocalizedString("Chinese", comment: ""))',
              "French": '\(NSLocalizedString("French", comment: ""))',
              "Hindi": '\(NSLocalizedString("Hindi", comment: ""))',
              "Norwegian": '\(NSLocalizedString("Norwegian", comment: ""))',
              "Blocks unnecessary ads and trackers using DuckDuckGo’s tracking protection list along with additional rules.": '\(NSLocalizedString("Blocks unnecessary ads and trackers using DuckDuckGo’s tracking protection list along with additional rules.", comment: ""))',
              "The changes will take effect after restarting the app.": '\(NSLocalizedString("The changes will take effect after restarting the app.", comment: ""))',
            }
          })
        """
        }
      case "notFindHost":
        return """
        window.aeroBrowserResponse.getPageStrings({
          data: {
            "lang": '\(lang)',
            "headTitle": '\(NSLocalizedString("Page not found", comment: ""))',
            "title": '\(NSLocalizedString("Page not found", comment: ""))',
            "buttonText": '\(NSLocalizedString("Refresh", comment: ""))',
            "message": '\(String(format: NSLocalizedString("The server IP address for \\'%@\\' could not be found.", comment: ""), tab.printURL))'
          }
        })
      """
      case "notConnectHost":
        return """
        window.aeroBrowserResponse.getPageStrings({
          data: {
            "lang": '\(lang)',
            "headTitle": '\(NSLocalizedString("Unable to connect to site", comment: ""))',
            "title": '\(NSLocalizedString("Unable to connect to site", comment: ""))',
            "buttonText": '\(NSLocalizedString("Refresh", comment: ""))',
            "message": '\(NSLocalizedString("Connection has been reset.", comment: ""))'
          }
        })
      """
      case "notConnectInternet":
        return """
        window.aeroBrowserResponse.getPageStrings({
          data: {
            "lang": '\(lang)',
            "headTitle": '\(NSLocalizedString("No internet connection", comment: ""))',
            "title": '\(NSLocalizedString("No internet connection", comment: ""))',
            "buttonText": '\(NSLocalizedString("Refresh", comment: ""))',
            "message": '\(NSLocalizedString("There is no internet connection.", comment: ""))'
          }
        })
      """
      case "occurredSSLError":
        return """
        window.aeroBrowserResponse.getPageStrings({
          data: {
            "lang": '\(lang)',
            "headTitle": '\(NSLocalizedString("SSL/TLS certificate error", comment: ""))',
            "title": '\(NSLocalizedString("SSL/TLS certificate error", comment: ""))',
            "buttonText": '\(NSLocalizedString("Refresh", comment: ""))',
            "message": '\(NSLocalizedString("A secure connection cannot be made because the certificate is not valid.", comment: ""))'
          }
        })
      """
      case "blockedContent":
        return """
        window.aeroBrowserResponse.getPageStrings({
          data: {
            "lang": '\(lang)',
            "headTitle": '\(NSLocalizedString("Blocked content", comment: ""))',
            "title": '\(NSLocalizedString("Blocked content", comment: ""))',
            "buttonText": '\(NSLocalizedString("Refresh", comment: ""))',
            "message": '\(NSLocalizedString("This content is blocked. To use the service, you must lower or turn off tracker blocking.", comment: ""))'
          }
        })
      """
      case "unknown":
        return """
        window.aeroBrowserResponse.getPageStrings({
          data: {
            "lang": '\(lang)',
            "headTitle": '\(NSLocalizedString("Unknown error", comment: ""))',
            "title": '\(NSLocalizedString("Unknown error", comment: ""))',
            "buttonText": '\(NSLocalizedString("Refresh", comment: ""))',
            "message": '\(NSLocalizedString("An unknown error occurred.", comment: ""))'
          }
        })
      """
      default:
        print("ParameterError getPageStrings")
    }
    
    return """
      window.aeroBrowserResponse.getPageStrings({
        data: "error"
      })
    """
  }
}
