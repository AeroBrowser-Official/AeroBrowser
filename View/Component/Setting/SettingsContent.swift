//
//  SettingsContent.swift
//  AeroBrowser
//
//  Created by Falsy on 6/3/25.
//

import SwiftUI
import SwiftData

struct SettingsContent: View {
  let selectedCategory: SettingsCategory
  let generalSettings: [GeneralSetting]
  @ObservedObject var browser: Browser
  
  init(selectedCategory: SettingsCategory, generalSettings: [GeneralSetting], browser: Browser) {
    self.selectedCategory = selectedCategory
    self.generalSettings = generalSettings
    self.browser = browser
  }
  
  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack(alignment: .leading, spacing: 0) {
        switch selectedCategory {
        case .general:
          GeneralSettingsView(browser: browser, generalSettings: generalSettings)
        case .Theme:
            ThemesSettingsView(browser: browser)
        case .searchHistory:
          SearchHistorySettingsView(browser: browser)
        case .visitHistory:
          VisitHistorySettingsView(browser: browser)
        case .permissions:
          PermissionsSettingsView(browser: browser)
        case .library:
          LibrarySettingsView(browser: browser)
        case .About:
            AboutView(browser: browser)
      }
        
        Spacer(minLength: 40)
      }
      .padding(.horizontal, 36)
      .padding(.top, 32)
      .frame(maxWidth: .infinity, alignment: .topLeading)
    }
  }
}
