import SwiftUI

struct MainView: View {
    @ObservedObject var service: Service
    @ObservedObject var browser: Browser

    @AppStorage("selectedTheme") private var selectedTheme: String = Theme.bluePurple.rawValue
    private var currentTheme: Theme {
        Theme(rawValue: selectedTheme) ?? .bluePurple
    }

    var body: some View {
        ZStack {
            currentTheme.gradient
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

                        // ✅ Only ONE active tab rendered
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
