import Cocoa
import SwiftUI

class IntroOverlayController {
    var window: NSWindow!
    var hostingView: NSHostingView<WelcomeIntroView>!

    init() {
        let screenRect = NSScreen.main?.frame ?? .zero
        let windowSize = CGSize(width: 600, height: 400)
        let origin = CGPoint(
            x: screenRect.midX - windowSize.width / 2,
            y: screenRect.midY - windowSize.height / 2
        )

        let rect = NSRect(origin: origin, size: windowSize)

        // Create the window
        window = NSWindow(
            contentRect: rect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.alphaValue = 0
        window.level = .floating
        window.ignoresMouseEvents = false
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.collectionBehavior = [.canJoinAllSpaces]

        // Create the hosting view with blurred background and corner radius
        let rootView = WelcomeIntroView()
        hostingView = NSHostingView(rootView: rootView)
        hostingView.wantsLayer = true
        hostingView.layer?.cornerRadius = 30
        hostingView.layer?.masksToBounds = true
        hostingView.alphaValue = 0
        window.contentView = hostingView

        // Show the window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        // Animate fade in
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 1.2
            self.window.animator().alphaValue = 1.0
            self.hostingView.animator().alphaValue = 1.0
        }

        // Listen for notification to close
        NotificationCenter.default.addObserver(
            forName: .didFinishIntroAnimation,
            object: nil,
            queue: .main
        ) { _ in
            self.fadeOutAndClose()
        }
    }

    func fadeOutAndClose() {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.8
            self.window.animator().alphaValue = 0
        }, completionHandler: {
            self.window.close()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                AppDelegate.shared?.createWindow()
            }
        })
    }
}

extension Notification.Name {
    static let didFinishIntroAnimation = Notification.Name("didFinishIntroAnimation")
}
