import SwiftUI
import Sparkle



@main
struct AeroBrowserApp: App {
  
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
