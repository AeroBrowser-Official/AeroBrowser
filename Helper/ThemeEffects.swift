//
//  ThemeEffects.swift
//  AeroBrowser
//
//  Created by AeroBrowser on 2/28/26.
//

import SwiftUI

/// Central resolver for the current theme's visual effects.
/// Built-in themes have default effects; custom themes store their own.
struct ThemeEffects {
    let gradient: LinearGradient
    let blurRadius: Double
    let noiseOpacity: Double
    let chromeOpacity: Double
    
    /// Resolve the current theme effects from AppStorage values.
    static func resolve(
        selectedTheme: String,
        customThemesData: Data
    ) -> ThemeEffects {
        // Built-in theme match
        if let theme = Theme.allCases.first(where: { $0.rawValue == selectedTheme }) {
            return ThemeEffects(
                gradient: theme.gradient,
                blurRadius: 0,
                noiseOpacity: 0,
                chromeOpacity: 1.0
            )
        }
        
        // Custom theme match
        if let uuid = UUID(uuidString: selectedTheme),
           let customThemes = try? JSONDecoder().decode([CustomTheme].self, from: customThemesData),
           let matched = customThemes.first(where: { $0.id == uuid }) {
            return ThemeEffects(
                gradient: matched.gradient,
                blurRadius: matched.blurRadius,
                noiseOpacity: matched.noiseOpacity,
                chromeOpacity: matched.chromeOpacity
            )
        }
        
        return ThemeEffects(
            gradient: Theme.bluePurple.gradient,
            blurRadius: 0,
            noiseOpacity: 0,
            chromeOpacity: 1.0
        )
    }
}

/// A white-noise texture view drawn with Canvas
struct NoiseTexture: View {
    let opacity: Double
    
    var body: some View {
        if opacity > 0.001 {
            Canvas { context, size in
                let step = 4
                for x in stride(from: 0, to: Int(size.width), by: step) {
                    for y in stride(from: 0, to: Int(size.height), by: step) {
                        let brightness = Double.random(in: 0...1)
                        let color = Color.white.opacity(brightness * opacity)
                        context.fill(
                            Path(CGRect(x: x, y: y, width: step, height: step)),
                            with: .color(color)
                        )
                    }
                }
            }
            .allowsHitTesting(false)
            .drawingGroup()
        }
    }
}
