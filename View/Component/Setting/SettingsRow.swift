//
//  SettingsRow.swift
//  AeroBrowser
//
//  Created by Falsy on 6/3/25.
//

import SwiftUI

struct SettingsRow<Content: View>: View {
  let title: String
  let content: () -> Content
  
  init(title: String, @ViewBuilder content: @escaping () -> Content) {
    self.title = title
    self.content = content
  }
  
  var body: some View {
    HStack(spacing: 0) {
      Text(title)
        .font(.system(size: 13))
        .foregroundColor(Color("UIText").opacity(0.8))
        .frame(width: 130, alignment: .leading)
      
      content()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}
