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
        case .bluePurple:
            return LinearGradient(
                colors: [Color(hex: "#667EEA"), Color(hex: "#764BA2")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .greenYellow:
            return LinearGradient(
                colors: [Color(hex: "#F2994A"), Color(hex: "#F2C94C")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .redOrange:
            return LinearGradient(
                colors: [Color(hex: "#E44D56"), Color(hex: "#F09819")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .tealPink:
            return LinearGradient(
                colors: [Color(hex: "#43CEA2"), Color(hex: "#E05FC4")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .midnight:
            return LinearGradient(
                colors: [Color(hex: "#0F2027"), Color(hex: "#203A43"), Color(hex: "#2C5364")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .icyMist:
            return LinearGradient(
                colors: [Color(hex: "#E0EAFC"), Color(hex: "#CFDEF3")],
                startPoint: .top, endPoint: .bottom
            )
        case .forestBloom:
            return LinearGradient(
                colors: [Color(hex: "#11998E"), Color(hex: "#38EF7D")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .velvetDusk:
            return LinearGradient(
                colors: [Color(hex: "#4A00E0"), Color(hex: "#8E2DE2")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
    }
}
