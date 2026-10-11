# Accessibility statement

This statement covers the A3 Accessibility addon for Arma 3. It follows the
structure of the GOV.UK model accessibility statement. It is not a legal
statement and it makes no claim of compliance.

## What this addon does

The addon adds five selectable colour-vision-deficiency modes. Each mode remaps
the named map marker colours so that friendly, enemy, neutral and unknown
markers stay easy to tell apart. The modes change the colours. They do not add a
screen filter or a post-process effect.

The modes are Off, Protan, Deutan, Tritan and Achromatopsia.

## What this addon does not do

- It is addon-scoped. It cannot change Arma 3 itself, other addons, or content
  that the game draws.
- It cannot add a shape, icon, pattern, text or sound cue. Where the game conveys
  meaning by colour alone, a palette change improves perception but does not
  supply the second cue. This is the rule in WCAG 2.2 success criterion 1.4.1
  and in Xbox Accessibility Guideline 103.
- It cannot fix text or UI that it does not draw.
- It cannot guarantee contrast over a variable 3D background.
- It does not make Arma 3 conform to any accessibility standard.

## Contrast

The palette is gated by a machine test. `tests/verify_palette.py` recomputes the
WCAG 2.2 relative-luminance contrast for every pair that must be told apart, and
the build fails if any pair is below 3:1. This is the level WCAG 2.2 success
criterion 1.4.11 requires for non-text elements.

The pairs that must be told apart, and the ratio each reaches, are in
`docs/PLAN.md` section 2. The lowest is 3.10:1.

## How this was tested

- The palette values and the config are checked offline by
  `tests/verify_palette.py`. It needs no game.
- The addon is loaded by a real Arma 3 dedicated server, and its test suite runs
  in the engine, through `tests/ingame/run.sh`. The suite asserts the apply, the
  restore and the mode switch on live markers, the config sync, the setting
  default and the structured-text control.
- Simulation filters were not used to test the palette. They are not a substitute
  for testing with colour-blind players. No colour-blind player has tested this
  addon yet.

## Known limits

- Only the named marker colours are remapped. A marker with a raw colour value
  keeps its value.
- The addon covers map markers. It does not cover every HUD element.

## Report a problem

Report an accessibility problem through the
[GitHub issue tracker](https://github.com/lErrorl404l/A3-Accessibility/issues).

## Standards used

These standards are voluntary for this addon. None of them binds it.

- WCAG 2.2 level AA, success criteria 1.4.1, 1.4.3 and 1.4.11.
- Xbox Accessibility Guideline 103, "Cues and clues".
- The structure of the GOV.UK model accessibility statement.

The background research, including the UK, US and EU requirements, is in
`docs/research/09-accessibility-law.md`.
