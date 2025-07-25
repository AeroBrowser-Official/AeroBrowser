//
//  SettingsSidebar.swift
//  Opacity
//
//  Created by Falsy on 6/3/25.
//

import SwiftUI

struct SettingsSidebar: View {
  @Binding var selectedCategory: SettingsCategory
  
  var body: some View {
    VStack(spacing: 0) {
      VStack(spacing: 0) {
        HStack(spacing: 12) {
          Image("MainLogo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 60, height: 60)
          
          Text(NSLocalizedString("Settings", comment: ""))
            .font(.system(size: 20, weight: .regular))
            .foregroundColor(Color("UIText"))
          
          Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 42)
        .padding(.bottom, 32)
      }
      
      VStack(spacing: 4) {
        ForEach(SettingsCategory.allCases, id: \.self) { category in
          SettingsSidebarItem(
            category: category,
            isSelected: selectedCategory == category
          ) {
            selectedCategory = category
          }
        }
      }
      .padding(.horizontal, 20)
      
      Spacer(minLength: 40)
    }
    .frame(width: 240)
    .background(Color("SearchBarBG"))
  }
}

struct SettingsSidebarItem: View {
  let category: SettingsCategory
  let isSelected: Bool
  let action: () -> Void
  
  @State private var isHover: Bool = false
  @State private var isPressed: Bool = false
  
  var body: some View {
    Button(action: action) {
      HStack(spacing: 0) {
        Image(systemName: category.icon)
          .frame(width: 16, height: 16)
          .font(.system(size: 14))
          .foregroundColor(isSelected ? Color("Point") : Color("Icon"))
        
        Text(category.localizedTitle)
          .font(.system(size: 14))
          .foregroundColor(isSelected ? Color("Point") : Color("UIText"))
          .padding(.leading, 12)
        
        Spacer()
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(
            isSelected ? Color("Point").opacity(0.1) : 
            isPressed ? Color("UIText").opacity(0.1) :  // 프레스 피드백 추가
            isHover ? Color("UIText").opacity(0.05) : 
            Color.clear
          )
      )
      .contentShape(Rectangle())  // 전체 영역을 클릭 가능하게
    }
    .buttonStyle(.plain)
    .onHover { hovering in
      withAnimation(.easeInOut(duration: 0.1)) {  // 애니메이션 속도 개선: 0.15 → 0.1
        isHover = hovering
      }
    }
    .simultaneousGesture(
      DragGesture(minimumDistance: 0)
        .onChanged { _ in
          withAnimation(.easeInOut(duration: 0.05)) {
            isPressed = true
          }
        }
        .onEnded { _ in
          withAnimation(.easeInOut(duration: 0.1)) {
            isPressed = false
          }
        }
    )
  }
}
