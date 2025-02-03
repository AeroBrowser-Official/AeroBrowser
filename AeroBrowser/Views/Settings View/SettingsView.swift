import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gearshape.fill")
                }
            AeroAIView()
                .tabItem {
                    Label {
                        Text("Aero AI")
                    } icon: {
                        Image("AeroAI")
                            .resizable()
                            .renderingMode(.template) // Makes the image behave like a system icon
                            .scaledToFit()
                            .frame(width: 20, height: 20) // Matches the size of system icons
                    }
                }
            ThemesSettingsView()
                .tabItem {
                    Label("Themes", systemImage: "swatchpalette.fill")
                }
            AdvancedSettingsView()
                .tabItem {
                    Label("Advanced", systemImage: "star.fill")
                }
        }
        .frame(width: 700, height: 400) // Set the desired frame size here
        .padding(.top, 0.1)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .previewLayout(.sizeThatFits)
    }
}
