import SwiftUI

struct ThemesSettingsView: View {
    @AppStorage("selectedTheme") private var selectedTheme: String = Theme.bluePurple.rawValue
    @ObservedObject var browser: Browser
    @State public var CustomColor1 = Color.black
        @State public var CustomColor2 = Color.black
        @State public var CustomRotation: String = ""

        let directionOptions = [
                DirectionOption(icon: "arrow.down", value: "topbottom"),
                DirectionOption(icon: "arrow.right", value: "sxdx"),
                DirectionOption(icon: "arrow.down.left", value: "diagdxsx"),
                DirectionOption(icon: "arrow.down.right", value: "diagsxdx")
            ]


    var builtInThemes: [Theme] {
        Theme.allCases
    }

    var currentGradient: LinearGradient {
        if selectedThemeEnum == .custom {
                    return LinearGradient(colors: [browser.customColor1, browser.customColor2], startPoint: .top, endPoint: .bottom)
                } else {
                    return selectedThemeEnum.gradient()
                }
            }
            struct CustomSettingsDropdown: View {
                @Binding var selection: String
                let options: [DirectionOption]

                var body: some View {
                    Picker(selection: $selection, label: Text("")) {
                                ForEach(options, id: \.self) { option in
                                    Image(systemName: option.icon)
                                        .tag(option.value)
                                }
                            }
                    .pickerStyle(MenuPickerStyle())
                    .padding(8)
                    //.background(Color.black)
                    .cornerRadius(8)
                    .foregroundColor(.white) // testo selezionato bianco
                    .tint(.blue) // colore selezione (blu, cambia a piacere)
                    .colorScheme(.dark) // forza tema scuro dentro il picker
                }
            }

            struct DirectionOption: Identifiable, Hashable {
                let id = UUID()
                let icon: String
                let value: String
            }

            var selectedThemeEnum: Theme {
                Theme(rawValue: selectedTheme) ?? .bluePurple
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
                    if (selectedThemeEnum == .custom) {
                                            //Add custom theme settings
                                            HStack {
                                                ColorPicker("First Color", selection: $browser.customColor1)
                                                ColorPicker("Second Color", selection: $browser.customColor2)
                                                CustomSettingsDropdown(selection: $browser.customPosition, options: directionOptions)
                                            }
                                            .padding(40)
                                        } else {
                                            EmptyView()
                                        }
                }
            }

            Spacer()
        }
        .padding(40)
    }
}
