//
//  SettingsView.swift
//  Opacity
//
//  Created by Falsy on 6/3/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
  @Query var generalSettings: [GeneralSetting]
    @Binding var selectedCategory: SettingsCategory
  @ObservedObject var browser: Browser
  
    init(browser: Browser) {
        self.browser = browser
        self._selectedCategory = Binding(get: {
            browser.selectedSettingsCategory
        }, set: {
            browser.selectedSettingsCategory = $0
        })
    }

  
  var body: some View {
    HStack(spacing: 0) {
      SettingsSidebar(selectedCategory: $selectedCategory)
      
      VStack(spacing: 0) {
        Rectangle()
          .frame(width: 0.5)
          .foregroundColor(Color("UIBorder"))
      }
      
      SettingsContent(selectedCategory: selectedCategory, generalSettings: generalSettings, browser: browser)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color("SearchBarBG"))
  }
}

enum SettingsCategory: String, CaseIterable {
  case general = "General"
    case Theme = "Theme"
  case searchHistory = "Search History"
  case visitHistory = "Visit History"
  case permissions = "Permissions"
  case library = "Library"
    case About = "About"
  
  var localizedTitle: String {
    NSLocalizedString(self.rawValue, comment: "")
  }
  
  var icon: String {
    switch self {
    case .general:
      return "gearshape"
    case .searchHistory:
      return "magnifyingglass.circle"
    case .visitHistory:
      return "text.page"
    case .permissions:
      return "shield.lefthalf.filled"
    case .library:
      return "book.closed"
    case .Theme:
        return "paintpalette"
    case .About:
        return "info.circle"

    }
  }
}
