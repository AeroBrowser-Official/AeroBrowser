import SwiftUI
import Sparkle

@main
struct AeroBrowserApp: App {
    @State private var isSidebarVisible = true
    
    // Initialize Sparkle only for macOS
    private let updaterController: SPUStandardUpdaterController
    
    init() {
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(isSidebarVisible: $isSidebarVisible)
        }
        
        .commands {
            // Add to the "View" menu
            CommandGroup(after: .sidebar) {
                Button(isSidebarVisible ? "Hide Sidebar" : "Show Sidebar") {
                    withAnimation(.easeInOut) {
                        isSidebarVisible.toggle()
                    }
                }
                .keyboardShortcut("S", modifiers: .command) // CMD+S for the shortcut
            }
            
            // Sparkle "Check for Updates" command
            CommandGroup(after: .appInfo) {
                Button("Check for Updates") {
                    updaterController.checkForUpdates(self)
                }
            }
        }
        .windowStyle(.hiddenTitleBar)
        // macOS-specific Settings
        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}
