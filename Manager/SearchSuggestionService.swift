//
//  SearchSuggestionService.swift
//  AeroBrowser
//
//  Created by AeroBrowser on 2/28/26.
//

import Foundation

class SearchSuggestionService {
    static let shared = SearchSuggestionService()
    
    private var currentTask: URLSessionDataTask?
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 3
        config.timeoutIntervalForResource = 5
        session = URLSession(configuration: config)
    }
    
    /// Fetches search suggestions from Google Suggest API.
    /// Calls completion on main thread with array of suggestion strings.
    func fetchSuggestions(for query: String, completion: @escaping ([String]) -> Void) {
        // Cancel any in-flight request
        currentTask?.cancel()
        
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.count >= 2 else {
            DispatchQueue.main.async { completion([]) }
            return
        }
        
        guard let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://suggestqueries.google.com/complete/search?client=firefox&q=\(encoded)") else {
            DispatchQueue.main.async { completion([]) }
            return
        }
        
        currentTask = session.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            
            // Response format: ["query", ["suggestion1", "suggestion2", ...]]
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [Any],
                   json.count >= 2,
                   let suggestions = json[1] as? [String] {
                    // Filter out the exact query and limit to 5
                    let filtered = suggestions
                        .filter { $0.lowercased() != trimmed.lowercased() }
                        .prefix(5)
                    DispatchQueue.main.async {
                        completion(Array(filtered))
                    }
                } else {
                    DispatchQueue.main.async { completion([]) }
                }
            } catch {
                DispatchQueue.main.async { completion([]) }
            }
        }
        currentTask?.resume()
    }
    
    func cancel() {
        currentTask?.cancel()
    }
}
