import SwiftUI

struct MainView: View {
    @ObservedObject var service: Service
    @ObservedObject var browser: Browser

    @AppStorage("selectedTheme") private var selectedTheme: String = Theme.bluePurple.rawValue
    @AppStorage("customThemes") private var customThemesData: Data = Data()

    private var effects: ThemeEffects {
        ThemeEffects.resolve(selectedTheme: selectedTheme, customThemesData: customThemesData)
    }

    var body: some View {
        ZStack {
            // Layer 1: Vibrancy / frosted glass (shows desktop when chromeOpacity < 1)
            if effects.blurRadius > 0 {
                VisualEffectNSView()
                    .edgesIgnoringSafeArea(.all)
            }
            
            // Layer 2: Gradient with adjustable opacity
            effects.gradient
                .opacity(effects.chromeOpacity)
                .edgesIgnoringSafeArea(.all)
            
            // Layer 3: Frosted blur on top of gradient
            if effects.blurRadius > 0 {
                Color.white.opacity(0.001) // invisible layer to apply blur
                    .background(.ultraThinMaterial)
                    .opacity(min(effects.blurRadius / 30.0, 0.6))
                    .edgesIgnoringSafeArea(.all)
            }
            
            // Layer 4: Noise texture
            if effects.noiseOpacity > 0.001 {
                NoiseTexture(opacity: effects.noiseOpacity)
                    .edgesIgnoringSafeArea(.all)
            }

            // Layer 5: Browser content
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
                                geometryHeight: geometry.size.height - 52
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
