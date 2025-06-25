//
//  CustomTheme.swift
//  AeroBrowser
//
//  Created by Kilian Balaguer on 25/06/2025.
//


import SwiftUI

struct CustomTheme: Codable, Identifiable {
    var id: UUID
    var name: String
    var color1Hex: String
    var color2Hex: String

    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color(hex: color1Hex), Color(hex: color2Hex)]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
