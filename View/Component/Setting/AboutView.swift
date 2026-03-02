import SwiftUI

struct AboutView: View {
    @ObservedObject var browser: Browser
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("About")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(Color("UIText"))
            
            // Logo & Version
            HStack(alignment: .center, spacing: 14) {
                Image("Logo")
                    .resizable()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("AeroBrowser")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("UIText"))
                    
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        Text("Version \(version)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Links
            VStack(spacing: 8) {
                AboutInfoRow(title: "GitHub Repository", link: "https://github.com/aerobrowser/aerobrowser", browser: browser)
                AboutInfoRow(title: "Licenses", link: "https://github.com/aerobrowser/aerobrowser/blob/main/LICENSE", browser: browser)
                AboutInfoRow(title: "Contact / Feedback", link: "mailto:support@aerobrowser.com", browser: browser)
            }
            
            Spacer()
            
            Text("© 2025 AeroBrowser Team")
                .font(.system(size: 10))
                .foregroundColor(.secondary.opacity(0.4))
        }
    }
}

struct AboutInfoRow: View {
    let title: String
    let link: String
    @ObservedObject var browser: Browser
    @State private var isHovered = false
    
    var body: some View {
        Button(action: {
            if let url = URL(string: link) {
                browser.newTab(url)
            }
        }) {
            HStack(spacing: 10) {
                Image(systemName: linkIcon)
                    .font(.system(size: 12))
                    .foregroundColor(.accentColor.opacity(0.7))
                    .frame(width: 16)
                
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color("UIText"))
                
                Spacer()
                
                Image(systemName: "arrow.up.forward")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.4))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isHovered ? Color("UIText").opacity(0.04) : Color("InputBG").opacity(0.4))
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
    
    private var linkIcon: String {
        if link.hasPrefix("mailto:") { return "envelope" }
        if link.contains("LICENSE") { return "doc.text" }
        return "link"
    }
}
