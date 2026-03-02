//
//  DownloadItem.swift
//  AeroBrowser
//
//  Created by AeroBrowser on 2/28/26.
//

import SwiftUI
import WebKit

enum DownloadState: String {
    case downloading
    case completed
    case failed
    case cancelled
}

class DownloadItem: ObservableObject, Identifiable {
    let id = UUID()
    let filename: String
    let url: URL?
    var destinationURL: URL?
    
    @Published var totalBytes: Int64 = -1
    @Published var receivedBytes: Int64 = 0
    @Published var state: DownloadState = .downloading
    @Published var errorMessage: String?
    
    let startDate = Date()
    weak var download: WKDownload?
    var resumeData: Data?
    
    var progress: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(receivedBytes) / Double(totalBytes)
    }
    
    var formattedProgress: String {
        let received = ByteCountFormatter.string(fromByteCount: receivedBytes, countStyle: .file)
        if totalBytes > 0 {
            let total = ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file)
            return "\(received) / \(total)"
        }
        return received
    }
    
    init(filename: String, url: URL?, download: WKDownload?) {
        self.filename = filename
        self.url = url
        self.download = download
    }
    
    func cancel() {
        download?.cancel { [weak self] resumeData in
            DispatchQueue.main.async {
                self?.resumeData = resumeData
                self?.state = .cancelled
            }
        }
    }
    
    func revealInFinder() {
        if let url = destinationURL {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        }
    }
    
    func openFile() {
        if let url = destinationURL {
            NSWorkspace.shared.open(url)
        }
    }
}
