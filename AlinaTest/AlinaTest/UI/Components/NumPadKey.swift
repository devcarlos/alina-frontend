//
//  NumPadKey.swift
//  AlinaTest
//
//  A single key in the custom number pad.
//
//  • Digit keys (1–9, 0): SF Pro Medium 34 pt, white.
//  • Decimal key (.):     SF Pro Medium 30 pt, white (dimmed when disabled).
//  • Delete key (⌫):     SF symbols `delete.left`, white at 75 % opacity.
//
//  Every tap fires light haptic feedback before calling the `onPress` handler.
//  The parent is responsible for ignoring presses that should be no-ops (e.g.
//  preventing a second decimal point) — this view only handles the disabled
//  state visually via `isDisabled`.
//

import SwiftUI

struct NumPadKey: View {

    let key: String
    var isDisabled: Bool = false
    let onPress: (String) -> Void

    var body: some View {
        Button {
            Haptics.impact()
            onPress(key)
        } label: {
            keyLabel
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }

    // MARK: - Key Label

    @ViewBuilder
    private var keyLabel: some View {
        switch key {
        case "⌫":
            Image(systemName: "delete.left.fill")
                .font(.numPadKey)
                .foregroundStyle(Color(hex: "#2E2C32"))

        case ".":
            Text(AmountFormatter.decimalSeparator)
                .font(.numPadKey)
                .foregroundStyle(Color.white.opacity(isDisabled ? 0.2 : 1.0))

        default:
            Text(key)
                .font(.numPadKey)
                .foregroundStyle(Color.white)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 0) {
        HStack(spacing: 0) {
            NumPadKey(key: "1") { _ in }
            NumPadKey(key: "2") { _ in }
            NumPadKey(key: "3") { _ in }
        }
        HStack(spacing: 0) {
            NumPadKey(key: ".", isDisabled: true) { _ in }
            NumPadKey(key: "0") { _ in }
            NumPadKey(key: "⌫") { _ in }
        }
    }
    .background(Color.appBackground)
}
