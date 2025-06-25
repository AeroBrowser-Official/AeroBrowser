import Foundation
import SwiftUI

struct WhatsNewEntry: Identifiable {
    var id: String { title }
    let title: String
    let icon: String
    let description: String
}

struct WhatsNewVersion: Identifiable {
    var id: String { version }
    let version: String
    let title: String
    let items: [WhatsNewEntry]
}

struct WhatsNewStore {
    static let allVersions: [WhatsNewVersion] = [
        WhatsNewVersion(
            version: "1.0.2",
            title: "Version 1.0.2",
            items: [
                WhatsNewEntry(title: "Bug Fixes", icon: "ant", description: "Fixed Sparkle updater and improved stability."),
                WhatsNewEntry(title: "Redesigned About Page", icon: "info.circle", description: "Updated About page layout and visuals."),
                WhatsNewEntry(title: "What's New Page", icon: "doc.text", description: "New What’s New window appears on update."),
                WhatsNewEntry(title: "Theme Page", icon: "paintbrush", description: "Switch themes easily from the new Theme settings.")
            ]
        ),
        WhatsNewVersion(
            version: "1.0.1",
            title: "Version 1.0.1",
            items: [
                WhatsNewEntry(title: "UI Redesign", icon: "rectangle.and.pencil.and.ellipsis", description: "Homepage and About window redesigned with cleaner spacing."),
                WhatsNewEntry(title: "About Window", icon: "info.circle", description: "Now opens as a floating window, not blocking the app."),
                WhatsNewEntry(title: "Auto-Updater Fix", icon: "arrow.triangle.2.circlepath", description: "Sparkle update checking and installation now works properly."),
                WhatsNewEntry(title: "Sidebar Logic", icon: "sidebar.left", description: "Improved toggle behavior for sidebar."),
                WhatsNewEntry(title: "Tab Fixes", icon: "folder", description: "Minor tab memory and layout fixes."),
                WhatsNewEntry(title: "Icon & Fonts", icon: "textformat.size", description: "Better spacing and text rendering on small screens.")
            ]
        ),
        WhatsNewVersion(
            version: "1.0.0",
            title: "Version 1.0.0",
            items: [
                WhatsNewEntry(title: "Full Rewrite", icon: "hammer", description: "The app was fully rewritten with a new design and logic."),
                WhatsNewEntry(title: "Ad Blocker", icon: "nosign", description: "Blocks most annoying ads by default."),
                WhatsNewEntry(title: "Bookmarks", icon: "bookmark", description: "Added support for saving and organizing bookmarks."),
                WhatsNewEntry(title: "Search History", icon: "clock", description: "Browser keeps track of your search history."),
                WhatsNewEntry(title: "Custom Search Engines", icon: "magnifyingglass", description: "Choose Google, Bing, Yahoo, and more."),
                WhatsNewEntry(title: "Reset Options", icon: "trash", description: "Clear your browser data by days/weeks."),
                WhatsNewEntry(title: "Captcha Avoidance", icon: "shield.lefthalf.fill", description: "Redesigned internals to reduce Google CAPTCHA triggers.")
            ]
        ),
        WhatsNewVersion(
            version: "0.0.2-alpha",
            title: "v0.0.2 Alpha",
            items: [
                WhatsNewEntry(title: "Settings Page", icon: "gear", description: "Added settings view to configure your browser."),
                WhatsNewEntry(title: "AeroAI View", icon: "sparkles", description: "Placeholder for future AI features."),
                WhatsNewEntry(title: "Theme Settings", icon: "paintpalette", description: "Change and preview your AeroBrowser theme."),
                WhatsNewEntry(title: "Advanced Settings", icon: "gearshape.2.fill", description: "Stub for upcoming advanced tweaks."),
                WhatsNewEntry(title: "Design Changes", icon: "rectangle.3.offgrid.bubble.left", description: "Blurred UI, removed stroke/shadows, improved visuals.")
            ]
        ),
        WhatsNewVersion(
            version: "0.0.1-alpha",
            title: "v0.0.1 Alpha",
            items: [
                WhatsNewEntry(title: "Early Access", icon: "flame", description: "Initial release of AeroBrowser (Alpha stage).")
            ]
        )
    ]
}
