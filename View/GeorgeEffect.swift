//
//  GeorgeEffect.swift
//  AeroBrowser
//
//  Created by Kilian Balaguer on 29/06/2025.
//


import AnimateText
import SwiftUI

struct GeorgeEffect: ATTextAnimateEffect {
    var data: ATElementData
    var userInfo: Any?

    init(_ data: ATElementData, _ userInfo: Any?) {
        self.data = data
        self.userInfo = userInfo
    }

    func body(content: Content) -> some View {
        content
            .opacity(data.value)
            .offset(y: -10)
            .animation(.interpolatingSpring(stiffness: 90, damping: 9).delay(Double(data.index) * 0.04), value: data.value)
    }
}
