//
//  DownloadManager.swift
//  AeroBrowser
//
//  Created by AeroBrowser on 2/28/26.
//

import SwiftUI
import WebKit

class DownloadManager: ObservableObject {
    static let shared = DownloadManager()
    
    @Published var downloads: [DownloadItem] = []
    @Published var hasActiveDownloads: Bool = false
    
    private init() {}
    
    func addDownload(filename: String, url: URL?, download: WKDownload?) -> DownloadItem {
        let item = DownloadItem(filename: filename, url: url, download: download)
        DispatchQueue.main.async {
            self.downloads.insert(item, at: 0)
            self.updateActiveState()
            GuidedTipController.shared.showContextualTip(.downloads)
        }
        return item
    }
    
    func updateProgress(for item: DownloadItem, received: Int64, total: Int64) {
        DispatchQueue.main.async {
            item.receivedBytes = received
            item.totalBytes = total
            item.objectWillChange.send()
            self.objectWillChange.send()
        }
    }
    
    func markCompleted(_ item: DownloadItem, at url: URL?) {
        DispatchQueue.main.async {
            item.destinationURL = url
            item.state = .completed
            item.objectWillChange.send()
            self.updateActiveState()
        }
    }
    
    func markFailed(_ item: DownloadItem, error: String, resumeData: Data?) {
        DispatchQueue.main.async {
            item.errorMessage = error
            item.resumeData = resumeData
            item.state = .failed
            item.objectWillChange.send()
            self.updateActiveState()
        }
    }
    
    func clearCompleted() {
        DispatchQueue.main.async {
            self.downloads.removeAll { $0.state == .completed || $0.state == .failed || $0.state == .cancelled }
            self.updateActiveState()
        }
    }
    
    func clearAll() {
        DispatchQueue.main.async {
            for item in self.downloads where item.state == .downloading {
                item.cancel()
            }
            self.downloads.removeAll()
            self.updateActiveState()
        }
    }
    
    private func updateActiveState() {
        hasActiveDownloads = downloads.contains { $0.state == .downloading }
    }
}
