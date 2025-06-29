import SwiftUI
import AnimateText

struct WelcomeIntroView: View {
    @State private var text: String = ""
    @State private var showButton = false

    var body: some View {
        ZStack {
            // Frosted glass material background
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                AnimateText<GeorgeEffect>($text)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                if showButton {
                    Button(action: {
                        NotificationCenter.default.post(name: .didFinishIntroAnimation, object: nil)
                    }) {
                        Text("Close")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(Color("Point"))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("InputBG").opacity(0.5))
                            )
                    }
                    .buttonStyle(.plain)
                    .frame(width: 160)
                }
            }
            .padding()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                text = "Welcome to AeroBrowser"
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                withAnimation { showButton = true }
            }
        }
    }
}
