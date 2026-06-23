//
//  AutomatedBadge.swift
//  AlinaTest
//
//  The "AUTOMATED" pill badge shown in the navigation bar.
//
//  Layers (back → front):
//  1. Dark fill  — `#0D0C14` Capsule.
//  2. Border     — controlled by `BorderStyle`:
//       .normal      plain "border" image asset, no animation.
//       .animated    image asset + SwiftUI brightness pulse & hue rotation.
//       .metalShader image asset + Metal `holoBorder` colorEffect shader.
//  3. Label      — "AUTOMATED" 11 pt bold, white, +1.5 tracking.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Border Style

enum BadgeBorderStyle {
    /// Static "border" image asset — no animation.
    case normal
    /// Image asset animated with SwiftUI brightness + hue rotation.
    case animated
    /// Image asset with per-pixel brightness modulation via Metal shader.
    case metalShader
}

// MARK: - View

struct AutomatedBadge: View {

    var borderStyle: BadgeBorderStyle = .normal

    @State private var badgeSize: CGSize = .zero

    var body: some View {
        Text("AUTOMATED")
            .font(.system(size: 16, weight: .heavy))
            .tracking(2.0)
            .foregroundStyle(Color.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 7)
            .background(badgeBackground)
            .onGeometryChange(for: CGSize.self, of: \.size) { badgeSize = $0 }
    }

    // MARK: - Private

    private var badgeBackground: some View {
        ZStack {
            Capsule()
                .fill(Color(hex: "#0D0C14"))

            borderOverlay
        }
    }

    @ViewBuilder
    private var borderOverlay: some View {
        switch borderStyle {

        case .normal:
            Image("border")
                .resizable()
                .scaledToFill()
                .clipShape(Capsule())

        case .animated:
            TimelineView(.animation) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate
                Image("border")
                    .resizable()
                    .scaledToFill()
                    .clipShape(Capsule())
                    .brightness(0.4 * sin(t * 2.5))
                    .hueRotation(.degrees(sin(t * 0.8) * 40))
            }

        case .metalShader:
            TimelineView(.animation) { tl in
                let t = Float(tl.date.timeIntervalSinceReferenceDate)
                Image("border")
                    .resizable()
                    .scaledToFill()
                    .clipShape(Capsule())
                    .drawingGroup()
                    .colorEffect(
                        ShaderLibrary.holoBorder(
                            .float2(badgeSize.width, badgeSize.height),
                            .float(t)
                        )
                    )
            }
        }
    }
}

// MARK: - Preview

#Preview("Normal") {
    AutomatedBadge(borderStyle: .normal)
        .padding()
        .background(Color.appBackground)
}

#Preview("Animated") {
    AutomatedBadge(borderStyle: .animated)
        .padding()
        .background(Color.appBackground)
}

#Preview("Metal Shader") {
    AutomatedBadge(borderStyle: .metalShader)
        .padding()
        .background(Color.appBackground)
}
