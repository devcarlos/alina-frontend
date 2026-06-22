//
//  AnimatedGradientBorder.swift
//  AlinaTest
//
//  A `ViewModifier` that overlays an infinitely-rotating angular gradient
//  stroke on any SwiftUI view. Works with any `Shape` — use `Capsule()` for
//  the AUTOMATED badge and `RoundedRectangle(cornerRadius:)` for pill buttons.
//
//  Usage:
//    Text("AUTOMATED")
//        .padding(...)
//        .animatedGradientBorder(shape: Capsule(), lineWidth: 1, duration: 4)
//
//    RoundedRectangle(cornerRadius: 50)
//        .fill(Color.white)
//        .animatedGradientBorder(shape: RoundedRectangle(cornerRadius: 50))
//

import SwiftUI

// MARK: - Modifier

struct AnimatedGradientBorderModifier<S: Shape>: ViewModifier {

    let shape: S
    var lineWidth: CGFloat = 1.5
    var duration: Double = 3.0
    var colors: [Color] = Color.brandGradientColors

    @State private var angle: Double = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                shape.stroke(
                    AngularGradient(
                        colors: colors,
                        center: .center,
                        angle: .degrees(angle)
                    ),
                    lineWidth: lineWidth
                )
            )
            .onAppear {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    angle = 360
                }
            }
    }
}

// MARK: - View Extension

extension View {
    /// Overlays an infinitely-rotating brand gradient border using the provided shape.
    ///
    /// - Parameters:
    ///   - shape: The `Shape` used for the stroke (e.g. `Capsule()`, `RoundedRectangle(cornerRadius: 50)`).
    ///   - lineWidth: Stroke thickness in points. Default `1.5`.
    ///   - duration: Seconds for one full 360° rotation. Default `3.0`.
    func animatedGradientBorder<S: Shape>(
        shape: S,
        lineWidth: CGFloat = 1.5,
        duration: Double = 3.0
    ) -> some View {
        modifier(
            AnimatedGradientBorderModifier(
                shape: shape,
                lineWidth: lineWidth,
                duration: duration
            )
        )
    }
}

// MARK: - Preview

#Preview("Capsule") {
    Text("AUTOMATED")
        .font(.system(size: 11, weight: .medium))
        .tracking(0.8)
        .foregroundStyle(Color.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color.white.opacity(0.05)))
        .animatedGradientBorder(shape: Capsule(), lineWidth: 1, duration: 4)
        .padding()
        .background(Color.appBackground)
}

#Preview("Pill") {
    Color.white
        .frame(width: 280, height: 50)
        .clipShape(RoundedRectangle(cornerRadius: 50))
        .animatedGradientBorder(shape: RoundedRectangle(cornerRadius: 50))
        .padding()
        .background(Color.appBackground)
}
