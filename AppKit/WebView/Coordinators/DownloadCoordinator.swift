//
//  DownloadCoordinator.swift
//  AeroBrowser
//
//  Created by Falsy on 5/24/25.
//

import SwiftUI
import WebKit

class DownloadCoordinator: NSObject, WKDownloadDelegate {
  var parent: MainWebView!
  private var downloadItems: [WKDownload: DownloadItem] = [:]
  
  init(parent: MainWebView) {
    self.parent = parent
    super.init()
  }
  
  func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
    let downloadsDir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
    
    // Generate unique filename if file exists
    var destURL = downloadsDir.appendingPathComponent(suggestedFilename)
    var counter = 1
    let nameWithoutExt = (suggestedFilename as NSString).deletingPathExtension
    let ext = (suggestedFilename as NSString).pathExtension
    
    while FileManager.default.fileExists(atPath: destURL.path) {
      let newName = ext.isEmpty ? "\(nameWithoutExt) (\(counter))" : "\(nameWithoutExt) (\(counter)).\(ext)"
      destURL = downloadsDir.appendingPathComponent(newName)
      counter += 1
    }
    
    let item = DownloadManager.shared.addDownload(
      filename: suggestedFilename,
      url: response.url,
      download: download
    )
    item.destinationURL = destURL
    if let expectedLength = response.expectedContentLength as? Int64, expectedLength > 0 {
      item.totalBytes = expectedLength
    }
    downloadItems[download] = item
    
    completionHandler(destURL)
  }
  
  func download(_ download: WKDownload, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    guard let item = downloadItems[download] else { return }
    DownloadManager.shared.updateProgress(for: item, received: totalBytesWritten, total: totalBytesExpectedToWrite)
  }
  
  func downloadDidFinish(_ download: WKDownload) {
    guard let item = downloadItems[download] else { return }
    DownloadManager.shared.markCompleted(item, at: item.destinationURL)
    downloadItems.removeValue(forKey: download)
  }
  
  func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
    guard let item = downloadItems[download] else { return }
    DownloadManager.shared.markFailed(item, error: error.localizedDescription, resumeData: resumeData)
    downloadItems.removeValue(forKey: download)
  }
  
  // Called when navigation becomes a download
  func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
    download.delegate = self
  }
  
  func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
    download.delegate = self
  }
}
