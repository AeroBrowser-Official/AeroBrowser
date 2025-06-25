//
//  SharedGradientBackground.swift
//  AeroBrowser
//
//  Created by Kilian Balaguer on 23/06/2025.
//


import SwiftUI

struct SharedGradientBackground: View {
    @AppStorage("selectedTheme") private var selectedTheme: String = Theme.bluePurple.rawValue
    private var currentTheme: Theme {
        Theme(rawValue: selectedTheme) ?? .bluePurple
    }

    var offset: CGFloat

    var body: some View {
        currentTheme.gradient
            .frame(height: 2000) // large height so both views can pull from it
            .offset(y: offset)
            .clipped()
    }
}
