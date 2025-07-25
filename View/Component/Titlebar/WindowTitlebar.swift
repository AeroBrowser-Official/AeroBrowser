import SwiftUI

struct WindowTitlebar: View {
    @Binding var width: CGFloat
    @ObservedObject var service: Service
    @ObservedObject var browser: Browser

    @Binding var tabs: [Tab]
    @Binding var activeTabId: UUID?

    @State var tabWidth: CGFloat = 220
    @State private var isAddHover: Bool = false

    var body: some View {
        ZStack {
            Color.clear // ❗ No gradient here anymore

            HStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                        if Int(width / 80) > index {
                            BrowserTabView(
                                service: service,
                                browser: browser,
                                tabs: $tabs,
                                tab: tab,
                                activeTabId: $activeTabId,
                                index: index,
                                tabWidth: $tabWidth
                            ) {
                                DispatchQueue.main.async {
                                    let removeTabId = tabs[index].id
                                    tabs[index].closeTab {
                                        tabs.remove(at: index)
                                        if tabs.isEmpty {
                                            AppDelegate.shared.closeWindow()
                                        } else {
                                            let targetIndex = tabs.count > index ? index : tabs.count - 1
                                            activeTabId = tabs[targetIndex].id
                                            AppDelegate.shared.closeInspector(removeTabId)
                                        }
                                    }
                                }
                            }
                            .contentShape(Rectangle())
                        }
                    }

                    Button(action: {
                        if let keyWindow = NSApplication.shared.keyWindow {
                            let windowNumber = keyWindow.windowNumber
                            if let target = self.service.browsers[windowNumber] {
                                target.initTab()
                            }
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 12))
                            .frame(maxWidth: 24, maxHeight: 24)
                            .background(isAddHover ? .gray.opacity(0.2) : .gray.opacity(0))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .padding(.top, 1)
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                    .onHover { isHover in
                        withAnimation {
                            isAddHover = isHover
                        }
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 10)
        }
        .frame(height: 38)
    }
}
