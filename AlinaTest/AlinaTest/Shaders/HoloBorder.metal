//
//  HoloBorder.metal
//  AlinaTest
//
//  SwiftUI-stitchable Metal shader that paints a rotating holographic border.
//
//  Key idea: instead of a horizontal UV sweep (which makes a narrow badge look
//  like a single flat colour), we compute each pixel's angle from the view
//  centre and use that as the gradient coordinate.  Adding `time` rotates the
//  colours around the perimeter — identical behaviour to AngularGradient but
//  with full Metal colour control and a shimmer layer on top.
//
//  Usage (SwiftUI):
//    ShapeView
//      .colorEffect(ShaderLibrary.holoBorder(.float2(w, h), .float(time)))
//
//  Auto-injected by SwiftUI:
//    position — pixel coordinate in view-local space
//    color    — source pixel colour / alpha (alpha is used as the stroke mask)
//
//  Caller-supplied:
//    size  — view size in points (.float2(width, height))
//    time  — elapsed seconds (.float(Date.timeIntervalSinceReferenceDate))
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[ stitchable ]] half4 holoBorder(
    float2 position,
    half4  color,
    float2 size,
    float  time
) {
    // Skip transparent pixels (outside the stroke path).
    if (color.a < 0.01h) return color;

    // ── Angular gradient coordinate ───────────────────────────────────────────
    // Compute angle of this pixel around the shape centre [-π, π],
    // normalise to [0, 1], then offset by time so the colours rotate.
    float2 center = size * 0.5;
    float2 delta  = position - center;
    float  angle  = atan2(delta.y, delta.x);              // radians
    float  t      = fract(angle / (2.0 * M_PI_F) + time * 0.22);

    // ── Brand palette ─────────────────────────────────────────────────────────
    half3 hotPink = half3(1.000h, 0.302h, 0.769h);   // #FF4DC4 — vivid pink
    half3 pink    = half3(0.698h, 0.302h, 0.800h);   // #B24DCC
    half3 purple  = half3(0.537h, 0.333h, 0.976h);   // #8955F9
    half3 blue    = half3(0.357h, 0.620h, 0.976h);   // #5B9EF9

    // 4-stop loop: hotPink → purple → blue → pink → hotPink
    half3 grad;
    if (t < 0.25h) {
        grad = mix(hotPink, purple, half(t / 0.25));
    } else if (t < 0.5h) {
        grad = mix(purple,  blue,   half((t - 0.25) / 0.25));
    } else if (t < 0.75h) {
        grad = mix(blue,    pink,   half((t - 0.50) / 0.25));
    } else {
        grad = mix(pink,    hotPink, half((t - 0.75) / 0.25));
    }

    // ── Shimmer — subtle brightness pulse that also travels around the ring ──
    float shimmer = 0.80 + 0.20 * sin(time * 4.0 + angle * 2.5);
    grad *= half(shimmer);

    grad = clamp(grad, 0.0h, 1.0h);
    return half4(grad, color.a);
}
