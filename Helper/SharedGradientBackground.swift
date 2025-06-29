//
//  SharedGradientBackground.swift
//  AeroBrowser
//
//  Created by Kilian Balaguer on 23/06/2025.
//


import SwiftUI

struct SharedGradientBackground: View {
    @ObservedObject var browser: Browser


    var offset: CGFloat

    var body: some View {
        let theme = browser.theme
                let gradient = theme == .custom
                ? theme.gradient(customColor1: browser.customColor1, customColor2: browser.customColor2, CustomRotation: browser.customPosition)
                    : theme.gradient()

                gradient
                    .frame(height: 2000)
            .offset(y: offset)
            .clipped()
    }
}
