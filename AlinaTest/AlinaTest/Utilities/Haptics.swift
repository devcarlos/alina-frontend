//
//  Haptics.swift
//  AlinaTest
//
//  Centralised haptic feedback helpers. All interactive taps call
//  Haptics.impact() so feedback style can be tuned from a single place.
//

#if canImport(UIKit)
import UIKit
#endif

enum Haptics {

    /// Light impact feedback. Used for every keypad and bubble tap.
    static func impact() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }

    /// Medium impact feedback. Available for heavier confirmations if needed.
    static func mediumImpact() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
    }
}
