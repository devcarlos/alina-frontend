//
//  Typography.swift
//  AlinaTest
//
//  Design system font tokens. Fonts are registered at launch by FontLoader.
//  Use these helpers instead of calling Font.custom(_:size:) directly.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Font PostScript Names

enum AlinaFont {
    /// GT Flexa Condensed Medium — PostScript name confirmed from the OTF file.
    /// Used for the main amount display.
    static let gtFlexa = "GTFlexa-CnMd"

    /// Instrument Sans SemiCondensed Medium — PostScript name confirmed from the OTF file.
    /// Used for suggestion bubble labels.
    static let instrumentSans = "InstrumentSansSemiCondensed-Medium"
}

// MARK: - Font Helpers

extension Font {
    /// GT Flexa Condensed Medium at the given point size.
    /// Falls back to the system font if the custom font failed to load.
    static func gtFlexa(size: CGFloat) -> Font {
        .custom(AlinaFont.gtFlexa, size: size)
    }

    /// Instrument Sans SemiCondensed Medium at the given point size.
    /// Falls back to the system font if the custom font failed to load.
    static func instrumentSans(size: CGFloat) -> Font {
        .custom(AlinaFont.instrumentSans, size: size)
    }

    /// SF Pro at Figma-specified weight 510 (between medium 500 and semibold 600)
    /// and 36.65 pt — used for all number-pad keys.
    /// Bridges through UIFont so the exact weight value is honoured.
    static var numPadKey: Font {
        #if canImport(UIKit)
        // UIFont.Weight raw values: medium ≈ 0.23, semibold ≈ 0.30.
        // Weight 510 interpolates to ≈ 0.237.
        return Font(UIFont.systemFont(ofSize: 36.65, weight: UIFont.Weight(rawValue: 0.237)))
        #else
        return .system(size: 36.65, weight: .medium)
        #endif
    }
}
