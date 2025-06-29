import SwiftUI

struct ThemesSettingsView: View {
    @AppStorage("selectedTheme") private var selectedTheme: String = Theme.bluePurple.rawValue
    @AppStorage("customColor1Hex") private var customColor1Hex: String = "#000000"
    @AppStorage("customColor2Hex") private var customColor2Hex: String = "#000000"
    @AppStorage("customDirection") private var customDirection: String = "topbottom"

    @ObservedObject var browser: Browser

    @State private var CustomColor1: Color
    @State private var CustomColor2: Color
    @State private var CustomRotation: String

    init(browser: Browser) {
        _browser = ObservedObject(wrappedValue: browser)

        _CustomColor1 = State(initialValue: Color(hex: UserDefaults.standard.string(forKey: "customColor1Hex") ?? "#000000"))
        _CustomColor2 = State(initialValue: Color(hex: UserDefaults.standard.string(forKey: "customColor2Hex") ?? "#000000"))
        _CustomRotation = State(initialValue: UserDefaults.standard.string(forKey: "customDirection") ?? "topbottom")
    }

    let directionOptions = [
        DirectionOption(icon: "arrow.down", value: "topbottom"),
        DirectionOption(icon: "arrow.right", value: "sxdx"),
        DirectionOption(icon: "arrow.down.left", value: "diagdxsx"),
        DirectionOption(icon: "arrow.down.right", value: "diagsxdx")
    ]

    var builtInThemes: [Theme] {
        Theme.allCases
    }

    var selectedThemeEnum: Theme {
        Theme(rawValue: selectedTheme) ?? .bluePurple
    }

    struct StyledColorPicker: View {
        let title: String
        @Binding var color: Color

        var body: some View {
            VStack(spacing: 6) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)

                HStack(spacing: 0) {
                    ColorPicker("", selection: $color)
                        .labelsHidden()
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                }
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color("InputBG"))
                        .stroke(Color("UIBorder"), lineWidth: 0.5)
                )
                .frame(width: 200)
            }
        }
    }

    
    var currentGradient: LinearGradient {
        if selectedThemeEnum == .custom {
            return selectedThemeEnum.gradient(
                customColor1: CustomColor1,
                customColor2: CustomColor2,
                CustomRotation: CustomRotation
            )
        } else {
            return selectedThemeEnum.gradient()
        }
    }

    var body: some View {
        VStack(spacing: 32) {
            // 🔹 Theme Picker centered
            VStack(spacing: 6) {
                Text("Active Theme")
                    .font(.caption)
                    .foregroundColor(.gray)
                SettingsDropdown(
                    selection: $selectedTheme,
                    options: builtInThemes.map { $0.rawValue }
                )
            }
            .frame(maxWidth: .infinity)

            // 🔹 Gradient Preview
            VStack(alignment: .leading, spacing: 8) {
                Text("Preview")
                    .font(.caption)
                    .foregroundColor(.gray)

                Rectangle()
                    .fill(currentGradient)
                    .frame(height: 120)
                    .cornerRadius(12)
            }

            // 🔹 Direction and Color Pickers (only for custom)
            if selectedThemeEnum == .custom {
                VStack(spacing: 24) {
                    VStack(spacing: 6) {
                        Text("Direction")
                            .font(.caption)
                            .foregroundColor(.gray)
                        CustomSettingsDropdown(
                            selection: $CustomRotation,
                            options: directionOptions
                        )
                        .frame(width: 200)
                    }

                    HStack(spacing: 60) {
                        VStack(spacing: 6) {
                            StyledColorPicker(title: "First Color", color: $CustomColor1)

                        }

                        VStack(spacing: 6) {
                            StyledColorPicker(title: "Second Color", color: $CustomColor2)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }

            Spacer()
        }
        .padding(40)
        .onChange(of: CustomColor1) { new in
            customColor1Hex = new.toHex()
            browser.customColor1 = new
        }
        .onChange(of: CustomColor2) { new in
            customColor2Hex = new.toHex()
            browser.customColor2 = new
        }
        .onChange(of: CustomRotation) { new in
            customDirection = new
            browser.customPosition = new
        }
    }

    struct DirectionOption: Identifiable, Hashable {
        let id = UUID()
        let icon: String
        let value: String

        var label: String {
            switch value {
            case "topbottom": return "Top to Bottom"
            case "sxdx": return "Left to Right"
            case "diagdxsx": return "Diagonal ↘︎"
            case "diagsxdx": return "Diagonal ↙︎"
            default: return value
            }
        }
    }

    struct CustomSettingsDropdown: View {
        @Binding var selection: String
        let options: [DirectionOption]

        var body: some View {
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option.label) {
                        selection = option.value
                    }
                }
            } label: {
                HStack(spacing: 0) {
                    Text(selectedLabel)
                        .font(.system(size: 14))
                        .foregroundColor(Color("UIText"))

                    Spacer()

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(Color("Icon"))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color("InputBG"))
                        .stroke(Color("UIBorder"), lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)
            .frame(width: 200)
        }

        private var selectedLabel: String {
            options.first(where: { $0.value == selection })?.label ?? selection
        }
    }
}
