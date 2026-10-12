# Accessibility statement

This statement covers the A3 Accessibility addon for Arma 3. It follows the
structure of the GOV.UK model accessibility statement. It is not a legal
statement and it makes no claim of compliance.

## What this addon does

The addon adds five selectable colour-vision-deficiency modes. Each mode remaps
the named map marker colours so that friendly, enemy, neutral and unknown
markers stay easy to tell apart. It also remaps the wider colour surface that
carries side and status meaning: the HUD and 3D icon side colours
(`CfgInGameUI/SideColors`), the scoreboard side colours, the squad radar, the
map object colours, and the notification status colours. The modes change the
colours. They do not add a screen filter or a post-process effect.

The modes are Off, Protan, Deutan, Tritan and Achromatopsia.

## Features

The addon is split into one component per accessibility concern.

- **Colour blind mode** (`colourblind`): five modes over the map markers, the
  HUD and 3D icon side colours, the scoreboard, the squad radar, the marker,
  group-icon and map-location catalogues, the vehicle optic HUD, the Eden editor
  draw colours, the Zeus cursors and the notification colours.
- **Reduce camera shake** (`motion`): for motion sensitivity.
- **Force subtitles on** (`hearing`): and restore the previous setting when off.
- **Directional gunfire cues** (`hearing`): an on-screen cue in the direction of
  nearby gunfire, for deaf and hard-of-hearing players.
- **Reduce HUD clutter** (`cognitive`): hides the kill feed and panels, the HUD
  group icons and the radio chatter.
- **Accessibility help screen** (`cognitive`): opens from the pause menu.
- **Current objective panel** (`cognitive`): a small always-on panel with the
  current task.
- **Larger map markers** (`lowvision`): for low vision.
- **Always walk** (`motor`): no key is needed to change speed.
- **Keybinds**: every feature is reachable from the keyboard, unbound by
  default. CBA keybinds are client-only, so they do not register on a server.

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
- The wider colour surface uses one universal palette, not the selected mode.
  The engine reads those fixed-name classes once, so they cannot switch with the
  mode. The palette is separated at 3:1 by luminance, so every deficiency type
  can still separate the colours by brightness.
- The addon does not change map terrain colours such as sea, forest and contour
  lines. Those are art, not side identity.

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
