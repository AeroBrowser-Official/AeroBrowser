import SwiftUI

struct WhatsNewView: View {
    @ObservedObject var manager: WhatsNewManager
    @Environment(\.dismiss) var dismiss

    @State private var isHover = false
    @State private var isPressed = false

    var body: some View {
        VStack(spacing: 20) {
            if let version = manager.latestVersion {
                Text("What’s New in \(version.version)")
                    .font(.title2).bold()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(version.items) { item in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: item.icon)
                                    .font(.title2)
                                    .frame(width: 28)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title).font(.headline)
                                    Text(item.description).font(.subheadline).foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Custom styled Continue button
                Button(action: {
                    dismiss()
                }) {
                    Text("Continue")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color("Point"))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    isPressed ? Color("UIText").opacity(0.1) :
                                    isHover ? Color("UIText").opacity(0.05) :
                                    Color.clear
                                )
                        )
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isHover = hovering
                    }
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            withAnimation(.easeInOut(duration: 0.05)) {
                                isPressed = true
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.easeInOut(duration: 0.1)) {
                                isPressed = false
                            }
                        }
                )
                .padding(.bottom)
            } else {
                Text("No updates")
                Button("Close") {
                    dismiss()
                }
            }
        }
        .padding()
        .frame(width: 420, height: 500)
    }
}
