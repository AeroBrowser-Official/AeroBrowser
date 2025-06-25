//
//  Theme.swift
//  AeroBrowser
//
//  Created by Kilian Balaguer on 23/06/2025.
//


import SwiftUI

enum Theme: String, CaseIterable {
    case bluePurple = "Blue & Purple"
    case greenYellow = "Green & Yellow"
    case redOrange = "Red & Orange"
    
    var gradient: LinearGradient {
        switch self {
        case .bluePurple:
            return LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .top, endPoint: .bottom)
        case .greenYellow:
            return LinearGradient(gradient: Gradient(colors: [Color.green, Color.yellow]), startPoint: .top, endPoint: .bottom)
        case .redOrange:
            return LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]), startPoint: .top, endPoint: .bottom)
        }
    }
}
