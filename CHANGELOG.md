# Changelog

All notable changes to this project are recorded in this file.
The format follows Keep a Changelog, and this project uses Semantic Versioning.

## [Unreleased]

### Changed

- The colour engine is dynamic. A mode change writes the engine's own side and
  interface profile variables, and the addon's own surface variables, instead of
  replacing config values. The player's own values are recorded and restored
  when the mode is Off.
- `CfgMarkerColors`, `CfgMarkers`, `CfgGroupIcons`, `CfgLocationTypes` and the
  name mapper are gone. The shipped config already reads the engine variables
  for those surfaces.
- `CfgInGameUI/SideColors`, `CfgInGameUI/MPTable`, the cursors, the optics, the
  Eden draw colours and the notifications read per-channel expressions. The
  `IslandMap` and `SquadRadar` overrides are gone: the shipped `IslandMap`
  already reads the variables, and the shipped config defines no colour for
  `SquadRadar`.
- Every reopened class restates its vanilla parent. A bare reopen cleared the
  parent and dropped the marker icon, size and scope.
- Coverage is wider. The addon now also recolours the map and group icon status
  markers, the ground support and minefield markers, the vehicle and weapon
  optic indicators across every optic class, the Zeus editor draw colours and
  cursors, the Eden waypoint cursors, the sensor panel, the server browser, the
  compass, the ORBAT, the chat channel, the command bar and the airborne mini
  map altitude gradient.
- `tests/verify_shipped.py` compares every override against the extracted game
  configs. It reports 224 overridden properties across 18805 shipped classes,
  with no property invented on a shipped class, and every parent and default
  agreeing with the game.

### Added

- `tests/verify_surface.py`, an offline gate for the expression form, the
  variable set, the owned and forbidden variables, the deleted overrides and the
  parent restatement.
- An in-engine surface test, and a marker colour wiring assertion.
- HEMTT project scaffold with a CBA-style split of `addons/main` and `addons/colourblind`.
- Research record under `docs/research` for colour vision deficiency, CBA_A3, the Arma 3 colour
  surface, accessibility features, testing, quality standards and example mods.
- Implementation and test plan in `docs/PLAN.md`.
- `.hemtt/lints.toml` enabling `sqf.undefined` and `sqf.unused`, and banning debug macros on release.
- Use `README.md` as the Steam Workshop description and `CHANGELOG.md` as the release changelog.
- Colour-blind modes: Off, Protan, Deutan, Tritan and Achromatopsia.
- A pure palette function that maps a mode and a side to a colour.
- The `A3ACC_CVDMode` CBA setting, applied client-local to the colour surface.
- An offline verifier, `tests/verify_palette.py`, that gates the config sync and every gated WCAG contrast pair.
- CI, CONTRIBUTING, the PR and issue templates, a pre-commit hook and the QA checklist.
- Research on UK, US and EU accessibility requirements.
- A whole-game remap of `CfgInGameUI` and the `CfgNotifications` status colours.
- A mod icon, converted to PAA and wired to `mod.cpp` and `CfgMods`.
- A Docker in-engine test tier in `tests/ingame`.
- Lowercase PBO names, so a Linux dedicated server loads the addon.
- One addon component per accessibility concern: `main`, `colourblind`, `hearing`, `motion`, `cognitive`, `lowvision`, `motor`.
- Camera-shake reduction, caption forcing, directional gunfire cues, reduced HUD clutter, larger map markers, an always-walk toggle and a pause-menu help screen.
- A keybind for every feature, a current-objective panel, and the CBA marker event in place of the marker poll.
