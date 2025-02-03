import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    @Binding var url: URL? // Binding to communicate the current URL to ContentView
    
    var userAgent: String = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()

        // Set the custom user agent
        webView.customUserAgent = userAgent
        
        // Set the delegate to capture URL changes
        webView.navigationDelegate = context.coordinator
        
        if let url = url {
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
            webView.load(request)
        }
        
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        if let url = url {
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
            nsView.load(request)
        }
    }

    // Coordinator to observe URL changes
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }

        // Update URL whenever the web view navigates to a new page
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.url = webView.url
        }
    }
}
