import Foundation

class BrowserModel: ObservableObject {
    @Published var currentURL: URL? = URL(string: "https://www.apple.com")
    @Published var searchQuery: String = ""
    @Published var history: [URL] = []
    @Published var bookmarks: [URL] = []

    func addBookmark() {
        guard let url = currentURL else { return }
        bookmarks.append(url)
    }

    func updateCurrentURL(from query: String) {
        if let url = URL(string: query) {
            currentURL = url
        }
    }

    func addToHistory(url: URL) {
        history.append(url)
    }
}
