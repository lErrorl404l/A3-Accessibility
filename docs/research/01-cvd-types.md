# Colour Vision Deficiency: types and palette strategy

Source of record for the CVD modes in this addon. `[F]` = measured fact with a source,
`[O]` = design opinion, `UNKNOWN` = not confirmed.

## 1. CVD types and prevalence

Male / female prevalence. Confusion pairs and opsin assignments from the cited sources.

| Type | Prevalence (M / F) | Cone / opsin | Colours confused |
|---|---|---|---|
| Protanomaly | 1.3% / 0.02% | L-cone, anomalous OPN1LW (X-linked) | Red, green, brown, orange; some blue vs purple |
| Protanopia | 1.3% / 0.02% | L-cone absent (X-linked) | Black vs dark red; dark brown vs dark green/orange/red; red strongly dimmed |
| Deuteranomaly | 5.0% / 0.35% | M-cone, anomalous OPN1MW (X-linked) | Red-green family, mild |
| Deuteranopia | 1.2% / 0.01% | M-cone absent (X-linked) | Mid-red vs mid-green; blue-green vs grey; bright green vs yellow; light blue vs lilac |
| Tritanomaly | 0.0001% / 0.0001% | S-cone, anomalous OPN1SW (chr 7, autosomal dominant) | Blue vs green; yellow vs red |
| Tritanopia | 0.008% / 0.008% | S-cone absent (chr 7) | Light blue vs grey; dark purple vs black; mid-green vs blue; orange vs red |
| Achromatopsia | ~1 in 33,000 | All cones (rod monochromacy) | All hue; world is greyscale |

Key measured facts:

- Protan and deutan types are X-linked and affect males far more than females. `[F]`
  <https://en.wikipedia.org/wiki/Color_vision_deficiency>
- Tritan types are equally common in both sexes (chromosome 7). `[F]` same.
- Neutral points: protan ~492 nm (cyan), deutan ~498 nm, tritan ~571 nm (yellow). `[F]` same.
- Protanopes see red much dimmer; red can be confused with black or dark grey. `[F]` same.
- Tritanopes see "light blues with greys, dark purples with black, mid-greens with blues, oranges with reds". `[F]`
  <https://www.colourblindawareness.org/colour-blindness/types-of-colour-blindness/>
- About 1 in 12 men have some CVD; ~8% of men and 0.5% of women worldwide are red-green deficient. `[F]`
  <https://www.nei.nih.gov/eye-health-information/eye-conditions-and-diseases/color-blindness>

## 2. Design consequences

- WCAG SC 1.4.1: colour must not be the only visual means of conveying information. `[F]`
  <https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html>
- A hue difference with luminance contrast of 3:1 or more counts as a second, non-colour distinction. `[F]` same.
- Hue/saturation have "minimal or no effect on legibility" for CVD viewers; luminance contrast is the reliable lever. `[F]`
  <https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html>
- Cross-axis trap: colours that contrast best for red-green CVD tend to be confusable for blue-yellow CVD and vice versa. `[F]`
  <https://en.wikipedia.org/wiki/Color_vision_deficiency>
  Therefore one palette cannot serve all types. Ship distinct selectable modes. `[O]`
- Shape/pattern redundancy is the reliable fallback: pair each marker colour with a distinct icon shape and, where possible, a text tag. `[F]`
  <https://gameaccessibilityguidelines.com/full-list/>

Contrast thresholds to target:

| Criterion | Level | Requirement |
|---|---|---|
| 1.4.1 Use of Color | A | Colour not the sole carrier of meaning |
| 1.4.3 Contrast (Minimum) | AA | Text 4.5:1, large text 3:1 |
| 1.4.11 Non-text Contrast | AA | UI components / meaningful graphics 3:1 |

## 3. Mode strategy

- Protan / deutan modes: move friend/foe and status cues off the red-green axis; use blue vs orange/amber plus luminance tiers. Treat red as a dark colour. `[O]`
- Tritan modes: move off the blue-yellow axis; use red vs green plus luminance. `[O]`
- Achromatopsia mode: hue-free; distinguish by luminance, outline weight and shape only. `[O]`
- Assign each marker class a distinct perceived-luminance tier (>= 3:1 apart) before assigning hue; raise saturation only after luminance separation is proven. `[O]`
- Ship at least: protan, deutan, tritan, greyscale (achromatopsia). `[O]`

## 4. Industry precedent and the central error

- The most common mistake is shipping a filter that **simulates** CVD instead of **correcting** it. A simulation makes red and green look the same to normal viewers rather than moving a colour into a CVD-visible range. Atomic Heart is the named example. `[F]`
  <https://access-ability.uk/2025/01/10/the-biggest-mistake-game-devs-make-with-colour-blind-accessibility/>
- Screen-wide filters destroy art cohesion and are often less effective in fast games. Preferred order: inherent accessible design, per-element player customisation, alternative symbology. `[F]` same.
- Hue (Fiddlesticks) adds symbols on coloured areas so meaning survives without hue. `[F]`
  <https://gameaccessibilityguidelines.com/hue-colorblind-mode/>
- Tekken 8 uses patterned silhouettes instead of colour as the identifying cue. `[F]` (Access-Ability, above).
- Daltonization shifts colours into a distinguishable range but cannot restore lost hue and can distort appearance for normal viewers. For a UI, remapping the few load-bearing marker colours is more predictable than a whole-screen filter. `[F]` doi:10.1016/j.jvcir.2015.12.014

**Decision for this addon:** remap UI colours per mode. Do not apply a simulation matrix. `[O]`

## 5. Open / unknown

- Windows/macOS exact filter names: UNKNOWN, do not cite without a fresh check.
- Battlefield / Call of Duty / Overwatch / Fortnite specifics: UNKNOWN this pass.
- Arma 3 `CfgMarkerColors` page contents: UNKNOWN (BIKI returned 403). See the Arma 3 research doc.
