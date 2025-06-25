//
//  OpacityApp.swift
//  Opacity
//
//  Created by Falsy on 1/7/24.
//

import SwiftUI
import Sparkle



@main
struct OpacityApp: App {
  
  // Initialize Sparkle only for macOS
  private let updaterController: SPUStandardUpdaterController
  
  init() {
      updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
  }
  
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  var body: some Scene {
    Settings {
      EmptyView()
    }
    .commands {
      MainCommands(appDelegate: appDelegate)
      CleanCommands(appDelegate: appDelegate)
    }
  }
}
