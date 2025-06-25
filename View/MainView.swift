import SwiftUI

struct MainView: View {
    @ObservedObject var service: Service
    @ObservedObject var browser: Browser

    @AppStorage("selectedTheme") private var selectedTheme: String = Theme.bluePurple.rawValue
    @AppStorage("customThemes") private var customThemesData: Data = Data()

    // Determine the current theme's gradient (built-in or custom)
    private var currentGradient: LinearGradient {
        // Built-in match
        if let theme = Theme.allCases.first(where: { $0.rawValue == selectedTheme }) {
            return theme.gradient
        }

        // Custom UUID match
        if let uuid = UUID(uuidString: selectedTheme),
           let customThemes = try? JSONDecoder().decode([CustomTheme].self, from: customThemesData),
           let matched = customThemes.first(where: { $0.id == uuid }) {
            return matched.gradient
        }

        return Theme.bluePurple.gradient
    }

    var body: some View {
        ZStack {
            currentGradient
                .edgesIgnoringSafeArea(.all)

            HStack(spacing: 0) {
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        NavigationSearchView(
                            service: service,
                            browser: browser,
                            activeTabId: $browser.activeTabId,
                            isFullScreen: .constant(false)
                        )

                        if let activeId = browser.activeTabId,
                           let tab = browser.tabs.first(where: { $0.id == activeId }) {
                            TabContentView(
                                service: service,
                                browser: browser,
                                tab: tab,
                                isActive: true,
                                geometryHeight: geometry.size.height - 54
                            )
                        }
                    }
                }

                if browser.isSideBar {
                    SideBarView(service: service, browser: browser)
                }
            }
        }
    }
}
