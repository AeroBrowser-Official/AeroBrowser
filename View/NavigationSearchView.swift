import SwiftUI

struct NavigationSearchView: View {
    @ObservedObject var service: Service
    @ObservedObject var browser: Browser
    @Binding var activeTabId: UUID?
    @Binding var isFullScreen: Bool

    var body: some View {
        ZStack {
            Color.clear // No gradient here, uses MainView's background

            if let activeTab = browser.tabs.first(where: { $0.id == activeTabId }) {
                Navigation(service: service, browser: browser, tab: activeTab)
                    .id(activeTab.id)
                    .frame(height: 44)
                    .padding(.horizontal, 12)
            }
        }
        .frame(height: 54)
    }
}
