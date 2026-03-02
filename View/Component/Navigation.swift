//
//  TitleView.swift
//  AeroBrowser
//
//  Created by Falsy on 1/7/24.
//

import SwiftUI

// MARK: - Reusable toolbar icon button
private struct NavIconButton: View {
    let icon: String
    let isActive: Bool
    var badge: Bool = false
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color("Icon"))
                    .frame(width: 28, height: 28)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill((isHovered || isActive) ? Color("UIText").opacity(0.08) : .clear)
                    )
                
                if badge {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 7, height: 7)
                        .offset(x: 2, y: -1)
                }
            }
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.12)) {
                isHovered = hovering
            }
        }
    }
}

struct Navigation: View {
    @ObservedObject var service: Service
    @ObservedObject var browser: Browser
    @ObservedObject var tab: Tab

    @State private var isMoreMenuDialog = false
    @State private var isDownloadsPopover = false
    @State private var isFindDetailDialog = true
    @State private var isNotificationDetailDialog = true

    @ObservedObject private var downloadManager = DownloadManager.shared

    var body: some View {
        HStack(spacing: 8) {
            // ── Navigation controls ──
            HistoryBackBtn(browser: browser, tab: tab)
            HistoryForwardBtn(browser: browser, tab: tab)

            if tab.pageProgress > 0 && tab.pageProgress < 1 {
                HistoryStopBtn(tab: tab, iconHeight: 28, iconRadius: 6)
            } else {
                HistoryRefreshBtn(iconHeight: 28, iconRadius: 6)
            }

            Spacer().frame(width: 4)

            // ── Search bar ──
            SearchBoxArea(browser: browser)
                .frame(maxWidth: .infinity)

            Spacer().frame(width: 4)

            // ── Contextual icons (only when active) ──
            if tab.isZoomDialog {
                NavIconButton(icon: "plus.magnifyingglass", isActive: true) {
                    tab.isZoomDialog.toggle()
                }
                .popover(isPresented: $tab.isZoomDialog, arrowEdge: .bottom) {
                    ZoomDialog(tab: tab)
                }
            }

            if tab.isFindDialog {
                NavIconButton(icon: "doc.text.magnifyingglass", isActive: true) {}
                    .onAppear { isFindDetailDialog = true }
                    .onChange(of: isFindDetailDialog) { _, nV in
                        if !nV { tab.isFindDialog = false }
                    }
                    .popover(isPresented: $isFindDetailDialog, arrowEdge: .bottom) {
                        FindDialog(tab: tab)
                    }
            }

            if tab.isNotificationDialogIcon {
                NavIconButton(icon: "bell.slash", isActive: false) {
                    isNotificationDetailDialog.toggle()
                }
                .onAppear { isNotificationDetailDialog = true }
                .popover(isPresented: $isNotificationDetailDialog, arrowEdge: .bottom) {
                    NotificationDialog(tab: tab)
                }
            }

            if tab.isLocationDialogIcon {
                NavIconButton(icon: "location.slash", isActive: false) {
                    tab.isLocationDialog.toggle()
                }
                .popover(isPresented: $tab.isLocationDialog, arrowEdge: .bottom) {
                    GeoLocationDialog()
                }
            }

            // ── Persistent toolbar icons ──
            NavIconButton(icon: "arrow.down.circle", isActive: isDownloadsPopover, badge: downloadManager.hasActiveDownloads) {
                isDownloadsPopover.toggle()
            }
            .popover(isPresented: $isDownloadsPopover, arrowEdge: .bottom) {
                DownloadsPopover()
            }

            NavIconButton(icon: "sidebar.right", isActive: browser.isSideBar) {
                AppDelegate.shared.isSidebar()
            }

            NavIconButton(icon: "ellipsis", isActive: isMoreMenuDialog) {
                isMoreMenuDialog.toggle()
            }
            .popover(isPresented: $isMoreMenuDialog, arrowEdge: .bottom) {
                MoreMenuDialog(browser: browser, tab: tab, isMoreMenuDialog: $isMoreMenuDialog)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
    }
}
