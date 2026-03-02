//
//  TabItem.swift
//  AeroBrowser
//
//  Created by Falsy on 2/6/24.
//

import SwiftUI

struct TabItem: View {
    @ObservedObject var browser: Browser
    @ObservedObject var tab: Tab
    @Binding var activeTabId: UUID?
    @Binding var tabWidth: CGFloat
    
    @State var loadingAnimation: Bool = false
    @State var isTabHover: Bool = false
    
    var isActive: Bool {
        tab.id == activeTabId
    }
    
    var isFavicon: Bool {
        tab.isInit || tab.isSetting || (!tab.isInit && !tab.isSetting && (tab.pageProgress > 0 || tab.favicon != nil))
    }
    
    var body: some View {
        HStack(spacing: 0) {
            if isFavicon {
                Group {
                    if tab.isInit || tab.isSetting {
                        Image("MainLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 14, height: 14)
                            .opacity(isActive ? 0.7 : 0.5)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    } else if tab.pageProgress > 0 && tab.favicon == nil {
                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(Color("Icon").opacity(0.5), lineWidth: 1.5)
                            .frame(width: 12, height: 12)
                            .rotationEffect(Angle(degrees: loadingAnimation ? 360 : 0))
                            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: loadingAnimation)
                    } else if let favicon = tab.favicon {
                        favicon
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 14, height: 14)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }
                }
                .frame(width: 16, height: 16)
                .padding(.leading, tabWidth > 60 ? 6 : 0)
            }
            
            if tabWidth > 60 || tab.favicon == nil {
                Text(tab.title.isEmpty ? tab.printURL : tab.title)
                    .font(.system(size: 11.5))
                    .foregroundColor(Color("UIText").opacity(isActive || isTabHover ? 1 : 0.7))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.leading, isFavicon ? 5 : 8)
                    .padding(.trailing, 20)
                    .frame(maxWidth: 200, alignment: .leading)
            }
        }
        .opacity(tabWidth < 60 && isActive ? 0 : 1)
        .frame(height: 28)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(isTabHover && !isActive ? Color("SearchBarBG").opacity(0.5) : .clear)
        )
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 1)
        .onHover { isTabHover = $0 }
        .onChange(of: tab.pageProgress) { _, nV in
            loadingAnimation = nV > 0
        }
    }
}
