import Foundation

struct WhatsNewItem: Codable, Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let version: String
    let date: Date
}
