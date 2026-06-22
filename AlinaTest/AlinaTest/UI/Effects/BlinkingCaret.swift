//
//  BlinkingCaret.swift
//  AlinaTest
//
//  A thin vertical bar that blinks on a fixed interval using a Swift
//  concurrency task so no Timer or Combine subscription is required.
//
//  Usage:
//    HStack(spacing: 6) {
//        Text(displayAmount)
//        BlinkingCaret(height: 64)
//    }
//

import SwiftUI

struct BlinkingCaret: View {

    /// Height of the caret in points. Should match the cap-height of the
    /// accompanying text at its maximum rendered size.
    var height: CGFloat = 64

    /// Colour of the caret.
    var color: Color = .white.opacity(0.8)

    /// Time in seconds between on/off state changes.
    var interval: TimeInterval = 0.53

    @State private var visible = true

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 3, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 1.5))
            .opacity(visible ? 1 : 0)
            .task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(interval))
                    withAnimation(.easeInOut(duration: 0.08)) {
                        visible.toggle()
                    }
                }
            }
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 6) {
        Text("$2,000")
            .font(.gtFlexa(size: 64))
            .foregroundStyle(Color.white.opacity(0.8))
        BlinkingCaret(height: 60)
    }
    .padding()
    .background(Color.appBackground)
}
