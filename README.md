# AlinaTest

An iOS prototype for Alinea Invest's investment amount entry screen. The user types a dollar amount via a custom number pad, picks from preset suggestion bubbles, and confirms with an animated Review button.

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
| 2 | **Animated gradient border** on AUTOMATED badge + Review button | Rotating `AngularGradient` via `AnimatedGradientBorderModifier` |
| 3 | **Bubbles → Review button transition** | Asymmetric `.scale` + `.opacity` spring transitions |
| 4 | **Haptic feedback** on every keypad and bubble tap | `UIImpactFeedbackGenerator(.light)` via `Haptics.impact()` |
| 5 | **Blinking caret** always at end of input | `BlinkingCaret` using Swift concurrency `task {}` loop |
| 6 | **Decimal disabled** when inappropriate | Disabled when `isEmpty` or already has a decimal point |
| 7 | **Text scales to fit** when amount is large | `.minimumScaleFactor(0.2)` + `.lineLimit(1)` |
| 8 | **Digit animation** on each key press | `.contentTransition(.numericText())` + spring `scaleEffect` bounce |
| 9 | **Locale-aware currency** formatting | `NumberFormatter` with `Locale.current` for symbol + grouping |
| 10 | **Back + Review reset state** | Both call `resetInput()` with spring animation |

---

## Project Structure

```
AlinaTest/AlinaTest/
│
├── DesignSystem/
│   ├── Colors.swift          # Color tokens (appBackground, brandPink, brandPurple, brandBlue)
│   └── Typography.swift      # Font PostScript names + Font extension helpers
│
├── UI/
│   ├── Components/
│   │   ├── AutomatedBadge.swift   # "AUTOMATED" pill badge in the nav bar
│   │   ├── SuggestionBubble.swift # Preset amount pill buttons ($500 / $2,000 / $10,000)
│   │   ├── ReviewButton.swift     # Animated CTA using the `review` image asset
│   │   └── NumPadKey.swift        # Individual number-pad key (digit / decimal / delete)
│   └── Effects/
│       ├── BlinkingCaret.swift         # Async blinking cursor view
│       └── AnimatedGradientBorder.swift # ViewModifier + View extension for rotating gradient stroke
│
├── Utilities/
│   ├── Haptics.swift          # UIImpactFeedbackGenerator wrapper
│   └── AmountFormatter.swift  # Raw-string → locale currency string conversion
│
├── Fonts/
│   ├── GTFlexa-CnMd.otf
│   └── InstrumentSansSemiCondensed-Medium.otf
│
├── Assets.xcassets/
│   ├── automated.imageset/   # Gradient border pill (used as texture in AutomatedBadge)
│   └── review.imageset/      # White pill + glow background (used in ReviewButton)
│
├── FontLoader.swift           # Registers custom OTF fonts via CoreText at launch
├── AmountInputView.swift      # Main screen — orchestrates all components
├── ContentView.swift          # Entry point → AmountInputView
└── AlinaTestApp.swift         # @main — calls FontLoader.loadFonts() in init
```

---

## Design System

### Colors (`DesignSystem/Colors.swift`)

| Token | Hex | Usage |
|-------|-----|-------|
| `Color.appBackground` | `#18161F` | Full-screen background |
| `Color.brandPink` | `#B24DCC` | Gradient start / AUTOMATED badge |
| `Color.brandPurple` | `#8955F9` | Gradient mid / Review button border |
| `Color.brandBlue` | `#5B9EF9` | Gradient accent stop |
| `Color.brandGradientColors` | — | Ordered `[Color]` array for `AngularGradient` |

### Typography (`DesignSystem/Typography.swift`)

| Helper | PostScript Name | File | Usage |
|--------|----------------|------|-------|
| `Font.gtFlexa(size:)` | `GTFlexa-CnMd` | `GTFlexa-CnMd.otf` | Main amount display (96 pt, scales down) |
| `Font.instrumentSans(size:)` | `InstrumentSansSemiCondensed-Medium` | `InstrumentSansSemiCondensed-Medium.otf` | Suggestion bubble labels (17 pt) |
| `Font.system(size: 34, weight: .medium)` | SF Pro (system) | — | Number pad digits (approx. weight 510) |

Fonts are loaded at app launch via `FontLoader.loadFonts()` using `CTFontManagerRegisterFontsForURL`. No `UIAppFonts` Info.plist key is required.

---

## Key Implementation Notes

### Font Loading
Fonts are bundled as resources (`.otf` files in `Fonts/`) and registered programmatically with CoreText:
```swift
CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
```
PostScript names are extracted directly from the OTF files — `GTFlexa-CnMd` and `InstrumentSansSemiCondensed-Medium`.

### Amount Formatting
`AmountFormatter` stores input as a raw digit string using `.` as the internal decimal separator, then formats it for display using `NumberFormatter` with `Locale.current`. This localises the currency symbol, grouping separator, and decimal separator automatically.

### Animated Gradient Border
`AnimatedGradientBorderModifier<S: Shape>` is a generic `ViewModifier` that overlays a rotating `AngularGradient` stroke on any `Shape`. A single `@State private var angle` drives an infinite `withAnimation(.linear.repeatForever)`. Used by both `AutomatedBadge` (Capsule, 4 s) and `ReviewButton` (RoundedRectangle, 3 s).

```swift
someView.animatedGradientBorder(shape: Capsule(), lineWidth: 1, duration: 4)
```

### Blinking Caret
`BlinkingCaret` uses a Swift concurrency `task {}` loop with `Task.sleep` — no Timer or Combine required. The `opacity` animates with a fast `.easeInOut(duration: 0.08)` on each toggle for a sharp blink feel.

### Review Button Image Alignment
`review.png` (393 × 260 px, transparent background) is clipped to 100 pt height using `scaledToFill`. At screen width the pill sits approximately 22 pt from the image top, centred 3 pt above the ZStack midpoint. The animated border and tap target use `offset(y: -3)` to align precisely.

### Digit Animation
Two animation layers fire on each key press:
1. `.contentTransition(.numericText(countsDown: false))` — smooth number morphing on the `Text`.
2. `scaleEffect(digitBounce ? 1.018 : 1.0)` with a spring — a subtle "punch" that resets after 110 ms via `Task.sleep`.

### Decimal Button Logic
```
isDecimalDisabled = rawInput.isEmpty || rawInput.contains(".")
```
Disabled when no digits have been entered yet, or when a decimal point already exists. Max 2 fractional digits enforced in `handleKey`.

---

## Build & Run

```bash
open AlinaTest/AlinaTest.xcodeproj
```

Select the **AlinaTest** scheme, choose an iPhone simulator (iOS 26.5), and press **⌘R**.

> **SourceKit diagnostics**: When new files are added outside Xcode (as done here), SourceKit shows "Cannot find X in scope" until the project is re-indexed. These are false positives — the build succeeds because all symbols live in the same module. Open the project in Xcode and the warnings clear immediately.

---

## Dark Mode

The app is dark-mode only. `AmountInputView` applies `.preferredColorScheme(.dark)` at the root so system appearance has no effect.
