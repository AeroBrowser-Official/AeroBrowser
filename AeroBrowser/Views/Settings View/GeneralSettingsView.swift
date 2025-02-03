import SwiftUI

struct GeneralRow: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.1)) // Neutral background
                .frame(height: 120)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)

            HStack {
                // Placeholder for Row's gradient or image
                Color.blue
                    .frame(width: 80, height: 80)
                    .cornerRadius(15)
                    .padding(.leading, 20)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Row Title") // Placeholder text for title
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Row Description") // Placeholder text for description
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
                .padding(.leading, 20)

                Spacer()
            }
        }
        .padding(.horizontal, 16) // Adjust padding
        .padding(.top, 10) // Adjust top padding for spacing
    }
}

struct GeneralSettingsView: View {
    var body: some View {
        VStack(spacing: 30) {
            // Header Section
            VStack {
                Text("General Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.top, 40)
                
                Text("Select a setting that suits your preferences.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 5)
                    .padding(.horizontal, 40)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 30)

            // Rows Section
            VStack(spacing: 16) {
                GeneralRow()
            }

            // Information Section
            VStack {
                Text("Adjusting settings will help personalize your app experience.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)

            Spacer()
        }
        .padding(.horizontal, 16) // Horizontal padding for content
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}
