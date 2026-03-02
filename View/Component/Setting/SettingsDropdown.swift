//
//  SettingsDropdown.swift
//  AeroBrowser
//
//  Created by Falsy on 6/3/25.
//

import SwiftUI

struct SettingsDropdown: View {
    @Binding var selection: String
    let options: [String]
    @State private var isHovered = false
    
    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(action: { selection = option }) {
                    if option == selection {
                        Label(option, systemImage: "checkmark")
                    } else {
                        Text(option)
                    }
                }
            }
        } label: {
            HStack(spacing: 0) {
                Text(selection)
                    .font(.system(size: 13))
                    .foregroundColor(Color("UIText"))
                
                Spacer()
                
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 10))
                    .foregroundColor(Color("Icon").opacity(0.6))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(Color("InputBG"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .stroke(isHovered ? Color("UIBorder").opacity(0.8) : Color("UIBorder").opacity(0.4), lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(.plain)
        .frame(width: 200)
        .onHover { isHovered = $0 }
    }
}
