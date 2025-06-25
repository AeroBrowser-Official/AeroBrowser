import SwiftUI

enum Theme: String, CaseIterable, Identifiable {
    case bluePurple = "Aurora"
    case greenYellow = "Solar Flare"
    case redOrange = "Crimson Heat"
    case tealPink = "Neon Sunset"
    case midnight = "Midnight Blue"
    case icyMist = "Icy Mist"
    case forestBloom = "Forest Bloom"
    case velvetDusk = "Velvet Dusk"

    var id: String { rawValue }

    var gradient: LinearGradient {
        switch self {
        case .bluePurple: // Aurora
            return LinearGradient(colors: [Color.blue, Color.purple], startPoint: .top, endPoint: .bottom)
        case .greenYellow: // Solar Flare
            return LinearGradient(colors: [Color.green, Color.yellow], startPoint: .top, endPoint: .bottom)
        case .redOrange: // Crimson Heat
            return LinearGradient(colors: [Color.red, Color.orange], startPoint: .top, endPoint: .bottom)
        case .tealPink: // Neon Sunset
            return LinearGradient(colors: [Color.teal, Color.pink], startPoint: .top, endPoint: .bottom)
        case .midnight: // Midnight Blue
            return LinearGradient(colors: [Color.black, Color.indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .icyMist:
            return LinearGradient(colors: [Color.cyan, Color.white], startPoint: .top, endPoint: .bottom)
        case .forestBloom:
            return LinearGradient(colors: [Color.green.opacity(0.6), Color.brown], startPoint: .top, endPoint: .bottom)
        case .velvetDusk:
            return LinearGradient(colors: [Color.purple, Color.black], startPoint: .top, endPoint: .bottom)
        }
    }
}
