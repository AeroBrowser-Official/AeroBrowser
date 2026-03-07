//
//  BrowserTips.swift
//  AeroBrowser
//
//  Created by AeroBrowser on 3/7/26.
//

import SwiftUI

// MARK: - Tip Step Enum

enum GuidedTipStep: Int, CaseIterable {
    case addressBar = 0
    case newTab
    case sidebar
    case moreMenu
    case searchEngine   // after first search
    case downloads      // after first download
    case shortcuts      // after 3+ tabs
    case none

    var title: String {
        switch self {
        case .addressBar:   return "Search or enter a URL"
        case .newTab:       return "Tabs & favorites"
        case .sidebar:      return "Bookmarks & sidebar"
        case .moreMenu:     return "More options"
        case .searchEngine: return "Switch search engines"
        case .downloads:    return "Downloads"
        case .shortcuts:    return "Keyboard shortcuts"
        case .none:         return ""
        }
    }

    var message: String {
        switch self {
        case .addressBar:   return "Type anything to search the web, or enter a website address directly."
        case .newTab:       return "Click the + button in the tab bar to open a new tab. Add your favorite sites for quick access on the new tab page."
        case .sidebar:      return "Open the sidebar to access your bookmarks. Bookmark any page with the ☆ icon in the address bar."
        case .moreMenu:     return "Access settings, zoom, find on page, and more from this menu."
        case .searchEngine: return "Click the search icon to quickly switch between Google, Bing, Yahoo, and DuckDuckGo."
        case .downloads:    return "Your downloads appear here. Track progress, open files, or reveal them in Finder."
        case .shortcuts:    return "⌘T new tab  •  ⌘W close tab  •  ⌘L address bar  •  ⌘R reload  •  ⌘F find"
        case .none:         return ""
        }
    }

    var icon: String {
        switch self {
        case .addressBar:   return "magnifyingglass"
        case .newTab:       return "plus.square.on.square"
        case .sidebar:      return "sidebar.right"
        case .moreMenu:     return "ellipsis"
        case .searchEngine: return "arrow.triangle.swap"
        case .downloads:    return "arrow.down.circle"
        case .shortcuts:    return "keyboard"
        case .none:         return ""
        }
    }
}

// MARK: - Guided Tip Controller

class GuidedTipController: ObservableObject {
    static let shared = GuidedTipController()

    /// The step currently being shown. `.none` means no tip visible.
    @Published var currentStep: GuidedTipStep = .none

    /// Steps that are part of the initial guided tour (shown in order)
    private let initialTour: [GuidedTipStep] = [
        .addressBar, .newTab, .sidebar, .moreMenu, .shortcuts
    ]

    /// Tracks which step index we're on in the initial tour
    private var tourIndex: Int = 0
    
    /// Whether the tour is currently running (not yet completed)
    private var isTourActive: Bool = false

    private let completedKey = "guidedTipCompleted"

    private init() {
        if !UserDefaults.standard.bool(forKey: completedKey) {
            isTourActive = true
            tourIndex = 0
            // Don't show immediately — wait for views to appear
        }
    }
    
    /// Call once after the main window is visible to start the tour
    func startTourIfNeeded() {
        guard isTourActive, currentStep == .none else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self, self.isTourActive else { return }
            self.currentStep = self.initialTour[self.tourIndex]
        }
    }

    /// Call when the user dismisses the current tip
    func dismiss() {
        // Clear current step immediately
        currentStep = .none
        
        if isTourActive {
            tourIndex += 1
            if tourIndex < initialTour.count {
                // Show next tip after a short delay so popover animation finishes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                    guard let self, self.isTourActive else { return }
                    self.currentStep = self.initialTour[self.tourIndex]
                }
            } else {
                // Tour complete
                isTourActive = false
                UserDefaults.standard.set(true, forKey: completedKey)
            }
        }
    }

    /// Show a contextual tip (outside the initial tour) if nothing is showing
    func showContextualTip(_ step: GuidedTipStep) {
        guard currentStep == .none, !isTourActive else { return }
        let key = "contextualTip_\(step.rawValue)_shown"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        UserDefaults.standard.set(true, forKey: key)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.currentStep = step
        }
    }

    /// Reset for testing
    func reset() {
        UserDefaults.standard.removeObject(forKey: completedKey)
        for step in GuidedTipStep.allCases {
            UserDefaults.standard.removeObject(forKey: "contextualTip_\(step.rawValue)_shown")
        }
        tourIndex = 0
        isTourActive = true
        currentStep = .none
    }
}

// MARK: - Tip Popover View

struct GuidedTipPopover: View {
    let step: GuidedTipStep
    let onDismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: step.icon)
                .font(.system(size: 20))
                .foregroundStyle(.tint)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)

                Text(step.message)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(Color.primary.opacity(0.06)))
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .frame(width: 280)
    }
}

// MARK: - Convenience modifier

private struct GuidedTipModifier: ViewModifier {
    let step: GuidedTipStep
    @ObservedObject var controller: GuidedTipController
    let arrowEdge: Edge
    
    @State private var isShowing: Bool = false
    
    func body(content: Content) -> some View {
        content
            .popover(isPresented: $isShowing, arrowEdge: arrowEdge) {
                GuidedTipPopover(step: step) {
                    isShowing = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        controller.dismiss()
                    }
                }
                .interactiveDismissDisabled()
            }
            .onAppear {
                // Sync state when view first appears or is recreated
                let shouldShow = (controller.currentStep == step)
                if shouldShow != isShowing {
                    // Small delay to let the view settle before showing popover
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if controller.currentStep == step {
                            isShowing = true
                        }
                    }
                }
            }
            .onReceive(controller.$currentStep) { newStep in
                let shouldShow = (newStep == step)
                if shouldShow && !isShowing {
                    isShowing = true
                } else if !shouldShow && isShowing {
                    isShowing = false
                }
            }
    }
}

extension View {
    /// Attaches a guided-tip popover that shows only when the controller's step matches.
    func guidedTip(
        _ step: GuidedTipStep,
        controller: GuidedTipController = .shared,
        arrowEdge: Edge = .bottom
    ) -> some View {
        self.modifier(GuidedTipModifier(step: step, controller: controller, arrowEdge: arrowEdge))
    }
}

// MARK: - Stub types (prevent compile errors from old references)

struct AddressBarTip {}
struct SearchEngineTip { @MainActor static var hasSearched: Bool = false }
struct SidebarTip { @MainActor static var addressBarDismissed: Bool = false }
struct DownloadsTip { @MainActor static var hasDownloaded: Bool = false }
struct MoreMenuTip { @MainActor static var addressBarDismissed: Bool = false }
struct TabManagementTip {}
struct NewTabTip {}
struct KeyboardShortcutsTip { @MainActor static var tabCount: Int = 0 }
struct ThemeCustomizationTip { @MainActor static var hasOpenedSettings: Bool = false }
