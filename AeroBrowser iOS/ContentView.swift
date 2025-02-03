import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            WebView(url: URL(string: "https://www.apple.com")!)
            
        }
        Rectangle()
            .fill(Color.blue)
            .frame(width: .infinity, height: 150)
            .padding()
    }
}

#Preview {
    ContentView()
}
