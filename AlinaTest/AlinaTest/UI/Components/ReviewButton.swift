//
//  ReviewButton.swift
//  AlinaTest
//
//  The "Review" call-to-action button.
//
//  Layers (back → front):
//  1. Gradient glow   — AngularGradient Capsule, heavily blurred + offset down,
//                       creates the wide neon bloom around the gradient border.
//  2. Gradient border — AngularGradient Capsule (pillHeight + 4 pt). The white
//                       pill sits 2 pt inset, exposing the gradient as a thin
//                       coloured border wrapping all edges and corners.
//  3. White glow      — White Capsule, soft blur, sits just behind the white
//                       pill to create a bright inner halo at the pill edges.
//  4. White fill      — Solid white Capsule, 2 pt inset on all sides.
//  5. "Review" label  — GT Flexa Condensed Medium 24 pt, −3 % tracking, black.
//
//  A single `angle` state drives the two AngularGradient layers in sync.
//

import SwiftUI

struct ReviewButton: View {

    let action: () -> Void

    /// Height of the visible white pill (Figma: 50 px).
    private static let pillHeight: CGFloat = 50
    /// How many points of gradient border show around the white pill (all 4 edges).
    private static let borderInset: CGFloat = 2

    @State private var angle: Double = 0

    private let gradientColors: [Color] = [
        Color(hex: "#B24DCC"),   // brand pink
        Color(hex: "#8955F9"),   // brand purple
        Color(hex: "#5B9EF9"),   // brand blue
        Color(hex: "#8955F9"),   // brand purple
        Color(hex: "#B24DCC"),   // wraps back to pink
    ]

    // MARK: - Body

    var body: some View {
        Button {
            Haptics.impact()
            action()
        } label: {
            ZStack {
                gradientGlow
                gradientBorderCapsule
                whiteGlow
                whitePill
                reviewLabel
            }
            .frame(maxWidth: .infinity)
            .frame(height: Self.pillHeight + Self.borderInset * 2)
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                angle = 360
            }
        }
    }

    // MARK: - Sub-views

    /// Wide blurred gradient bloom — the coloured neon halo behind the button.
    private var gradientGlow: some View {
        Capsule()
            .fill(
                AngularGradient(
                    colors: gradientColors,
                    center: .center,
                    angle: .degrees(angle)
                )
            )
            .scaleEffect(x: 1.0, y: 1.5)
            .blur(radius: 26)
            .opacity(0.9)
            .offset(y: 10)
            .allowsHitTesting(false)
    }

    /// Gradient-filled Capsule that peeks out as a thin border around the white pill.
    /// Same horizontal width as the white pill — border only visible top/bottom
    /// and wrapping the corners, not bleeding beyond the pill's left/right edges.
    private var gradientBorderCapsule: some View {
        Capsule()
            .fill(
                AngularGradient(
                    colors: gradientColors,
                    center: .center,
                    angle: .degrees(angle)
                )
            )
            .padding(.horizontal, Self.borderInset)
    }

    /// Soft white halo just behind the white pill — brightens the inner edge of the border.
    private var whiteGlow: some View {
        Capsule()
            .fill(Color.white)
            .frame(height: Self.pillHeight)
            .padding(.horizontal, Self.borderInset)
            .blur(radius: 8)
            .opacity(0.55)
            .allowsHitTesting(false)
    }

    /// Solid white pill — sits 2 pt inset on all sides, exposing the gradient border.
    private var whitePill: some View {
        Capsule()
            .fill(Color.white)
            .frame(height: Self.pillHeight)
            .padding(.horizontal, Self.borderInset)
    }

    /// "Review" text — GT Flexa Condensed Medium 24 pt, −3 % letter-spacing.
    private var reviewLabel: some View {
        Text("Review")
            .font(.gtFlexa(size: 24))
            .tracking(24 * -0.03)
            .foregroundStyle(Color.black)
    }
}

// MARK: - Preview

#Preview {
    ReviewButton {}
        .padding(.horizontal, 24)
        .background(Color.appBackground)
}
