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
    var blurRadius: Double = 0       // 0–30, frosted glass amount
    var noiseOpacity: Double = 0     // 0–0.5, white noise texture
    var chromeOpacity: Double = 1.0  // 0.3–1.0, gradient layer opacity (lower = more transparent)

    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color(hex: color1Hex), Color(hex: color2Hex)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
