import SwiftUI

struct Sidebar: View {
    @Binding var searchQuery: String
    @Binding var url: URL?

    @FocusState private var isFocused: Bool
    @State private var suggestions: [String] = []
    @State private var showSuggestions = false
    @State private var isLoading = false
    @State private var heightOfSuggestions: CGFloat = 0
    @AppStorage("selectedTheme") private var selectedTheme: String = Theme.bluePurple.rawValue

    private var currentTheme: Theme {
        Theme(rawValue: selectedTheme) ?? .bluePurple
    }

    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.black.opacity(0.2)) // Reduced opacity for better clarity
                    .blur(radius: 5) // Subtle blur
                    .frame(height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1) // Subtle border
                    )

                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.7)) // Subtle icon color
                    .padding(.leading, 12)

                TextField("Search or type a URL", text: $searchQuery)
                    .padding(.leading, 32)
                    .padding(.trailing, 32)
                    .padding(.vertical, 10)
                    .frame(height: 40)
                    .background(Color.clear)
                    .cornerRadius(15)
                    .focused($isFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white) // White text for better contrast
                    .onSubmit {
                        handleSearchQuery(searchQuery)
                    }

                if !searchQuery.isEmpty {
                    Button(action: {
                        searchQuery = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.trailing, 12)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.top, 20)
            .padding(.horizontal)

            if isFocused && !suggestions.isEmpty && showSuggestions {
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        ForEach(suggestions, id: \.self) { suggestion in
                            Text(suggestion)
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(Color.black.opacity(0.3)) // Darker background for suggestions
                                .onTapGesture {
                                    searchQuery = suggestion
                                    handleSearchQuery(suggestion)
                                    showSuggestions = false
                                }

                            Divider()
                                .background(Color.white.opacity(0.2))
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.black.opacity(0.4)) // Darker background with a bit of blur
                            .blur(radius: 5) // Subtle blur for suggestions
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5) // Softer shadow
                    .frame(width: geometry.size.width)
                    .frame(maxHeight: heightOfSuggestions)
                    .padding(.top, 5)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                .frame(height: heightOfSuggestions)
                .padding(.horizontal)
            }

            Spacer()
        }
        .background(currentTheme.gradient)
        .frame(width: 250)
        .padding(0)
        .onChange(of: url) { newURL in
            if let newURL = newURL {
                searchQuery = newURL.absoluteString
            }
        }
        .onChange(of: searchQuery) { newQuery in
            if !newQuery.isEmpty {
                fetchSearchSuggestions(for: newQuery)
            } else {
                showSuggestions = false
            }
        }
    }

    private func fetchSearchSuggestions(for query: String) {
        isLoading = true
        let urlString = "https://suggestqueries.google.com/complete/search?client=firefox&q=\(query)"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            isLoading = false
            if let data = data, error == nil {
                do {
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any],
                       let suggestionsArray = json[1] as? [String] {
                        DispatchQueue.main.async {
                            self.suggestions = Array(suggestionsArray.prefix(5))
                            self.heightOfSuggestions = CGFloat(self.suggestions.count * 40)
                            self.showSuggestions = true
                        }
                    }
                }
            }
        }
        .resume()
    }

    private func handleSearchQuery(_ query: String) {
        if query.isEmpty {
            return
        }

        let urlPattern = "([A-Za-z0-9]+://)?([A-Za-z0-9.-]+\\.[A-Za-z]{2,})"
        let regex = try! NSRegularExpression(pattern: urlPattern, options: .caseInsensitive)

        if let _ = regex.firstMatch(in: query, options: [], range: NSRange(location: 0, length: query.count)) {
            var finalURLString = query

            if !finalURLString.hasPrefix("http://") && !finalURLString.hasPrefix("https://") {
                finalURLString = "https://" + finalURLString
            }

            self.url = URL(string: finalURLString)
        } else {
            let searchURL = "https://www.google.com/search?q=" + query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            self.url = URL(string: searchURL)
        }
    }
}

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar(searchQuery: .constant(""), url: .constant(nil))
            .frame(height: 400)
            .preferredColorScheme(.dark)
    }
}
