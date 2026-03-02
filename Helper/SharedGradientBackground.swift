//
//  SharedGradientBackground.swift
//  AeroBrowser
//
//  Created by Kilian Balaguer on 23/06/2025.
//


import SwiftUI

struct SharedGradientBackground: View {
    @AppStorage("selectedTheme") private var selectedTheme: String = Theme.bluePurple.rawValue
    @AppStorage("customThemes") private var customThemesData: Data = Data()

    private var currentGradient: LinearGradient {
        // Built-in match
        if let theme = Theme.allCases.first(where: { $0.rawValue == selectedTheme }) {
            return theme.gradient
        }
        // Custom UUID match
        if let uuid = UUID(uuidString: selectedTheme),
           let customThemes = try? JSONDecoder().decode([CustomTheme].self, from: customThemesData),
           let matched = customThemes.first(where: { $0.id == uuid }) {
            return matched.gradient
        }
        return Theme.bluePurple.gradient
    }

    var offset: CGFloat

    var body: some View {
        currentGradient
            .frame(height: 2000) // large height so both views can pull from it
            .offset(y: offset)
            .clipped()
    }
}
