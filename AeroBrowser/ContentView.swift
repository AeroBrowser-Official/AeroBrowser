import SwiftUI

struct ContentView: View {
    @Binding var isSidebarVisible: Bool
    @State private var searchQuery: String = ""
    @State private var url: URL? = URL(string: "https://www.apple.com")
    @AppStorage("selectedTheme") private var selectedTheme: String = Theme.bluePurple.rawValue

    private var currentTheme: Theme {
        Theme(rawValue: selectedTheme) ?? .bluePurple
    }

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar with smoother slide-in and slide-out animations
            if isSidebarVisible {
                Sidebar(searchQuery: $searchQuery, url: $url)
                    .frame(width: 250)
                    .background(currentTheme.gradient)
                    .transition(
                        AnyTransition.move(edge: .leading)
                            .combined(with: .scale(scale: 1.0))
                    )
            }

            // Main content (WebView) with gradient background
            MainContentView(url: $url)
                .background(currentTheme.gradient)
                .edgesIgnoringSafeArea(.all)
        }
        .frame(minWidth: 800, minHeight: 600)
        .onAppear {
            // Restore sidebar visibility from previous state
            let sidebarVisible = UserDefaults.standard.bool(forKey: "isSidebarVisible")
            isSidebarVisible = sidebarVisible
            enforceWindowControlState(isSidebarVisible: sidebarVisible)
        }
        .onChange(of: isSidebarVisible) { newValue in
            // Save sidebar visibility state and update window controls
            UserDefaults.standard.set(newValue, forKey: "isSidebarVisible")
            enforceWindowControlState(isSidebarVisible: newValue)
        }
        .animation(
            Animation.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.3)
                .speed(1.2), // Adjust speed for smoother transitions
            value: isSidebarVisible
        )
    }

    private func enforceWindowControlState(isSidebarVisible: Bool) {
        DispatchQueue.main.async {
            if let window = NSApp.mainWindow ?? NSApplication.shared.windows.first {
                if isSidebarVisible {
                    // Ensure window controls are visible
                    window.styleMask.insert([.closable, .miniaturizable, .resizable])
                } else {
                    // Force window controls to be hidden
                    window.styleMask.remove([.closable, .miniaturizable, .resizable])
                }
            }
        }
    }
}
