//
//  DownloadsPopover.swift
//  AeroBrowser
//
//  Created by AeroBrowser on 2/28/26.
//

import SwiftUI

struct DownloadsPopover: View {
    @ObservedObject var downloadManager = DownloadManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Downloads")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("UIText"))
                Spacer()
                if !downloadManager.downloads.isEmpty {
                    Button(action: { downloadManager.clearCompleted() }) {
                        Text("Clear")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .onHover { inside in
                        if inside { NSCursor.pointingHand.push() }
                        else { NSCursor.pop() }
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            
            Divider().opacity(0.5)
            
            if downloadManager.downloads.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "arrow.down.circle")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.secondary.opacity(0.4))
                    Text("No downloads")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary.opacity(0.6))
                }
                .frame(maxWidth: .infinity, minHeight: 90)
                .padding(.vertical, 16)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(downloadManager.downloads) { item in
                            DownloadItemRow(item: item)
                            
                            if item.id != downloadManager.downloads.last?.id {
                                Divider().opacity(0.3)
                                    .padding(.leading, 46)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .frame(maxHeight: 300)
            }
        }
        .frame(width: 300)
    }
}

struct DownloadItemRow: View {
    @ObservedObject var item: DownloadItem
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 10) {
            fileIcon
                .frame(width: 28, height: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.filename)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("UIText"))
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                switch item.state {
                case .downloading:
                    ProgressView(value: max(0.02, item.progress))
                        .progressViewStyle(.linear)
                        .tint(.accentColor)
                    Text(item.formattedProgress)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        
                case .completed:
                    Text("Completed")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: "#34C759"))
                        
                case .failed:
                    Text(item.errorMessage ?? "Failed")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "#FF3B30"))
                        .lineLimit(1)
                        
                case .cancelled:
                    Text("Cancelled")
                        .font(.system(size: 10))
                        .foregroundColor(.orange)
                }
            }
            
            Spacer(minLength: 4)
            actionButtons
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isHovered ? Color("UIText").opacity(0.04) : .clear)
        )
        .onHover { isHovered = $0 }
        .contentShape(Rectangle())
    }
    
    @ViewBuilder
    private var fileIcon: some View {
        let ext = (item.filename as NSString).pathExtension.lowercased()
        let iconName: String = {
            switch ext {
            case "pdf": return "doc.richtext"
            case "zip", "gz", "tar", "7z", "rar": return "doc.zipper"
            case "dmg", "iso": return "externaldrive"
            case "png", "jpg", "jpeg", "gif", "webp", "svg": return "photo"
            case "mp4", "mov", "avi", "mkv": return "film"
            case "mp3", "wav", "aac", "flac": return "music.note"
            case "doc", "docx": return "doc.text"
            case "xls", "xlsx": return "tablecells"
            case "ppt", "pptx": return "rectangle.on.rectangle"
            default: return "doc"
            }
        }()
        
        Image(systemName: iconName)
            .font(.system(size: 16))
            .foregroundColor(.accentColor.opacity(0.8))
    }
    
    @ViewBuilder
    private var actionButtons: some View {
        switch item.state {
        case .downloading:
            Button(action: { item.cancel() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary.opacity(0.6))
            }
            .buttonStyle(.plain)
            
        case .completed:
            HStack(spacing: 4) {
                Button(action: { item.revealInFinder() }) {
                    Image(systemName: "folder")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Reveal in Finder")
                
                Button(action: { item.openFile() }) {
                    Image(systemName: "arrow.up.forward.square")
                        .font(.system(size: 12))
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                .help("Open")
            }
            
        case .failed, .cancelled:
            EmptyView()
        }
    }
}
