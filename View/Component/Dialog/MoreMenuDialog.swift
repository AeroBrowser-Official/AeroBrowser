//
//  MoreMenuDialog.swift
//  AeroBrowser
//
//  Created by Falsy on 3/27/24.
//

import SwiftUI

// MARK: - Reusable menu row
private struct MenuRow: View {
    let icon: String
    let title: String
    var shortcutKey: String? = nil
    var shortcutModifier: String? = "command"
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(Color("Icon"))
                    .frame(width: 16)
                
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(Color("UIText"))
                
                Spacer()
                
                if let key = shortcutKey {
                    HStack(spacing: 2) {
                        if shortcutModifier == "command" {
                            Image(systemName: "command")
                                .font(.system(size: 9))
                        }
                        Text(key)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(Color("Icon").opacity(0.45))
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(isHovered ? Color("UIText").opacity(0.07) : .clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

struct MoreMenuDialog: View {
    @ObservedObject var browser: Browser
    @ObservedObject var tab: Tab
    @Binding var isMoreMenuDialog: Bool
    
    var body: some View {
        VStack(spacing: 2) {
            MenuRow(icon: "envelope", title: NSLocalizedString("Contact Us", comment: "")) {
                NSWorkspace.shared.open(URL(string: "mailto:")!)
                isMoreMenuDialog = false
            }
            
            Divider().padding(.vertical, 3)
            
            MenuRow(icon: "plus.magnifyingglass", title: NSLocalizedString("Zoom In", comment: ""), shortcutKey: "+") {
                tab.isZoomDialog = true
                tab.zoomLevel = ((tab.zoomLevel * 10) + 1) / 10
                isMoreMenuDialog = false
            }
            
            MenuRow(icon: "minus.magnifyingglass", title: NSLocalizedString("Zoom Out", comment: ""), shortcutKey: "–") {
                tab.isZoomDialog = true
                tab.zoomLevel = ((tab.zoomLevel * 10) - 1) / 10
                isMoreMenuDialog = false
            }
            
            Divider().padding(.vertical, 3)
            
            MenuRow(icon: "rectangle.badge.plus", title: NSLocalizedString("New Tab", comment: ""), shortcutKey: "T") {
                browser.initTab()
                isMoreMenuDialog = false
            }
            
            MenuRow(icon: "macwindow.badge.plus", title: NSLocalizedString("New Window", comment: ""), shortcutKey: "N") {
                AppDelegate.shared.newWindow()
                isMoreMenuDialog = false
            }
            
            Divider().padding(.vertical, 3)
            
            MenuRow(icon: "gearshape", title: NSLocalizedString("Settings", comment: "")) {
                browser.openSettings()
                isMoreMenuDialog = false
            }
        }
        .padding(6)
        .frame(width: 210)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color("DialogBG"))
        )
    }
}
