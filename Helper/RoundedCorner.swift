//
//  RoundedCorner.swift
//  AeroBrowser
//
//  Created by Kilian Balaguer on 23/06/2025.
//


import SwiftUI

struct RoundedCorner: Shape {
    var radius: CGFloat = 20.0
    var corners: UIRectCorner = [.allCorners]

    func path(in rect: CGRect) -> Path {
        let path = NSBezierPath(roundedRect: rect, byRoundingCorners: corners, radius: radius)
        return Path(path.cgPath)
    }
}

// NSBezierPath extension to get CGPath
extension NSBezierPath {
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [NSPoint](repeating: .zero, count: 3)

        for i in 0..<elementCount {
            switch element(at: i, associatedPoints: &points) {
            case .moveTo: path.move(to: CGPoint(x: points[0].x, y: points[0].y))
            case .lineTo: path.addLine(to: CGPoint(x: points[0].x, y: points[0].y))
            case .curveTo:
                path.addCurve(to: CGPoint(x: points[2].x, y: points[2].y),
                              control1: CGPoint(x: points[0].x, y: points[0].y),
                              control2: CGPoint(x: points[1].x, y: points[1].y))
            case .closePath: path.closeSubpath()
            @unknown default: break
            }
        }

        return path
    }
}
