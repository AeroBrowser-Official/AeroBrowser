import SwiftUI

struct AboutView: View {
  @ObservedObject var browser: Browser

  var body: some View {
    VStack {
      VStack(spacing: 24) {
        Spacer(minLength: 4)
        
        // Logo
        Image("Logo")
          .resizable()
          .frame(width: 72, height: 72)
          .clipShape(RoundedRectangle(cornerRadius: 16))
          .shadow(radius: 8)

        // App Name + Version
        VStack(spacing: 4) {
          Text("AeroBrowser")
            .font(.system(size: 22, weight: .semibold, design: .rounded))
            .foregroundColor(Color("UIText"))

          if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            Text("Version \(version)")
              .font(.system(size: 14, weight: .medium))
              .foregroundColor(Color("UIText").opacity(0.6))
          }
        }

        Divider().background(Color.white.opacity(0.08)).padding(.horizontal, 40)

        // Links centered
        VStack(spacing: 12) {
          AboutLinkRow(title: "GitHub Repository", link: "https://github.com/aerobrowser/aerobrowser", browser: browser)
          AboutLinkRow(title: "Licenses", link: "https://github.com/aerobrowser/aerobrowser/blob/main/LICENSE", browser: browser)
          AboutLinkRow(title: "Contact / Feedback", link: "mailto:support@aerobrowser.com", browser: browser)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 40)
        .multilineTextAlignment(.center)

        Divider().background(Color.white.opacity(0.08)).padding(.horizontal, 40)

        // Footer
        Text("© 2025 AeroBrowser Team")
          .font(.system(size: 11))
          .foregroundColor(Color("UIText").opacity(0.4))
      }
      .padding(8)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(
        RoundedRectangle(cornerRadius: 20)
          .fill(Color("InputBG").opacity(0.5))
          .overlay(
            RoundedRectangle(cornerRadius: 20)
              .stroke(Color.white.opacity(0.05), lineWidth: 1)
          )
      )
      .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 6)
    }
    .padding(16)
  }
}

struct AboutLinkRow: View {
  let title: String
  let link: String
  @ObservedObject var browser: Browser

  var body: some View {
    Button(action: {
      if let url = URL(string: link) {
        browser.newTab(url)
      }
    }) {
      HStack(spacing: 8) {
        Image(systemName: "arrow.up.right.square")
          .font(.system(size: 12))
        Text(title)
          .font(.system(size: 13, weight: .medium))
      }
      .frame(maxWidth: .infinity)
      .foregroundColor(Color("Point"))
      .multilineTextAlignment(.center)
    }
    .buttonStyle(.plain)
    .padding(.horizontal, 16)
  }
}
