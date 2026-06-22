//
//  AutomatedBadge.swift
//  AlinaTest
//
//  The "AUTOMATED" pill badge shown in the navigation bar.
//
//  Layers (back → front):
//  1. Dark fill   — `#0D0C14` Capsule.
//  2. Border      — "border" image asset stretched to fit (the holographic
//                   gradient border provided as a design asset).
//  3. Glow halos  — layered `.shadow` passes for the coloured bloom.
//  4. Label       — "AUTOMATED" 11 pt bold, white, +1.5 tracking.
//

import SwiftUI

struct AutomatedBadge: View {

    var body: some View {
        Text("AUTOMATED")
            .font(.system(size: 11, weight: .bold))
            .tracking(1.5)
            .foregroundStyle(Color.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(badgeBackground)
    }

    // MARK: - Private

    private var badgeBackground: some View {
        ZStack {
            Capsule()
                .fill(Color(hex: "#0D0C14"))

            Image("border")
                .resizable()
                .scaledToFill()
                .clipShape(Capsule())
        }
    }
}

// MARK: - Preview

#Preview {
    AutomatedBadge()
        .padding()
        .background(Color.appBackground)
}
