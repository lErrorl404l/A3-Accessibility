# A3 Accessibility: dynamic colour engine

Status: decision complete. The worker starts at T0 and needs no interview.
Requirement, verbatim: "Needs to be fully dynamic, needs to be fully accessible."
Evidence: `docs/research/10-colour-surface-dump.md`, `11-config-sweep.md`,
`12-command-capability.md`, `14-accessibility-what-good-looks-like.md`,
`docs/PLAN-colour-surface.md`. British English. ASD-STE100. ASCII only.

## 1. Target architecture

Three mechanisms. M1 is primary.

### M1 (primary): one config shape, the profile-variable expression

Every colour the engine reads from config becomes three per-channel string
expressions and the vanilla alpha literal:

```
colorFriendly[] = {
    "(profilenamespace getvariable ['A3ACC_Surf_SideColors_colorFriendly_R',0.709])",
    "(profilenamespace getvariable ['A3ACC_Surf_SideColors_colorFriendly_G',0.972])",
    "(profilenamespace getvariable ['A3ACC_Surf_SideColors_colorFriendly_B',0.384])",
    1
};
```

Rules:

1. A mode change writes profile variables. It does not write config. Config is
   read-only at runtime.
2. Where vanilla already uses a profile variable, keep the vanilla name. The
   addon records the player's value and restores it on Off. Where vanilla writes
   a literal, use `A3ACC_Surf_<surface>_<key>_<R|G|B>`.
3. The expression default is the vanilla channel. An unwritten variable gives
   the vanilla colour.
4. Reopen shared classes, not leaf classes. A mod class that inherits a reopened
   class follows the mode. A mod that reads a vanilla side-colour variable
   follows the mode.
5. Every reopened class restates its parent. A bare reopen clears the parent.

### M2: runtime setters, where the engine offers one

- Markers: `setMarkerColorLocal` on `allMapMarkers`, any origin. Shipped and unchanged.
- Reachable UI controls: `ctrlSetTextColor` on `allControls`. UNVERIFIED which
  displays, and whether the colour survives a redraw. Probe D2.

### M3: runtime enumeration of the merged config

A recursive walk of `configFile` (proven, 3453 properties) lists every
colour-bearing property, including mods. It cannot write config. It measures
coverage and names the uncovered remainder.

### The boundary, stated once

Config compiles at load. An addon cannot create a class for a mod class it does
not know at build time. Mod content is covered when it inherits a reopened
class, reads a vanilla side-colour variable, or has a runtime setter. The rest
is measured by M3 and reported. The plan claims no coverage it cannot prove.

### What this removes

The 47 hand-written leaf overrides become the smallest shared set. The
universal-palette limit on the HUD ends, because every surface becomes per-mode.
The 20 `A3ACC_<colour>_<mode>` marker classes become optional, per probe D4.

## 2. Migration order

Never leave the tree red. Every task updates its verifier in the same commit.
Order: T0 green the tree, T1 the blocking probe, T2 the no-filter decision, then
one surface at a time, then the vanilla variables, then the coverage meter, then
the apply path, then docs. The tree is red today: `tests/verify_palette.py` exits
1 because Gate 5 rejects the restated parents.

## 3. Tasks

### T0. Green the tree

Files: `tests/verify_palette.py`.
Change: Gate 5 must accept a parent. Replace
`rf"class {cls}\s*\{{"` with `rf"class {cls}(?:\s*:\s*\w+)?\s*\{{"`.
Commit the six modified `addons/colourblind/Cfg*.hpp` parent restatements first.
Gate: `python3 tests/verify_palette.py` exits 0. `python3 tests/verify_no_filter.py`
exits 0.

### T1. The blocking probe: evaluation timing

This is the single blocking unknown. It needs a rendering client.
Files: add `tests/ingame/missions/a3acc_probe.Stratis/eval_probe.sqf`. Extend
`docs/research/probe-client-runtime-colour.sqf`.
Change: for each surface key, the probe logs the raw `getArray`, then
`call compile` of each channel, then writes the variable, then `call compile`
again, then forces a redraw (open the map, fire a notification, build the
scoreboard), then `call compile` again. Log prefix `[A3ACC-EVAL]`.
Gate: client RPT. The human runs `hemtt launch` with the probe mission and reads
the RPT at
`/ext/SteamLibrary/steamapps/compatdata/107410/pfx/drive_c/users/steamuser/AppData/Local/Arma 3/`.
The human records, per surface: value before the write, value after the write,
and whether the drawn surface changed. The answer sets `_needRestart` and the
docs.

### T2. Resolve the no-filter conflict

Files: `tests/verify_no_filter.py`, `docs/PLAN-accessibility.md`.
Change: keep the promise. Split the gate into two named checks. Check A scans all
of `addons/` for `ppEffect*`, `setPiPEffect`, `ColorCorrections` and a 10-number
array. Check B scans only `addons/colourblind/` for `setAperture` and
`setApertureNew`, so the colour component is provably brightness-neutral. The
colour engine uses per-channel expressions, so it needs no matrix and no
post-process. Move the flash items MP2 and MP3 of `docs/PLAN-accessibility.md` to
the future `addons/accessibility/` component, which Check B does not scan.
Gate: `python3 tests/verify_no_filter.py` exits 0 and prints both check lines.

### T3. Pure table and writer, no config change

Files: add `addons/colourblind/functions/fnc_surfaceColourFor.sqf`, add
`addons/colourblind/functions/fnc_applySurface.sqf`, edit
`addons/colourblind/XEH_PREP.hpp`, add `tests/verify_surface.py`, add
`addons/colourblind/test_surface.sqf`, edit `addons/colourblind/CfgTests.hpp`.
Change: `fnc_surfaceColourFor` is pure, `[mode, key] -> RGBA`. It holds the
vanilla value, the four mode values and the two universal greys. `fnc_applySurface`
writes the profile variables and calls `saveProfileNamespace` once.
`test_surface.sqf` asserts the writer round-trip.
Gate: `python3 tests/verify_surface.py`. `python3 tests/verify_palette.py`.
In-engine `tests/ingame`.

### T4. Convert `CfgInGameUI/SideColors`

Files: `addons/colourblind/CfgInGameUI.hpp`, `tests/verify_palette.py` (Gate 4),
`addons/colourblind/test_config.sqf`,
`addons/colourblind/functions/fnc_applySurface.sqf`.
Change: the five SideColors keys become expression triples plus the vanilla
alpha. Gate 4 reads the expression, checks the variable name and the default. The
in-engine assertion becomes an expression assertion. `fnc_applySurface` adds the
five keys.
Gate: offline `tests/verify_palette.py`, in-engine `tests/ingame`, client RPT:
open the map, change the mode, confirm the HUD icons recolour.

### T5. Convert `CfgNotifications`

Files: `addons/colourblind/CfgNotifications.hpp`, `tests/verify_palette.py`,
`addons/colourblind/test_config.sqf`,
`addons/colourblind/functions/fnc_applySurface.sqf`.
Change: the status class properties become expression triples. Restate each
parent.
Gate: offline, in-engine, client RPT: fire a task-succeeded and a task-failed
notification, change mode, confirm the two colours differ.

### T6. Convert `CfgWrapperUI/Cursors` and `Cfg3DEN`

Files: `addons/colourblind/CfgWrapperUI.hpp`, `addons/colourblind/Cfg3DEN.hpp`,
`tests/verify_palette.py`, `addons/colourblind/test_config.sqf`,
`addons/colourblind/functions/fnc_applySurface.sqf`.
Gate: offline, in-engine, client RPT: enter Zeus and confirm the cursor colour.
Open Eden and confirm the draw colour.

### T7. Convert `RscInGameUI` optic HUDs

Files: `addons/colourblind/CfgRscInGameUI.hpp`, `tests/verify_palette.py`,
`addons/colourblind/test_config.sqf`,
`addons/colourblind/functions/fnc_applySurface.sqf`.
Gate: offline, in-engine, client RPT: enter a vehicle optic and confirm.

### T8. Convert the marker catalogue defaults

Files: `addons/colourblind/CfgMarkers.hpp`,
`addons/colourblind/CfgGroupIcons.hpp`,
`addons/colourblind/CfgLocationTypes.hpp`, `tests/verify_palette.py`,
`addons/colourblind/test_config.sqf`,
`addons/colourblind/functions/fnc_applySurface.sqf`.
Change: the side entries become expression triples. Keep the
`setMarkerColorLocal` path and `fnc_applyMode` unchanged.
Gate: offline, in-engine, client RPT: create a marker, change mode, confirm.

### T9. Vanilla variable capture and restore

Files: add `addons/colourblind/functions/fnc_vanillaVars.sqf`, edit
`addons/colourblind/XEH_PREP.hpp`,
`addons/colourblind/functions/fnc_applySurface.sqf`.
Change: capture the vanilla `Map_*` and `IGUI_TEXT_RGB_*` values on first apply,
write the mode values, restore on Off. The exact variable names come from the T1
dump.
Gate: in-engine assertion for the round-trip. Client RPT: set the game's own map
colour, turn a mode on, then Off, confirm the choice returns.

### T10. Coverage meter

Files: add `addons/colourblind/functions/fnc_coverage.sqf`, edit
`addons/colourblind/XEH_PREP.hpp`, `addons/colourblind/XEH_postInit.sqf`,
`tests/ingame/verify.py`, add `docs/research/15-coverage.md`.
Change: `fnc_coverage` walks `configFile`, counts colour-bearing properties, and
logs `[A3ACC-COVER] found=N covered=M uncovered=K`. `verify.py` requires
`[A3ACC-COVER] DONE` and fails on `Updating base class`.
Gate: in-engine `tests/ingame`. `docs/research/15-coverage.md` records the
numbers.

### T11. One apply path, per-mode HUD

Files: add `addons/colourblind/functions/fnc_applyAll.sqf`, edit
`addons/colourblind/initSettings.inc.sqf`, `addons/colourblind/XEH_preStart.sqf`,
`tests/verify_palette.py`.
Change: the settings hook becomes `fnc_applyAll`, which calls `fnc_applyMode` then
`fnc_applySurface`. `XEH_preStart.sqf` writes the variables before any display is
built. The universal-palette gates of `verify_palette.py` become per-mode gates.
Gate: offline, in-engine, client RPT.

### T12. Documentation

Files: `README.md`, `ACCESSIBILITY.md`, `CHANGELOG.md`,
`docs/QA-colourblind.md`, `docs/PLAN-colour-surface.md`.
Change: state the dynamic mechanism, the mod-coverage boundary, the evaluation
timing from T1, and the no-filter scope from T2. Mark
`docs/PLAN-colour-surface.md` superseded.
Gate: `python3 tests/verify_palette.py`, `python3 tests/verify_no_filter.py`,
`python3 tests/verify_surface.py`.

### T13. Final verification wave

Gate: every offline gate, one dedicated-server run, one client run. Record the
result in `CHANGELOG.md`.

## 4. Open decisions and their probes

- **D1, live re-evaluation. Blocking.** Does the engine re-evaluate a
  profile-variable expression after the variable changes, and at which moment is
  each surface evaluated? Probe T1. Sets `_needRestart` and the docs.
- **D2, control setter reach.** Which displays expose a control text-colour
  setter, and does the colour survive a redraw? Probe: extend
  `docs/research/probe-client-runtime-colour.sqf`, run on a client, read
  `[A3ACC-CPROBE]`.
- **D3, mod marker coverage.** Does a mod marker that uses a vanilla colour name
  follow a reopened `CfgMarkerColors` expression? Probe: a dedicated-server run
  with a test mod, then a client run.
- **D4, marker setter re-read.** Does `setMarkerColorLocal` re-read a class
  colour expression at set time? Probe: client RPT. If yes, collapse the 20
  marker classes to 5.
- **D5, nested default.** Does the engine accept a nested
  `profilenamespace getvariable` default inside a config expression? Probe:
  in-engine `getArray` plus `call compile`.
- **D6, player choice restore.** Is record-and-restore of the vanilla variables
  enough to preserve the player's own map colour choice? Probe: client RPT, T9.

## 5. Acceptance

- A mode change drives every surface the addon covers, without a restart, or the
  docs state the exact restart condition from D1.
- Any mod marker, and any mod class that inherits a reopened class, follows the
  mode.
- The coverage meter names the uncovered remainder.
- Off restores vanilla, including the player's own map colour choice.
- No matrix and no post-process in the colour component.
