# AlinaTest

An iOS prototype for Alinea Invest's investment amount entry screen. The user types a dollar amount via a custom number pad, picks from preset suggestion bubbles, and confirms with an animated Review button.

---

## Preview

https://github.com/user-attachments/assets/4c698aa9-b6d9-4eb7-970c-276e7c14d997


---

## Requirements

| Tool | Version |
|------|---------|
| Xcode | 26.5+ |
| iOS deployment target | 26.5+ |
| Swift | 6 |

> Open `AlinaTest.xcodeproj` — the project uses `PBXFileSystemSynchronizedRootGroup`, so Xcode auto-discovers every file in the `AlinaTest/` directory. No manual file registration is required.

---

## Features

| # | Feature | Implementation |
|---|---------|----------------|
| 1 | **Suggestion bubbles** visible only when input is empty | `ZStack` + `if isEmpty` with asymmetric spring transition |
| 2 | **AUTOMATED badge** with animatable holographic border | `BadgeBorderStyle` enum: `.normal` (static asset), `.animated` (SwiftUI brightness + hue rotation), `.metalShader` (Metal `holoBorder` shader) |
| 3 | **Review button** with animated neon glow + gradient border | 5-layer `ZStack`: gradient glow → gradient border → white glow → white pill → label |
| 4 | **Bubbles → Review button transition** | Asymmetric `.scale` + `.opacity` spring transitions |
| 5 | **Haptic feedback** on every keypad and bubble tap | `UIImpactFeedbackGenerator(.light)` via `Haptics.impact()` |
| 6 | **Blinking caret** always at end of input | `BlinkingCaret` using Swift concurrency `Task.sleep` loop |
| 7 | **Decimal disabled** when inappropriate | Disabled when `isEmpty` or already has a decimal point |
| 8 | **Text scales to fit** when amount is large | `.minimumScaleFactor(0.2)` + `.lineLimit(1)` |
| 9 | **Digit animation** on each key press | `.contentTransition(.numericText())` + spring `scaleEffect` bounce |
| 10 | **Locale-aware currency** formatting | `NumberFormatter` with `Locale.current` for symbol + grouping |
| 11 | **Back + Review reset state** | Both call `resetInput()` with spring animation |

---

## Project Structure

```
AlinaTest/AlinaTest/
│
├── DesignSystem/
│   ├── Colors.swift          # Color tokens + Color(hex:) initializer
│   └── Typography.swift      # Font PostScript names + Font extension helpers
│
├── UI/
│   ├── Components/
│   │   ├── AutomatedBadge.swift   # Nav bar pill: BadgeBorderStyle enum (normal / animated / metalShader)
│   │   ├── SuggestionBubble.swift # Preset amount bubbles ($500 / $2,000 / $10,000)
│   │   ├── ReviewButton.swift     # 5-layer animated CTA button
│   │   └── NumPadKey.swift        # Individual number-pad key (digit / decimal / delete)
│   └── Effects/
│       ├── BlinkingCaret.swift         # Async blinking cursor view
│       └── AnimatedGradientBorder.swift # Generic rotating-gradient stroke ViewModifier
│
├── Shaders/
│   └── HoloBorder.metal       # Stitchable Metal shader — holographic rotating border (BadgeBorderStyle.metalShader)
│
├── Utilities/
│   ├── Haptics.swift          # UIImpactFeedbackGenerator wrapper
│   └── AmountFormatter.swift  # Raw-string → locale currency string conversion
│
├── Fonts/
│   ├── GTFlexa-CnMd.otf                     # GT Flexa Condensed Medium
│   └── InstrumentSansSemiCondensed-Medium.otf
│
├── Assets.xcassets/
│   └── border.imageset/       # Holographic gradient border pill for AutomatedBadge
│
├── FontLoader.swift           # Registers custom OTF fonts via CoreText at launch
├── AmountInputView.swift      # Main screen — orchestrates all components
├── ContentView.swift          # Entry point → AmountInputView
└── AlinaTestApp.swift         # @main — calls FontLoader.loadFonts() in init

AppIcon.svg                    # 1024×1024 "A" lettermark for IconComposer (project root)
```

---

## Design System

### Colors (`DesignSystem/Colors.swift`)

| Token | Hex | Usage |
|-------|-----|-------|
| `Color.appBackground` | `#18161F` | Full-screen background |
| `Color.brandPink` | `#B24DCC` | Gradient start |
| `Color.brandPurple` | `#8955F9` | Gradient mid |
| `Color.brandBlue` | `#5B9EF9` | Gradient accent |

`Color(hex:)` is available as an extension — accepts 6-digit hex strings with or without `#`.

### Typography (`DesignSystem/Typography.swift`)

| Helper | Font | Usage |
|--------|------|-------|
| `Font.gtFlexa(size:)` | GT Flexa Condensed Medium (`GTFlexa-CnMd`) | Amount display (100 pt) · Review label (24 pt) |
| `Font.instrumentSans(size:)` | Instrument Sans SemiCondensed Medium | Suggestion bubble labels |
| `Font.numPadKey` | SF Pro weight 510 via `UIFont` bridge | All number-pad keys (digits, decimal, delete) |

Fonts are loaded at app launch via `FontLoader.loadFonts()` using `CTFontManagerRegisterFontsForURL`. No `UIAppFonts` Info.plist entry required.

---

## Key Implementation Notes

### AUTOMATED Badge — `BadgeBorderStyle` Enum

`AutomatedBadge` exposes a `borderStyle` parameter that selects one of three rendering paths. Default is `.animated`.

```swift
enum BadgeBorderStyle {
    /// Static "border" image asset — no animation.
    case normal
    /// Image asset animated with SwiftUI brightness + hue rotation.
    case animated
    /// Image asset with per-pixel brightness modulation via Metal shader.
    case metalShader
}
```

| Style | Rendering |
|-------|-----------|
| `.normal` | `Image("border")` clipped to `Capsule` — static |
| `.animated` | Same image + `TimelineView(.animation)` driving `.brightness(0.4 * sin(t * 2.5))` and `.hueRotation(.degrees(sin(t * 0.8) * 40))` |
| `.metalShader` | Same image + `.drawingGroup()` + `.colorEffect(ShaderLibrary.holoBorder(...))` |

```swift
// Three previews provided:
#Preview("Normal")       { AutomatedBadge(borderStyle: .normal) }
#Preview("Animated")     { AutomatedBadge(borderStyle: .animated) }
#Preview("Metal Shader") { AutomatedBadge(borderStyle: .metalShader) }
```

Badge padding: `.horizontal 14`, `.vertical 14`.

### Metal Holographic Border Shader (`Shaders/HoloBorder.metal`)

Used by `BadgeBorderStyle.metalShader`. A `[[ stitchable ]]` fragment shader applied via `.colorEffect` (requires `.drawingGroup()` first to rasterize the image into a pixel buffer). Rather than a horizontal UV sweep, it computes each pixel's angle from the view centre via `atan2` and uses that as the gradient coordinate, producing a clockwise rotation effect around the perimeter.

Effects: deep brightness wave → fast shimmer overlay → two travelling glints (one clockwise, one counter-clockwise).

```metal
float aT = fract(angle / (2.0f * M_PI_F));
float wave = 0.30f + 0.70f * (0.5f + 0.5f * sin(aT * 6.28318f - time * 2.5f));
```

Applied in SwiftUI:
```swift
Image("border")
    .resizable()
    .scaledToFill()
    .clipShape(Capsule())
    .drawingGroup()   // rasterise before colorEffect
    .colorEffect(ShaderLibrary.holoBorder(
        .float2(badgeSize.width, badgeSize.height),
        .float(t)
    ))
```

> **Note**: Dynamic array indexing (`stops[i]`) inside `[[ stitchable ]]` shaders causes a silent compile failure (white output). Use `if/else` chains instead.

### Review Button — 5-Layer Stack

`ReviewButton` uses five stacked layers (back → front) to produce the neon pill effect. `pillHeight = 50`, `borderInset = 2`, total `ZStack` height = 54.

| Layer | View | Purpose |
|-------|------|---------|
| 1 | Blurred `AngularGradient` Capsule | Wide neon bloom behind the button; `scaleEffect(y: 1.5)`, `blur(26)`, `offset(y: 10)` |
| 2 | `AngularGradient` Capsule + `.padding(.horizontal, borderInset)` | Thin coloured border peeking out 2 pt top/bottom, same width as white pill |
| 3 | Blurred white Capsule | Inner white halo brightening pill edges; `blur(8)`, `opacity(0.55)` |
| 4 | Solid white Capsule | The pill surface |
| 5 | `Text("Review")` | GT Flexa Condensed Medium 24 pt, −3% tracking |

A single `angle: Double` state drives both gradient layers with `.linear(duration: 3).repeatForever(autoreverses: false)`, so the pink → purple → blue colours sweep around the perimeter in sync.

### Amount Formatting

`AmountFormatter` stores input as a raw digit string using `.` as the internal decimal separator, then formats for display using `NumberFormatter` with `Locale.current`. This localises the currency symbol, grouping separator, and decimal separator automatically.

### Blinking Caret

`BlinkingCaret` uses a Swift concurrency `Task.sleep` loop — no Timer or Combine required. Opacity toggles with a fast `.easeInOut(duration: 0.08)` for a sharp blink.

### Digit Animation

Two animation layers fire on each key press:
1. `.contentTransition(.numericText(countsDown: false))` — smooth number morphing.
2. `scaleEffect(digitBounce ? 1.018 : 1.0)` with a spring — resets after 110 ms via `Task.sleep`.

### Decimal Button Logic

```
isDecimalDisabled = rawInput.isEmpty || rawInput.contains(".")
```

Disabled when no digits exist yet, or when a decimal point is already present. Max 2 fractional digits enforced in `handleKey`.

---

## Build & Run

```bash
open AlinaTest/AlinaTest.xcodeproj
```

Select the **AlinaTest** scheme, choose an iPhone simulator (iOS 26.5), and press **⌘R**.

> **SourceKit diagnostics**: When files are added outside Xcode, SourceKit shows "Cannot find X in scope" until the project is re-indexed. These are false positives — the build succeeds because all symbols live in the same module. Open the project in Xcode and the warnings clear automatically.

---

## Dark Mode

The app is dark-mode only. `AmountInputView` applies `.preferredColorScheme(.dark)` at the root so system appearance has no effect.
