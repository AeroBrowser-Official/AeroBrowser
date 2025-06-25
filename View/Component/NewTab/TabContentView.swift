import SwiftUI
import SwiftData

struct TabContentView: View {
    @ObservedObject var service: Service
    @ObservedObject var browser: Browser
    @ObservedObject var tab: Tab
    let isActive: Bool
    let geometryHeight: CGFloat

    var body: some View {
        Group {
            if tab.isInit {
                NewTabView(browser: browser, tab: tab)
            } else if tab.isSetting {
                SettingsView(browser: browser)
            } else if tab.showErrorPage, let errorType = tab.errorPageType {
                ErrorPageView(
                    errorType: errorType,
                    failingURL: tab.errorFailingURL
                ) {
                    if let url = URL(string: tab.errorFailingURL) {
                        DispatchQueue.main.async {
                            tab.showErrorPage = false
                            tab.errorPageType = nil
                            tab.errorFailingURL = ""
                            tab.updateURLBySearch(url: url)
                        }
                    }
                }
                .onAppear {
                    if let mainLogoImage = NSImage(named: "MainLogo") {
                        tab.favicon = Image(nsImage: mainLogoImage)
                    }
                }
            } else {
                // ✅ This is your ONLY WebView render — no ZStack, no duplicate
                WebviewArea(service: service, browser: browser, tab: tab)
                    .cornerRadius(20)
                    .padding([.leading, .trailing, .bottom], 10)
                    .shadow(radius: 5)
            }
        }
        .offset(y: isActive ? 0 : geometryHeight + 1)
        .frame(height: geometryHeight + 1)
        .onChange(of: tab.isClearWebview) { _, newValue in
            if newValue && tab.isInit {
                DispatchQueue.main.async {
                    tab.isClearWebview = false
                    tab.complateCleanUpWebview?()
                }
            }
        }
    }
}
