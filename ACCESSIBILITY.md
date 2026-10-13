# Accessibility statement

This statement covers the A3 Accessibility addon for Arma 3. It follows the
structure of the GOV.UK model accessibility statement. It is not a legal
statement and it makes no claim of compliance.

## What this addon does

The addon adds five selectable colour-vision-deficiency modes. Each mode drives
the colours that carry side and status meaning, so that friendly, enemy, neutral
and unknown stay easy to tell apart.

The mechanism is dynamic. The engine reads most of these colours from a profile
variable, and a few from a mission variable, so a mode change writes variables
instead of replacing config values. The addon writes the engine's own side and
interface variables, and its own surface variables, and records the player's
own values so that Off restores them. It does not add a screen filter and it
does not add a post-process effect.

The surfaces that follow a mode: the map markers and the map, the group icons,
the HUD and 3D icon side colours, the respawn table, the vehicle optic indicators
and heading, the Eden editor draw colours and waypoint cursors, the Zeus editor
draw colours and cursors, the task and score notifications, the interface error
and warning text, the tactical ping, the sensor panel, the server browser, the
compass, the ORBAT and the chat channel.

The modes are Off, Protan, Deutan, Tritan and Achromatopsia.

## Features

The addon is split into one component per accessibility concern.

- **Colour blind mode** (`colourblind`): five modes over the map markers and
  the map, the HUD and 3D icon side colours, the respawn table, the vehicle optic
  HUD, the Eden editor draw colours, the Zeus and high-command cursors, and the
  notification, error, warning and tactical ping colours.
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
- **Always walk** (`motor`): forces a walk. This removes sprint, so it is off by
  default and the player opts in.
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
  restore and the mode switch, the engine variable values, the marker colour
  wiring, the setting default and the structured-text control. An offline gate,
  `tests/verify_surface.py`, asserts the expression form, the variable set and
  that every reopened class restates its parent.
- Simulation filters were not used to test the palette. They are not a substitute
  for testing with colour-blind players. No colour-blind player has tested this
  addon yet.

## Known limits

- Only the colours the addon covers are remapped. A marker that a mission gives
  a raw colour value keeps that value.
- The evaluation moment of the converted surfaces is not fully mapped at a
  client. One class is settled: `CfgInGameUI/MPTable`, the respawn table, is
  evaluated before the profile namespace exists, and a profile expression there
  terminates the game. Every converted surface therefore reads a mission
  variable, which the engine cannot evaluate that early either, so a surface the
  engine reads that early shows the shipped colour instead of the mode colour.
  Which surfaces those are is unverified. See
  `docs/research/20-colour-coverage.md`.
- Whether the engine reads `CfgInGameUI/MPTable` again after the mission starts is
  unverified. Its expression resolves to the mode colour when read, which the
  in-engine tier asserts.
- No script command reads a marker's resolved colour, so the rendered marker
  colour can only be checked by eye at a client.
- The addon does not change map terrain colours such as sea, forest and contour
  lines. Those are art, not side identity.
- The always-walk option removes sprint rather than removing the need to hold a
  key. `forceWalk` and `allowSprint` are the only motor commands and both are
  Boolean switches, so a sprint toggle is not available to an addon. The option
  is off by default, the change is networked, and a mission that depends on
  sprint can break.
- There is no global text-size lever. The game sizes text per control, from the
  control size and a size-indexed font family, so the addon can only size its
  own interface.
- Friendly and enemy name tags are a difficulty option. A mod can ship a
  difficulty preset, but it cannot raise the tags at runtime, and it cannot
  force the player to select a preset.

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
