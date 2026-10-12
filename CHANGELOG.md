# Changelog

All notable changes to this project are recorded in this file.
The format follows Keep a Changelog, and this project uses Semantic Versioning.

## [Unreleased]

### Added

- HEMTT project scaffold with a CBA-style split of `addons/main` and `addons/colourblind`.
- Research record under `docs/research` for colour vision deficiency, CBA_A3, the Arma 3 colour
  surface, accessibility features, testing, quality standards and example mods.
- Implementation and test plan in `docs/PLAN.md`.
- `.hemtt/lints.toml` enabling `sqf.undefined` and `sqf.unused`, and banning debug macros on release.
- Use `README.md` as the Steam Workshop description and `CHANGELOG.md` as the release changelog.
- Colour-blind modes: Off, Protan, Deutan, Tritan and Achromatopsia.
- A pure palette function, a name mapper and 20 per-mode `CfgMarkerColors` classes.
- The `A3ACC_CVDMode` CBA setting, applied client-local to the map markers.
- An offline verifier, `tests/verify_palette.py`, that gates the config sync and every gated WCAG contrast pair.
- CI, CONTRIBUTING, the PR and issue templates, a pre-commit hook and the QA checklist.
- Research on UK, US and EU accessibility requirements.
- A whole-game remap of `CfgInGameUI` (SideColors, MPTable, SquadRadar, IslandMap) and the `CfgNotifications` status colours.
- A mod icon, converted to PAA and wired to `mod.cpp` and `CfgMods`.
- A Docker in-engine test tier in `tests/ingame`.
- Lowercase PBO names, so a Linux dedicated server loads the addon.
- One addon component per accessibility concern: `main`, `colourblind`, `hearing`, `motion`, `cognitive`, `lowvision`, `motor`.
- Camera-shake reduction, caption forcing, directional gunfire cues, reduced HUD clutter, larger map markers, an always-walk toggle and a pause-menu help screen.
- Marker, group-icon and map-location catalogue colours, the vehicle optic HUD, the Eden editor draw colours and the Zeus cursors.
- A keybind for every feature, a current-objective panel, and the CBA marker event in place of the marker poll.
