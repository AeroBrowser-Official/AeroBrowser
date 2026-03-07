import SwiftUI

struct WhatsNewView: View {
    @ObservedObject var manager: WhatsNewManager
    var onClose: () -> Void

    @AppStorage("selectedTheme") private var selectedTheme: String = "Aurora"
    @AppStorage("customThemes") private var customThemesData: Data = Data()

    @State private var buttonHover = false
    @State private var appeared = false

    private var currentGradient: LinearGradient {
        if let theme = Theme.allCases.first(where: { $0.rawValue == selectedTheme }) {
            return theme.gradient
        }
        if let uuid = UUID(uuidString: selectedTheme),
           let customThemes = try? JSONDecoder().decode([CustomTheme].self, from: customThemesData),
           let matched = customThemes.first(where: { $0.id == uuid }) {
            return matched.gradient
        }
        return Theme.bluePurple.gradient
    }

    var body: some View {
        ZStack {
            // Subtle gradient wash behind everything
            currentGradient
                .opacity(0.12)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                if let version = manager.latestVersion {
                    // ── Header ──
                    VStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 56, height: 56)

                            currentGradient
                                .mask(
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 26, weight: .medium))
                                )
                                .frame(width: 26, height: 26)
                        }
                        .scaleEffect(appeared ? 1 : 0.5)
                        .opacity(appeared ? 1 : 0)

                        VStack(spacing: 6) {
                            Text("What's New")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color("UIText"))

                            Text("Version \(version.version)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color("UIText").opacity(0.45))
                        }
                    }
                    .padding(.top, 28)
                    .padding(.bottom, 20)

                    // ── Top divider ──
                    Rectangle()
                        .fill(Color("UIBorder").opacity(0.3))
                        .frame(height: 0.5)
                        .padding(.horizontal, 32)

                    // ── Scrollable items ──
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            ForEach(Array(version.items.enumerated()), id: \.element.id) { index, item in
                                WhatsNewRow(
                                    item: item,
                                    gradient: currentGradient,
                                    index: index,
                                    appeared: appeared
                                )

                                if index < version.items.count - 1 {
                                    Rectangle()
                                        .fill(Color("UIBorder").opacity(0.15))
                                        .frame(height: 0.5)
                                        .padding(.leading, 56)
                                        .padding(.trailing, 24)
                                }
                            }
                        }
                        .padding(.vertical, 12)
                    }
                    .frame(maxHeight: .infinity)

                    // ── Bottom divider ──
                    Rectangle()
                        .fill(Color("UIBorder").opacity(0.3))
                        .frame(height: 0.5)
                        .padding(.horizontal, 32)

                    // ── Continue button ──
                    VStack(spacing: 0) {
                        Button(action: { onClose() }) {
                            Text("Continue")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    ZStack {
                                        currentGradient
                                        Color.white.opacity(buttonHover ? 0.15 : 0)
                                    }
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                .shadow(color: Color.black.opacity(0.12), radius: 4, y: 2)
                        }
                        .buttonStyle(.plain)
                        .onHover { hovering in
                            withAnimation(.easeInOut(duration: 0.15)) {
                                buttonHover = hovering
                            }
                        }
                        .padding(.horizontal, 32)
                    }
                    .padding(.vertical, 18)

                } else {
                    // ── Empty state ──
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 36, weight: .light))
                            .foregroundColor(Color("UIText").opacity(0.3))
                        Text("You're up to date")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color("UIText").opacity(0.5))
                    }
                    Spacer()
                    Button(action: { onClose() }) {
                        Text("Close")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color("UIText").opacity(0.7))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .fill(Color("UIText").opacity(0.06))
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 20)
                }
            }
        }
        .frame(width: 440, height: 520)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor))
        )
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                appeared = true
            }
        }
    }
}

// MARK: - Individual feature row

private struct WhatsNewRow: View {
    let item: WhatsNewEntry
    let gradient: LinearGradient
    let index: Int
    let appeared: Bool

    @State private var isHover = false

    var body: some View {
        HStack(spacing: 14) {
            // Gradient-masked icon in a soft rounded square
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color("UIText").opacity(0.04))
                    .frame(width: 34, height: 34)

                gradient
                    .mask(
                        Image(systemName: item.icon)
                            .font(.system(size: 15, weight: .medium))
                    )
                    .frame(width: 18, height: 18)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("UIText"))
                    .lineLimit(1)

                Text(item.description)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color("UIText").opacity(0.55))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(isHover ? Color("UIText").opacity(0.04) : Color.clear)
                .padding(.horizontal, 16)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.12)) {
                isHover = hovering
            }
        }
        .offset(y: appeared ? 0 : 12)
        .opacity(appeared ? 1 : 0)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.05),
            value: appeared
        )
    }
}

// MARK: - Preview

private class PreviewWhatsNewManager: WhatsNewManager {
    override init() {
        super.init()
        self.latestVersion = WhatsNewVersion(
            version: "1.0.2",
            title: "Version 1.0.2",
            items: [
                WhatsNewEntry(title: "Bug Fixes", icon: "ant", description: "Fixed Sparkle updater and improved stability."),
                WhatsNewEntry(title: "Redesigned About Page", icon: "info.circle", description: "Updated About page layout and visuals."),
                WhatsNewEntry(title: "What's New Page", icon: "doc.text", description: "New What's New window appears on update."),
                WhatsNewEntry(title: "Theme Settings", icon: "paintbrush", description: "Switch themes easily from the new Theme settings."),
                WhatsNewEntry(title: "Search Suggestions", icon: "magnifyingglass", description: "Get Google suggestions as you type in the address bar."),
                WhatsNewEntry(title: "Download Manager", icon: "arrow.down.circle", description: "Track and manage file downloads with progress indicators.")
            ]
        )
    }
}

#Preview("What's New") {
    WhatsNewView(manager: PreviewWhatsNewManager(), onClose: {})
        .frame(width: 440, height: 520)
}

#Preview("What's New — Empty") {
    let emptyManager = WhatsNewManager()
    emptyManager.latestVersion = nil
    return WhatsNewView(manager: emptyManager, onClose: {})
        .frame(width: 440, height: 520)
}
