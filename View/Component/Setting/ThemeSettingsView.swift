import SwiftUI

struct ThemesSettingsView: View {
    @AppStorage("selectedTheme") private var selectedTheme: String = Theme.bluePurple.rawValue
    @ObservedObject var browser: Browser

    var builtInThemes: [Theme] {
        Theme.allCases
    }

    var currentGradient: LinearGradient {
        builtInThemes.first(where: { $0.rawValue == selectedTheme })?.gradient
        ?? LinearGradient(colors: [.gray, .gray], startPoint: .top, endPoint: .bottom)
    }

    var body: some View {
        VStack(spacing: 32) {
            HStack {
                Text("Themes")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color("UIText"))
                Spacer()
            }

            VStack(spacing: 24) {
                SettingsRow(title: "Active Theme") {
                    SettingsDropdown(
                        selection: $selectedTheme,
                        options: builtInThemes.map { $0.rawValue }
                    )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Preview")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Rectangle()
                        .fill(currentGradient)
                        .frame(height: 120)
                        .cornerRadius(12)
                }
            }

            Spacer()
        }
        .padding(40)
    }
}
