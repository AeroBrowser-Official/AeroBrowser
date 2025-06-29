import SwiftUI

struct AboutView: View {
  @ObservedObject var browser: Browser

  var body: some View {
    VStack(spacing: 32) {
      VStack(alignment: .leading, spacing: 24) {
        Text("About")
          .font(.system(size: 24, weight: .semibold))
          .foregroundColor(Color("UIText"))
          .padding(.bottom, 6)

        // Logo & Version Info
        HStack(alignment: .center, spacing: 16) {
          Image("Logo")
            .resizable()
            .frame(width: 72, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 8)

          VStack(alignment: .leading, spacing: 4) {
            Text("AeroBrowser")
              .font(.system(size: 22, weight: .semibold, design: .rounded))
              .foregroundColor(Color("UIText"))

            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
              Text("Version \(version)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color("UIText").opacity(0.6))
            }
          }
        }

        // Links
        VStack(spacing: 16) {
          AboutInfoRow(title: "GitHub Repository", link: "https://github.com/AeroBrowser-Official/AeroBrowser", browser: browser)
          AboutInfoRow(title: "Licenses", link: "https://github.com/AeroBrowser-Official/AeroBrowser/blob/main/LICENSE", browser: browser)
          AboutInfoRow(title: "Contact / Feedback", link: "https://aerobrowser.pages.dev/support", browser: browser)
        }
      }

      Spacer()

      // Footer
      Text("© 2025 AeroBrowser Team")
        .font(.system(size: 11))
        .foregroundColor(Color("UIText").opacity(0.4))
    }
    .padding(.horizontal, 24)
    .padding(.top, 32)
  }
}

struct AboutInfoRow: View {
  let title: String
  let link: String
  @ObservedObject var browser: Browser

  var body: some View {
    Button(action: {
      if let url = URL(string: link) {
        browser.newTab(url)
      }
    }) {
      Text(title)
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(Color("Point"))
        .underline()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .buttonStyle(.plain)
    .padding(.horizontal, 16)
    .padding(.vertical, 16)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(Color("InputBG").opacity(0.5))
    )
  }
}
