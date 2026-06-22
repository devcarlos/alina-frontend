//
//  Colors.swift
//  AlinaTest
//
//  Design system color tokens. All UI colors must reference
//  these tokens — never use raw hex values or system colors directly.
//

import SwiftUI

// MARK: - Hex Initialiser

extension Color {
    /// Creates a `Color` from a 6-digit hex string (with or without the `#` prefix).
    /// - Parameter hex: e.g. `"#18161F"` or `"18161F"`.
    init(hex: String) {
        let raw = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: raw).scanHexInt64(&value)
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >>  8) & 0xFF) / 255
        let b = Double( value        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Brand Color Tokens

extension Color {

    // MARK: Background

    /// Primary app background  `#18161F`
    static let appBackground = Color(hex: "#18161F")

    // MARK: Brand Gradient

    /// Gradient start — pink  `#B24DCC`
    static let brandPink   = Color(hex: "#B24DCC")

    /// Gradient mid — purple  `#8955F9`
    static let brandPurple = Color(hex: "#8955F9")

    /// Gradient accent — blue  `#5B9EF9`
    static let brandBlue   = Color(hex: "#5B9EF9")

    // MARK: Gradient Palette

    /// Ordered color stops for the rotating brand gradient.
    static let brandGradientColors: [Color] = [
        .brandPink, .brandPurple, .brandBlue, .brandPurple, .brandPink
    ]
}
