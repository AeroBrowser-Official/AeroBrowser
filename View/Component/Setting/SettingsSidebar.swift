//
//  SettingsSidebar.swift
//  AeroBrowser
//
//  Created by Falsy on 6/3/25.
//

import SwiftUI

struct SettingsSidebar: View {
    @Binding var selectedCategory: SettingsCategory
    
    var body: some View {
        VStack(spacing: 0) {
            // App branding
            HStack(spacing: 10) {
                Image("MainLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                
                Text(NSLocalizedString("Settings", comment: ""))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("UIText"))
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 32)
            .padding(.bottom, 24)
            
            // Nav items
            VStack(spacing: 2) {
                ForEach(SettingsCategory.allCases, id: \.self) { category in
                    SettingsSidebarItem(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            
            Spacer()
            
            // Version footer
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                Text("v\(version)")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.5))
                    .padding(.bottom, 16)
            }
        }
        .frame(width: 220)
        .background(Color("SearchBarBG"))
    }
}

struct SettingsSidebarItem: View {
    let category: SettingsCategory
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHover = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: category.icon)
                    .font(.system(size: 13))
                    .foregroundColor(isSelected ? .accentColor : Color("Icon"))
                    .frame(width: 18)
                
                Text(category.localizedTitle)
                    .font(.system(size: 13, weight: isSelected ? .medium : .regular))
                    .foregroundColor(isSelected ? Color("UIText") : Color("UIText").opacity(0.8))
                
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(
                        isSelected ? Color.accentColor.opacity(0.1) :
                        isHover ? Color("UIText").opacity(0.04) :
                        Color.clear
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                isHover = hovering
            }
        }
    }
}
