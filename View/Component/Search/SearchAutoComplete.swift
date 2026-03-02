//
//  SearchAutoComplete.swift
//  AeroBrowser
//
//  Created by Falsy on 3/17/24.
//

import SwiftUI
import SwiftData

struct SearchAutoComplete: View {
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  
  private var searchCount: Int { min(tab.autoCompleteList.count, 5) }
  private var visitCount: Int { min(tab.autoCompleteVisitList.count, 5) }
  private var suggestCount: Int { min(tab.searchSuggestions.count, 5) }
  
  var body: some View {
    VStack(spacing: 0) {
      // Search history matches
      if searchCount > 0 {
        ForEach(Array(tab.autoCompleteList.enumerated().prefix(5)), id: \.element.id) { index, autoComplete in
          SearchAutoCompleteItemNSView(browser: browser, tab: tab, searchHistoryGroup: autoComplete, isActive: tab.autoCompleteIndex == index)
            .allowsHitTesting(true)
        }
      }
      
      // Visit history matches
      if visitCount > 0 {
        if searchCount > 0 {
          Divider().opacity(0.3).padding(.vertical, 3)
        }
        ForEach(Array(tab.autoCompleteVisitList.enumerated().prefix(5)), id: \.element.id) { index, autoComplete in
          SearchAutoCompleteVisitItemNSView(browser: browser, tab: tab, visitHistoryGroup: autoComplete, isActive: tab.autoCompleteIndex == searchCount + index)
            .allowsHitTesting(true)
        }
      }
      
      // Google search suggestions
      if suggestCount > 0 {
        if searchCount > 0 || visitCount > 0 {
          Divider().opacity(0.3).padding(.vertical, 3)
        }
        ForEach(Array(tab.searchSuggestions.enumerated().prefix(5)), id: \.offset) { index, suggestion in
          SearchSuggestionRow(
            browser: browser,
            tab: tab,
            text: suggestion,
            isActive: tab.autoCompleteIndex == searchCount + visitCount + index
          )
        }
      }
    }
    .padding(.bottom, 5)
  }
}

// MARK: - Suggestion Row

struct SearchSuggestionRow: View {
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  let text: String
  let isActive: Bool
  
  @State private var isHovered = false
  
  var body: some View {
    HStack(spacing: 6) {
      Image(systemName: "magnifyingglass")
        .font(.system(size: 10))
        .foregroundColor(Color("Icon").opacity(0.5))
        .frame(width: 14)
      
      Text(text)
        .font(.system(size: 12))
        .foregroundColor(Color("UIText"))
        .lineLimit(1)
        .truncationMode(.tail)
      
      Spacer()
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 5)
    .background(
      RoundedRectangle(cornerRadius: 4)
        .fill((isActive || isHovered) ? Color("UIText").opacity(0.06) : .clear)
    )
    .contentShape(Rectangle())
    .onHover { isHovered = $0 }
    .onTapGesture {
      DispatchQueue.main.async {
        tab.inputURL = text
        tab.searchInSearchBar()
      }
    }
  }
}
