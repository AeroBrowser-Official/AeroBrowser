import SwiftUI

struct MainContentView: View {
    @Binding var url: URL?
    @AppStorage("selectedTheme") private var selectedTheme: String = Theme.bluePurple.rawValue

    private var currentTheme: Theme {
        Theme(rawValue: selectedTheme) ?? .bluePurple
    }

    var body: some View {
        ZStack {
            // Apply the gradient based on the selected theme
            currentTheme.gradient
                .edgesIgnoringSafeArea(.all)
            
            // WebView (Displays the webpage content)
            WebView(url: $url)
                .cornerRadius(20)  // Rounded corners for the WebView
                .padding([.leading, .trailing], 10)  // Padding around the WebView
                .padding(.top, 10) // Top padding to avoid space at the top of WebView
                .padding(.bottom, 10) // Bottom padding to avoid space at the bottom of WebView
        }
    }
}
