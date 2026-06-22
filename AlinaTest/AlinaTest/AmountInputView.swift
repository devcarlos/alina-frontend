//
//  AmountInputView.swift
//  AlinaTest
//
//  Main investment amount entry screen. Coordinates all sub-components:
//  navigation bar, amount display, middle section (suggestion bubbles ↔
//  review button) and number pad.
//
//  State machine:
//    rawInput.isEmpty  → suggestion bubbles visible, placeholder "$0" shown
//    rawInput non-empty → review button visible, formatted amount shown
//
//  Back button and Review button both call resetInput(), clearing the state.
//

import SwiftUI

struct AmountInputView: View {

    // MARK: - State

    @State private var rawInput: String = ""
    @State private var digitBounce: Bool = false

    // MARK: - Derived

    private var hasDecimal: Bool       { rawInput.contains(".") }
    private var isEmpty: Bool          { rawInput.isEmpty }
    private var isDecimalDisabled: Bool { isEmpty || hasDecimal }
    private var displayAmount: String  { AmountFormatter.format(rawInput) }

    private var suggestions: [(label: String, value: String)] {
        [
            (AmountFormatter.format("500"),   "500"),
            (AmountFormatter.format("2000"),  "2000"),
            (AmountFormatter.format("10000"), "10000")
        ]
    }

    private let numPadRows: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "⌫"]
    ]

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                navigationBar
                    .padding(.top, 8)

                Spacer(minLength: 12)

                amountDisplay
                    .padding(.horizontal, 24)

                Spacer(minLength: 12)

                middleSection
                    .padding(.horizontal, 24)

                numberPad
                    .padding(.top, 24)
                    .padding(.horizontal, 47)
                    .padding(.bottom, 32)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Navigation Bar

    private var navigationBar: some View {
        HStack {
            Button {
                Haptics.impact()
                resetInput()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)

            Spacer()

            AutomatedBadge()

            Spacer()

            // Balances the back button so the badge stays centred
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Amount Display

    private var amountDisplay: some View {
        HStack(alignment: .center, spacing: 6) {
            Text(displayAmount)
                .font(.gtFlexa(size: 100))
                .tracking(100 * -0.02) // −2 % letter-spacing → −2 pt
                .foregroundStyle(
                    isEmpty
                        ? AnyShapeStyle(Color.white.opacity(0.4))
                        : AnyShapeStyle(
                            RadialGradient(
                                colors: [.white, .white.opacity(0.8)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 140
                            )
                        )
                )
                .lineLimit(1)
                .minimumScaleFactor(0.2)
                .contentTransition(.numericText(countsDown: false))
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: displayAmount)
                .scaleEffect(digitBounce ? 1.018 : 1.0)
                .animation(.spring(response: 0.1, dampingFraction: 0.45), value: digitBounce)

            BlinkingCaret(height: 64)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Middle Section (bubbles ↔ review button)

    private var middleSection: some View {
        ZStack {
            if isEmpty {
                suggestionBubbles
                    .transition(bubblesTransition)
            } else {
                ReviewButton { resetInput() }
                    .transition(reviewButtonTransition)
            }
        }
        .animation(.spring(response: 0.38, dampingFraction: 0.78), value: isEmpty)
    }

    private var suggestionBubbles: some View {
        HStack(spacing: 10) {
            ForEach(suggestions, id: \.label) { s in
                SuggestionBubble(label: s.label) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        rawInput = s.value
                    }
                    triggerBounce()
                }
            }
        }
    }

    private var bubblesTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity
                .combined(with: .scale(scale: 0.88, anchor: .bottom))
                .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.04)),
            removal: .opacity
                .combined(with: .scale(scale: 0.82, anchor: .bottom))
                .animation(.spring(response: 0.28, dampingFraction: 0.8))
        )
    }

    private var reviewButtonTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity
                .combined(with: .scale(scale: 0.94, anchor: .center))
                .animation(.spring(response: 0.4, dampingFraction: 0.75).delay(0.04)),
            removal: .opacity
                .combined(with: .scale(scale: 0.90, anchor: .center))
                .animation(.spring(response: 0.28, dampingFraction: 0.8))
        )
    }

    // MARK: - Number Pad

    private var numberPad: some View {
        VStack(spacing: 0) {
            ForEach(numPadRows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(row, id: \.self) { key in
                        NumPadKey(
                            key: key,
                            isDisabled: key == "." && isDecimalDisabled
                        ) { pressed in
                            handleKey(pressed)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Key Handling

    private func handleKey(_ key: String) {
        // Haptic is already fired by NumPadKey before this is called
        switch key {
        case "⌫":
            guard !rawInput.isEmpty else { return }
            rawInput.removeLast()

        case ".":
            guard !isEmpty, !hasDecimal else { return }
            rawInput += "."

        default:
            // Cap at 2 decimal places
            if hasDecimal {
                let fraction = rawInput.components(separatedBy: ".").last ?? ""
                guard fraction.count < 2 else { return }
            }
            rawInput += key
        }

        triggerBounce()
    }

    // MARK: - Helpers

    /// Momentarily scales the amount display to give tactile feedback.
    private func triggerBounce() {
        digitBounce = true
        Task {
            try? await Task.sleep(for: .milliseconds(110))
            digitBounce = false
        }
    }

    /// Clears the input with a spring animation (used by back button + review button).
    private func resetInput() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            rawInput = ""
        }
    }
}

// MARK: - Preview

#Preview {
    AmountInputView()
}
