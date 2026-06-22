//
//  HoloBorder.metal
//  AlinaTest
//
//  Animates the "border" image asset. The `color` input is the real image pixel
//  (pink/purple/blue from the asset) — colours and pattern are fully preserved.
//  Only brightness is modulated so the animation is clearly visible.
//
//  Effects:
//    1. Deep brightness wave  — dims to 30 % then peaks at 100 %, one full
//                               cycle clockwise every ~2.5 s.
//    2. Fast shimmer          — higher-frequency flicker for the foil texture.
//    3. Two travelling glints — sharp bright reflections orbiting in opposite
//                               directions, wide enough to be clearly visible.
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
    if (color.a < 0.01h) return color;

    // Angular position [0, 1) around badge centre
    float2 center = size * 0.5f;
    float2 delta  = position - center;
    float  angle  = atan2(delta.y, delta.x);
    float  aT     = fract(angle / (2.0f * M_PI_F));

    // 1. Deep brightness wave — large amplitude so the dim/bright is obvious
    float wave = 0.30f + 0.70f * (0.5f + 0.5f * sin(aT * 6.28318f - time * 2.5f));

    // 2. Fast shimmer overlay
    float shimmer = 0.85f + 0.15f * sin(aT * 6.28318f * 4.0f + time * 8.0f);

    // 3a. Glint A — orbits clockwise every ~3 s, wide soft peak
    float g1pos  = fract(time * 0.33f);
    float g1dist = abs(aT - g1pos);
    g1dist = min(g1dist, 1.0f - g1dist);
    float glint1 = pow(max(0.0f, 1.0f - g1dist * 10.0f), 2.5f);

    // 3b. Glint B — orbits counter-clockwise every ~5 s
    float g2pos  = fract(-time * 0.20f + 0.5f);
    float g2dist = abs(aT - g2pos);
    g2dist = min(g2dist, 1.0f - g2dist);
    float glint2 = pow(max(0.0f, 1.0f - g2dist * 10.0f), 2.5f);

    float glint = clamp(glint1 + glint2, 0.0f, 1.0f);

    // Combine: modulate image brightness then add glint
    half brightness = half(wave * shimmer);
    half3 col = color.rgb * brightness;
    // Glint: blend toward a bright slightly-pink white
    col = mix(col, half3(1.0h, 0.85h, 1.0h), half(glint * 0.80f));

    return half4(clamp(col, 0.0h, 1.0h), color.a);
}
