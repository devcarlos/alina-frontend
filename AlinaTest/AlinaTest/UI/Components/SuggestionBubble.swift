//
//  SuggestionBubble.swift
//  AlinaTest
//
//  A tappable neumorphic pill button showing a preset investment amount.
//  Bubbles are only visible when the user has not entered any digits.
//
//  Visual layers (back → front):
//  1. Outer drop-shadow — black, offset downward for depth.
//  2. Dark fill — `#23212C` at 75 % opacity.
//  3. Gradient stroke — bright white highlight at top fading to near-black at
//     bottom, mimicking a specular light source above the pill.
//
//  Usage:
//    SuggestionBubble(label: "$2,000") { rawInput = "2000" }
//

import SwiftUI

struct SuggestionBubble: View {

    let label: String
    let action: () -> Void

    // Corner radius large enough to give the near-stadium look in the design.
    private static let cornerRadius: CGFloat = 44

    var body: some View {
        Button {
            Haptics.impact()
            action()
        } label: {
            Text(label)
                .font(.instrumentSans(size: 17))
                .foregroundStyle(Color.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 20)
                .background(bubbleBackground)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Private

    private var bubbleBackground: some View {
        ZStack {
            // Filled shape
            RoundedRectangle(cornerRadius: Self.cornerRadius)
                .fill(Color(hex: "#23212C").opacity(0.75))

            // Gradient border: bright top highlight → dark bottom shadow
            RoundedRectangle(cornerRadius: Self.cornerRadius)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.55),  // top specular highlight
                            Color.white.opacity(0.12),  // upper quarter fade
                            Color.clear,                // mid — invisible
                            Color.black.opacity(0.25),  // lower shadow
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1.5
                )
        }
        // Outer depth shadow
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 5)
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 12) {
        SuggestionBubble(label: "$500")    {}
        SuggestionBubble(label: "$2,000")  {}
        SuggestionBubble(label: "$10,000") {}
    }
    .padding()
    .background(Color.appBackground)
}
