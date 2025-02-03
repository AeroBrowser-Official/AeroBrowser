import SwiftUI

enum Theme: String, CaseIterable {
    case bluePurple = "Blue & Purple"
    case greenYellow = "Green & Yellow"
    case redOrange = "Red & Orange"
    
    var gradient: LinearGradient {
        switch self {
        case .bluePurple:
            return LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .top, endPoint: .bottom)
        case .greenYellow:
            return LinearGradient(gradient: Gradient(colors: [Color.green, Color.yellow]), startPoint: .top, endPoint: .bottom)
        case .redOrange:
            return LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]), startPoint: .top, endPoint: .bottom)
        }
    }
}

struct ThemeRow: View {
    let theme: Theme
    @Binding var selectedTheme: String
    
    var body: some View {
        ZStack {
            // Use a neutral gradient if the theme is not selected
            RoundedRectangle(cornerRadius: 20)
                .fill(selectedTheme == theme.rawValue ? theme.gradient : LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.1)]), startPoint: .top, endPoint: .bottom))
                .frame(height: 120)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)

            HStack {
                theme.gradient
                    .frame(width: 80, height: 80)
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.8), lineWidth: 2)
                    )
                    .padding(.leading, 20)

                VStack(alignment: .leading, spacing: 8) {
                    Text(theme.rawValue)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(selectedTheme == theme.rawValue ? .white : .primary)

                    Text(selectedTheme == theme.rawValue ? "This theme is selected" : "Tap to select")
                        .font(.subheadline)
                        .foregroundColor(selectedTheme == theme.rawValue ? .white.opacity(0.8) : .secondary)
                        .padding(.top, 2)
                }
                .padding(.leading, 20)

                Spacer()

                if selectedTheme == theme.rawValue {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                        .padding(.trailing, 20)
                }
            }
        }
        .onTapGesture {
            selectedTheme = theme.rawValue
        }
        .animation(.spring(), value: selectedTheme)
    }
}

struct ThemesSettingsView: View {
    @AppStorage("selectedTheme") private var selectedTheme: String = Theme.bluePurple.rawValue

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header Section
                VStack {
                    Text("Themes Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.top, 40)
                    
                    Text("Select a theme that suits your style and personalize your experience.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 5)
                        .padding(.horizontal, 40)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 30)

                // Themes Section
                ForEach(Theme.allCases, id: \.self) { theme in
                    ThemeRow(theme: theme, selectedTheme: $selectedTheme)
                }
                
                // Information Section
                VStack {
                    Text("Changing your theme will give your app a fresh new look. Themes are designed to improve readability and aesthetics.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 30)
                        .padding(.top, 10)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)

                // Spacer to push content to the top if needed
                Spacer()
            }
            .padding(.horizontal, 16) // Control horizontal padding for the content
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Make sure VStack fills the available space
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Forces ScrollView to take up the full space
        .edgesIgnoringSafeArea(.all) // Optional: If you want the scroll view to go under the safe area (status bar, home indicator)
    }
}

struct ThemesSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ThemesSettingsView()
    }
}
