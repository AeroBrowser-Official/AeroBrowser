//
//  SideBarView.swift
//  AeroBrowser
//
//  Created by Falsy on 3/6/24.
//

import SwiftUI
import SwiftData

struct SideBarView: View {
    @Query var bookmarks: [Bookmark]
    @ObservedObject var service: Service
    @ObservedObject var browser: Browser
    @State var isCloseHover: Bool = false
    @State var searchText: String = ""
    
    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .frame(width: 0.5)
                .foregroundColor(Color("UIBorder").opacity(0.5))
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text(NSLocalizedString("Bookmark", comment: ""))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("UIText"))
                    
                    Spacer()
                    
                    Button(action: { browser.isSideBar = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color("Icon"))
                            .frame(width: 22, height: 22)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(isCloseHover ? Color("UIText").opacity(0.08) : .clear)
                            )
                    }
                    .buttonStyle(.plain)
                    .onHover { isCloseHover = $0 }
                }
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 10)
                
                BookmarkSearch(searchText: $searchText)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 10)
                
                Divider().opacity(0.5)
                
                if searchText.isEmpty {
                    BookmarkList(service: service, browser: browser)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 8)
                        .padding(.leading, 4)
                        .padding(.trailing, 14)
                    BookmarkDragAreaNSView(service: service)
                } else {
                    BookmarkSearchList(service: service, browser: browser, bookmarks: bookmarks, searchText: $searchText)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 14)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("SearchBarBG"))
            .contextMenu {
                Button(NSLocalizedString("Add Folder", comment: "")) {
                    if let baseBookmarkGroup = BookmarkManager.getBaseBookmarkGroup() {
                        BookmarkManager.addBookmarkGroup(parentGroup: baseBookmarkGroup)
                    }
                }
            }
        }
        .frame(maxWidth: 260, maxHeight: .infinity)
    }
}
