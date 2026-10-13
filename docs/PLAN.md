# A3 Accessibility - colour-blind modes, implementation and test plan

**Superseded.** The palette tables remain the source of the mode values, but the
mechanism and the scope have moved on. See `docs/PLAN-dynamic.md` for the dynamic
engine and `docs/PLAN-accessibility.md` for the full roadmap across every
impairment. `docs/research/20-colour-coverage.md` records what is covered.

Status: decision complete. The worker needs no further interview.
Slice: selectable colour-vision-deficiency (CVD) palettes for map markers and the addon's own structured-text panel.
Evidence base: `docs/research/01` to `docs/research/08`. Every value cites a rule. British English. ASD-STE100. ASCII only.

## 1. Scope and guardrails

Deliver: one CBA LIST setting with five modes, one pure palette function, `CfgMarkerColors` classes per mode and per class, one addon-owned structured-text control, and tests at the four layers of `03-testing.md` section 3.

Must NOT have:
- No full-screen render filter. `04-accessibility-features.md` marks it NOT ACHIEVABLE.
- No override of vanilla `RscDisplay*` or `RscMapControlTooltip`. `04` says a wholesale vanilla restyle is not guaranteed, and the `05-aee-prior-art.md` section 2 tooltip override is an AEE cartography behaviour, not a colour-blind feature.
- No separate high-contrast LIST entry. `04` lists high contrast under "build with a stated caveat", not under "build first". The four modes already meet the 3:1 non-text floor of `01` section 2.
- No marker texture, icon shape, or outline-weight work. Deferred, see section 12.
- No feature outside colour-blind modes. The wider roadmap stays unplanned.

## 2. Palette data model

- A. The palette is an SQF literal table inside the pure function. `03-testing.md` section 3 needs a pure function for the SQF-VM tier, and a config query or a global read breaks purity.
- B. `CfgMarkerColors` holds its own copy of the numbers, because config is static and cannot be generated from SQF. A CBA in-engine test asserts that config equals the function, per the `03-testing.md` section 2 pattern. The duplication is a known trade and the test is the guard.
- C. Every entry has alpha 1. `06-arma3-colour-surface.md` section 3 states alpha is element 4 and 1 is opaque.
- D. Mode index 0 (Off) returns `[]`. Off means "restore the original", so no remap value exists, and `[]` is total and machine-checkable.
- E. Protan and Deutan hold identical values in this slice. `01` section 3 gives one strategy for both, "move friend/foe and status cues off the red-green axis, use blue vs orange/amber plus luminance tiers". The modes stay separate LIST entries so a later slice can tune each.
- F. No high-contrast variant. See section 1.
### 2.1 Mode set and LIST indices

The LIST values extend the verified example in `02-cba-and-tooling.md` section 2.

| Index | Mode | Axis rule, `01` section 3 |
|---|---|---|
| 0 | Off | no remap, restore the original name |
| 1 | Protan | off the red-green axis, blue vs amber, treat red as dark |
| 2 | Deutan | off the red-green axis, blue vs amber |
| 3 | Tritan | off the blue-yellow axis, red vs green plus luminance |
| 4 | Achromatopsia | hue-free, luminance only |
### 2.2 Classes and their engine names

The five engine names come from the AEE affiliation adapter, which states that `getMarkerColor` returns one of these (`05-aee-prior-art.md` section 1 and the AEE `fnc_symbologyAffiliation` comment).

| Class | Engine colour name | Status |
|---|---|---|
| friendly | `ColorWEST` | verified by AEE prior art |
| enemy | `ColorEAST` | verified by AEE prior art |
| neutral | `ColorGUER` | verified by AEE prior art |
| civilian | `ColorCIV` | verified by AEE prior art |
| unknown | `ColorUNKNOWN` | verified by AEE prior art |
| objective | none | UNVERIFIED, see section 11 item 6 |
### 2.3 Protan and Deutan values

`01` section 3: blue vs orange/amber plus luminance tiers. Cyan is the protan and deutan neutral point (`01` section 1, protan ~492 nm, deutan ~498 nm), so cyan is safe for both. Amber is the only hue inside the red-green confused band, so no gated pair has both hues in the band.

| Class | RGBA | Hex | Luminance |
|---|---|---|---|
| friendly | 0.00, 0.35, 0.85, 1 | #0059D9 | 0.122 |
| enemy | 1.00, 0.70, 0.00, 1 | #FFB200 | 0.533 |
| neutral | 0.00, 0.80, 0.80, 1 | #00CCCC | 0.476 |
| unknown | 0.75, 0.75, 0.75, 1 | #BFBFBF | 0.523 |
| civilian | 0.35, 0.35, 0.35, 1 | #595959 | 0.100 |
| objective | 1.00, 1.00, 1.00, 1 | #FFFFFF | 1.000 |

Gated pairs, by the WCAG 2.2 relative-luminance formula: friendly vs enemy 3.39:1, neutral vs civilian 3.49:1, enemy vs civilian 3.87:1, friendly vs unknown 3.33:1. All clear the 3:1 floor of `01` section 2, where a luminance ratio of 3:1 or more counts as a second, non-colour distinction. The red-green axis carries no meaning in this mode.
### 2.4 Tritan values

`01` section 3: red vs green plus luminance. No blue, no purple and no orange is present, so the tritan confusions of `01` section 1 (light blue vs grey, dark purple vs black, mid-green vs blue, orange vs red) cannot occur.

| Class | RGBA | Hex | Luminance |
|---|---|---|---|
| friendly | 0.70, 0.00, 0.00, 1 | #B20000 | 0.095 |
| enemy | 0.30, 0.90, 0.30, 1 | #4CE64C | 0.584 |
| neutral | 0.75, 0.75, 0.75, 1 | #BFBFBF | 0.523 |
| unknown | 0.45, 0.45, 0.45, 1 | #737373 | 0.171 |
| civilian | 0.20, 0.20, 0.20, 1 | #333333 | 0.033 |
| objective | 1.00, 0.85, 0.00, 1 | #FFD900 | 0.708 |

Gated pairs: friendly vs enemy 4.37:1, neutral vs civilian 6.89:1, objective vs friendly 5.22:1, enemy vs civilian 7.63:1. The objective gate is required because `01` section 1 names "yellow vs red" as a tritan confusion.
### 2.5 Achromatopsia values

`01` section 3: hue-free, distinguish by luminance, outline weight and shape only. Three grey tiers are used. The offline gate `tests/verify_palette.py` recomputes every gated pair, so these are the corrected values that clear 3:1: grey 0.25 (L 0.051), grey 0.56 (L 0.274), grey 0.98 (L 0.955).

| Class | RGBA | Hex | Luminance | Extra carrier |
|---|---|---|---|---|
| friendly | 0.98, 0.98, 0.98, 1 | #FAFAFA | 0.955 | shape |
| enemy | 0.25, 0.25, 0.25, 1 | #404040 | 0.051 | shape |
| neutral | 0.56, 0.56, 0.56, 1 | #8F8F8F | 0.274 | shape |
| unknown | 0.56, 0.56, 0.56, 1 | #8F8F8F | 0.274 | dashed outline |
| civilian | 0.98, 0.98, 0.98, 1 | #FAFAFA | 0.955 | thin outline |
| objective | 1.000, 1.000, 1.000, 1 | #FFFFFF | 1.000 | text tag |

Gated pairs, recomputed by `tests/verify_palette.py`: friendly vs enemy 9.96:1, friendly vs neutral 3.10:1, enemy vs neutral 3.21:1, objective vs enemy 10.41:1, objective vs neutral 3.24:1.
Stated limitation: six classes cannot all sit 3:1 apart in greyscale. Unknown shares the neutral grey and civilian shares the friendly grey. `01` section 3 makes outline weight and shape a carrier for this mode, so those two pairs depend on the shape layer, which is deferred (section 12).

## 3. The pure mapping function

Name `A3ACC_colourblind_fnc_paletteForMode`, file `addons/colourblind/functions/fnc_paletteForMode.sqf`.

```
params [["_mode", 0, [0]], ["_class", "friendly", [""]]];
// Return <ARRAY> [r, g, b, a] in 0..1, or [] for mode 0 or an unknown class.
```

Why it is pure, and why SQF-VM can test it:
- It reads only `_mode` and `_class`. No global, no config, no engine state.
- It writes nothing and has no side effect.
- Its table is a `private` literal array inside the body, with no `#include` of a data file, so no preprocessor dependency for the runner.
- The same inputs always give the same output.

The file still carries `#include "script_component.hpp"` for project convention. The SQF-VM runner points its include path at `include/`, which holds the CBA macro stub, exactly as HEMTT does.

Second pure function `A3ACC_colourblind_fnc_colourNameFor`, file `addons/colourblind/functions/fnc_colourNameFor.sqf`, signature `[mode, engineColourName] -> addon class name`. `[1, "ColorWEST"]` gives `"A3ACC_ColorWEST_Protan"`. `[0, "ColorWEST"]` gives `""`, which means "no remap". `[1, "#A1B2C3"]` gives `""`, which means "unknown name, leave the marker". Pure for the same reasons, and it is the second SQF-VM target.

## 4. Config override files
### 4.1 `addons/colourblind/CfgMarkerColors.hpp`

The AEE-proven shape from `05-aee-prior-art.md` section 1: forward-declare the engine base, inherit it, and set only `scope` and `color[]`.

```
class CfgMarkerColors {
    class Default;                            // forward-declare the engine base
    class A3ACC_ColorWEST_Protan: Default    { scope = 1; color[] = {0.00, 0.35, 0.85, 1}; };
    class A3ACC_ColorEAST_Protan: Default    { scope = 1; color[] = {1.00, 0.70, 0.00, 1}; };
    class A3ACC_ColorGUER_Protan: Default    { scope = 1; color[] = {0.00, 0.80, 0.80, 1}; };
    class A3ACC_ColorCIV_Protan: Default     { scope = 1; color[] = {0.75, 0.75, 0.75, 1}; };
    class A3ACC_ColorUNKNOWN_Protan: Default { scope = 1; color[] = {0.35, 0.35, 0.35, 1}; };
    // Repeat the five entries for Deutan, Tritan and Achromatopsia.
};
```

Rules carried from `05-aee-prior-art.md` section 3:
- `class X : Y` is the only way to override a vanilla class and keep inherited fields.
- A bare reopen `class X { ... }` with no `: Y` makes the engine log `Updating base class '<parent>'->''`, and X loses `scope`, `size` and `drawStyle`.
- The forward declaration must sit at the same scope as the user. A file-root forward declaration creates an empty class and re-parents existing entries. HEMTT flags this as `L-C03` or `L-C04`.
- Class names are case-insensitive, and the parent must precede the child in the file.
- Set only `scope` and `color[]`. No `name`, no `side`, no `aiRgbValue`.

Count: 4 non-Off modes x 5 classes = 20 entries. Naming rule `A3ACC_Color<EngineClass>_<Mode>`. No entry for the objective class, because no engine name is verified. No vanilla name such as `ColorWEST` is redefined, because a static redefinition cannot follow the runtime mode, so the runtime pass owns the remap instead.
### 4.2 `addons/colourblind/CfgStructuredText.hpp`

One addon-owned control. The addon does not touch a vanilla control.

```
class RscStructuredText;                       // forward-declare at this scope
class A3ACC_RscStructuredText: RscStructuredText {
    colorText[] = {0.93, 0.93, 0.93, 1};
    colorBackground[] = {0.10, 0.10, 0.10, 1};
};
```

The text pair is 14.96:1, which clears the 4.5:1 text floor of `01` section 2 (WCAG 2.2 SC 1.4.3). The panel is mode-independent by design, so a mode change cannot make the addon's own text unreadable. No `RscMapControlTooltip` override, per section 1.
### 4.3 Functions registration (no `CfgFunctions.hpp`)

An earlier draft registered the four functions through a `CfgFunctions` block. That block was removed. It produced `A3ACC_fnc_colourblind_*`, which no call site uses. The call sites use the `FUNC` macro, which expands to `A3ACC_colourblind_fnc_*`. The four functions are compiled by `PREP` in `XEH_PREP.hpp` through `CBA_fnc_compileFunction`, which is the CBA mechanism. A `CfgFunctions` block would compile each file a second time under a dead name.
### 4.4 `addons/colourblind/CfgTests.hpp`

The discovery list from `07-mod-quality-standards.md`, so adding a test file needs no edit to the runner.

```
class A3ACC_Tests {
    palette = QPATHTOF(test_palette.sqf);
    config  = QPATHTOF(test_config.sqf);
    setting = QPATHTOF(test_setting.sqf);
};
```

`config.cpp` includes `CfgMarkerColors.hpp`, `CfgStructuredText.hpp`, `CfgFunctions.hpp` and `CfgTests.hpp` after `CfgEventHandlers.hpp`.

## 5. CBA settings registration

File `addons/colourblind/initSettings.inc.sqf`, included from `XEH_preInit.sqf`. `08-example-mods.md` uses the `initSettings.inc.sqf` name, and `02-cba-and-tooling.md` section 4 says to register in `XEH_preInit.sqf` so the setting appears in Eden. Argument order follows `02` section 2.

```
[
    "A3ACC_CVDMode",                                     // _setting, becomes the global variable
    "LIST",                                              // _settingType
    ["Colour blind mode",                                // _title
     "Select a colour-vision-deficiency palette for map markers."],
    "A3 Accessibility",                                  // _category
    [[0, 1, 2, 3, 4],                                    // _valueInfo
     ["Off", "Protan", "Deutan", "Tritan", "Achromatopsia"],
     0],                                                 // _defaultIndex
    0,                                                   // _isGlobal, client-local
    { [_this] call A3ACC_colourblind_fnc_applyMode },    // _script
    false                                                // _needRestart
] call CBA_fnc_addSetting;
```

- Setting name `A3ACC_CVDMode`. It becomes the global variable, so a read is `missionNamespace getVariable ["A3ACC_CVDMode", 0]`, per `02` section 2.
- Default index 0, which is Off, so the default changes nothing for a player who does not want the feature.
- `_isGlobal = 0`, because the mode is a per-player accessibility preference and a global value would impose one player's mode on every client. `02` section 2 gives `_isGlobal` the default 0 and states that `addSetting` has a local effect.
- Hook: the 7th argument `_script`, not the `CBA_SettingChanged` event. `02` section 3 says "Cleaner for a single setting: pass the 7th argument `_script` to `CBA_fnc_addSetting`. It runs once at init and on every change." The `_script` form also covers the first application at init, which the event alone does not. One setting exists, so one handler is correct. The event name stays unused, and `CBA_SettingsChanged` is a wrong name that must not appear, per `02` section 3. `CBA_fnc_getSetting` must not appear either, because it does not exist, per `02` section 7.
- Titles are plain strings, matching the verified example in `02` section 2. A `stringtable.xml` is deferred.

## 6. Runtime apply, persistence, and degradation
### 6.1 Apply

File `addons/colourblind/functions/fnc_applyMode.sqf`, signature `[modeIndex] -> nothing`.
1. Read the mode. Guard the type and clamp to 0..4.
2. Write the active palette to the global `A3ACC_palette`, the name used by `03-testing.md` section 2. The value is the six-class table for the mode, or `[]` for Off.
3. For each name in `allMapMarkers`, read the current colour name with `getMarkerColor`, which the AEE adapter confirms returns one of the five class names (`05-aee-prior-art.md` section 1).
4. On the first touch of a marker, record `[name, originalColourName]` in the local cache `A3ACC_colourblind_markerCache`. This is the AEE record-and-restore pattern of the AEE `fnc_symbologyMarkersApply` and `fnc_symbologyMarkersRestore`.
5. Resolve the target with `[mode, colourName] call A3ACC_colourblind_fnc_colourNameFor`. An empty result means "leave this marker".
6. Call `setMarkerColorLocal name targetName`. Client-local only, because a global `setMarkerColor` would broadcast one player's palette to every machine, which is wrong for an accessibility setting. The AEE apply pass states the same rule.
7. For Off, write each cached original colour back with `setMarkerColorLocal`, then clear the cache.
### 6.2 New markers

File `addons/colourblind/functions/fnc_watch.sqf`, started from `XEH_postInit.sqf`. This evidence base confirms no marker-created event, so the watcher runs a bounded rescan with `CBA_fnc_waitAndExecute` (used in `05-aee-prior-art.md` section 4) every 2 seconds for the session. Each pass compares `allMapMarkers` with the cached set and recolours only the new names. Cost is one list compare per 2 seconds. Gate the loop on map visibility later if the cost matters.
### 6.3 Persistence

CBA owns it. The setting is registered with `_isGlobal = 0`, so CBA stores the client value in its own settings store and restores it next session. The addon writes nothing to `profileNamespace`. The exact store and its lifetime are UNVERIFIED (section 11 item 9).
### 6.4 Degradation on a raw RGBA marker

`06-arma3-colour-surface.md` section 2 states that a mission can bake a raw RGBA array and that an addon cannot rewrite it. Rule: if `getMarkerColor` returns a name outside the five class names, for example a hex string, then `colourNameFor` returns `""`, the apply pass leaves that marker untouched and writes one RPT line with `diag_log`, once per session per name. The mode still applies to every other marker. One unrecognised marker never blocks the pass, and the pass never throws.

## 7. Test plan, mapped to the four layers of `03-testing.md`
### 7.1 Layer 1, static lint
`hemtt check -p -e`, configured by `.hemtt/lints.toml`. Proves config and SQF parse, with no missing file, invalid value, unknown command, unknown event, version mismatch, or duplicate class. Does not prove runtime behaviour.
### 7.2 Layer 2, config assertions
`hemtt check`, then the in-engine `test_config.sqf`. Proves the config classes and values survive preprocessing and rapify.
### 7.3 Layer 3a, offline unit test
Offline tier: a Python verifier on the two pure functions plus the config. Decision: run the pure tests offline in CI AND as CBA in-engine assertions, because `03-testing.md` section 3 says the highest-value automated test is the pure function. The offline verifier covers the data and the sync; CBA `TEST_OP` covers the real engine.

Pivot: SQF-VM is old and unreliable (it hung on this project), so the offline tier is `tests/verify_palette.py`. It reads the real SQF function and the real `CfgMarkerColors.hpp`, checks the 24 function entries and the 20 config classes are in sync, and recomputes every gated WCAG contrast ratio. It needs no game and no SQF interpreter. `hemtt check` stays the authoritative static gate, and `sqflint` is advisory only.

Cases the verifier checks: 24 well-formed entries; alpha 1 and values in 0..1; the 20 config classes equal the function output; and every gated pair of section 2 meets its 3:1 floor, recomputed in Python, which makes the WCAG rule a machine gate and not a comment.
### 7.4 Layer 3b, in-engine smoke test
Entry point `addons/colourblind/test.sqf`. It reads `A3ACC_Tests` from `configFile`, `execVM`s each path, and `waitUntil { scriptDone _test }`, per `03-testing.md` section 1. It returns `true` when all files pass, per `07-mod-quality-standards.md`. Run it two ways: direct from the debug console as `execVM "z\a3acc\addons\colourblind\test.sqf"`, which is the shared floor that `07` describes, and as `[nil, "colourblind"] call CBA_fnc_test` for convenience. Whether CBA resolves the `z\a3acc` path is UNVERIFIED (section 11 item 7).

`test_palette.sqf` assertions:
- For each mode 1..4 and each class, `TEST_TRUE` that the return is an array of length 4.
- `TEST_OP(str ([1,"friendly"] call A3ACC_colourblind_fnc_paletteForMode), ==, str [0.00,0.35,0.85,1], "protan friendly")`, using the `TEST_OP` form of `03-testing.md` section 1.
- `TEST_OP(str ([3,"objective"] call A3ACC_colourblind_fnc_paletteForMode), ==, str [1.00,0.85,0.00,1], "tritan objective")`.
- `TEST_OP(str ([0,"friendly"] call A3ACC_colourblind_fnc_paletteForMode), ==, str [], "off returns empty")`.
- `TEST_OP([1,"ColorWEST"] call A3ACC_colourblind_fnc_colourNameFor, ==, "A3ACC_ColorWEST_Protan", "name mapping")`.
- `TEST_OP([1,"#A1B2C3"] call A3ACC_colourblind_fnc_colourNameFor, ==, "", "unknown name degrades")`.

`test_config.sqf` assertions, in the `03-testing.md` section 1 query pattern:
- For each of the 20 classes, `TEST_OP(str (getArray (configFile >> "CfgMarkerColors" >> _class >> "color")), ==, str _expected, _class)`. This is the config-versus-function sync gate of decision B.
- For each of the 20 classes, `TEST_TRUE` that `getNumber (configFile >> "CfgMarkerColors" >> _class >> "scope") > 0`, so the marker-colour picker builds, per the AEE probe in `05-aee-prior-art.md` section 4.
- For each of the 20 classes, `TEST_TRUE` that `count color == 4`, which also catches the file-root forward-declaration trap.
- `TEST_TRUE` that `configFile >> "RscStructuredText"` still resolves, so the forward declaration did not empty it.
- `TEST_TRUE` that `A3ACC_RscStructuredText` resolves and carries a 4-element `colorBackground[]`.

`test_setting.sqf` assertions:
- `TEST_OP(["A3ACC_CVDMode"] call CBA_settings_fnc_get, ==, 0, "default is Off")`, using the getter named in `02-cba-and-tooling.md` section 2.
- `TEST_TRUE` that `!(isNil "A3ACC_CVDMode")`.
- `TEST_TRUE` that `missionNamespace getVariable ["A3ACC_palette", []]` has six entries after `[1] call A3ACC_colourblind_fnc_applyMode`.
- `TEST_TRUE` that the palette global is `[]` after `[0] call A3ACC_colourblind_fnc_applyMode`.
- `TEST_TRUE` that a marker created with `setMarkerColorLocal "ColorWEST"` and then recoloured with mode 1 reports `getMarkerColor == "A3ACC_ColorWEST_Protan"`.
### 7.5 Layer 4, manual QA
Steps written to `docs/QA-colourblind.md` and run with `hemtt launch`. `08-example-mods.md` section 3 gives the launch profile shape, and `.hemtt/project.toml` already carries the CBA workshop id `450814997`.
1. Launch with the HEMTT default profile.
2. Place one marker of each of the five classes in Eden.
3. Open the CBA settings menu. Confirm the five mode names and the Off default.
4. Select each mode in turn. Confirm the five markers change, and that no marker stays vanilla.
5. Select Off. Confirm every marker returns to its vanilla colour.
6. Create a new marker while a non-Off mode is active. Confirm the watcher recolours it within 2 seconds.
7. Run a mission that sets a marker with a raw array. Confirm the marker is untouched, the other markers still change, and one RPT line records the skip.
8. Check the RPT for `Error` and for `Updating base class`. Both must be absent.
9. View each palette through a CVD simulator and confirm the gated pairs stay distinct. This is the only check of the rendered colour, because `03` section 2 states that the rendered pixel is not observable to an automated test.
### 7.6 CI workflow
File `.github/workflows/ci.yml`, job `build`, on push and pull request. Steps from `07-mod-quality-standards.md` and `05-aee-prior-art.md` section 5:
1. `actions/checkout`.
2. `arma-actions/hemtt@v1` to install HEMTT.
3. `hemtt check -p -e`.
4. `.hemtt/scripts/check_prefixes.rhai`, from `08-example-mods.md` item 9, which catches a missing `$PBOPREFIX$`.
5. `arma-actions/bom-check`.
6. Run `python3 tests/verify_palette.py` and require exit 0.
7. `hemtt build`.
8. `actions/upload-artifact` with `include-hidden-files: true`.

Layers 3b and 4 stay manual, because no maintained action runs the Arma 3 client in CI (`03` section 5). The Docker soak harness of `05-aee-prior-art.md` section 4 is deferred, and it must only run on a self-hosted runner from `schedule` or `workflow_dispatch`, never on a public pull request.

## 8. File tree to create

```
addons/colourblind/functions/fnc_paletteForMode.sqf   pure table and lookup, [mode, class] -> RGBA
addons/colourblind/functions/fnc_colourNameFor.sqf    pure, [mode, engine colour name] -> addon class name
addons/colourblind/functions/fnc_applyMode.sqf        impure, recolours allMapMarkers, writes the palette global
addons/colourblind/functions/fnc_watch.sqf            impure, 2-second rescan for new markers
addons/colourblind/CfgMarkerColors.hpp                20 named marker colours, AEE shape, 4 modes x 5 classes
addons/colourblind/CfgStructuredText.hpp              one addon-owned structured-text control
addons/colourblind/CfgFunctions.hpp                   registers the four public functions
addons/colourblind/CfgTests.hpp                       A3ACC_Tests discovery list for the in-engine runner
addons/colourblind/initSettings.inc.sqf               the single CBA LIST setting and its _script hook
addons/colourblind/test.sqf                           in-engine entry point, iterates A3ACC_Tests
addons/colourblind/test_palette.sqf                   CBA assertions on the two pure functions
addons/colourblind/test_config.sqf                    CBA assertions on configFile and the sync gate
addons/colourblind/test_setting.sqf                   CBA assertions on the setting and the palette global
tests/verify_palette.py                              offline palette and sync verifier
.hemtt/lints.toml                                     enables sqf.undefined and sqf.not_private
.hemtt/scripts/check_prefixes.rhai                    fails CI when a $PBOPREFIX$ is missing
.github/workflows/ci.yml                              lint, prefix check, BOM check, SQF-VM, build, artifact
.editorconfig                                         lf, utf-8, 4-space indent, trim trailing whitespace
docs/QA-colourblind.md                                the nine manual QA steps
```

Files to change: `config.cpp` to include the four new hpp files, `XEH_preInit.sqf` to include `initSettings.inc.sqf`, `XEH_PREP.hpp` to list the four functions, and `XEH_postInit.sqf` to start `fnc_watch`. No change to `addons/main/`, because the `PATHTOF_FNC` macro is not needed.

## 9. Ordered task list

Task 1 has no dependency. Tasks 2 and 3 depend on 1. Task 4 depends on 1. Task 5 depends on 2 and 4. Task 6 depends on 5. Task 7 depends on 2, 4, 5 and 6. Task 8 depends on 1. Task 9 depends on 1, 7 and 8. Task 10 depends on 5.

## Todos

- [ ] 1. Write the pure palette function and the pure name mapper.
  - Acceptance: `fnc_paletteForMode.sqf` returns the exact values of sections 2.3 to 2.5 for modes 1..4 and all six classes, and `[]` for mode 0 or an unknown class. `fnc_colourNameFor.sqf` returns the exact class name of section 4.1, and `""` for mode 0 or an unrecognised name. Neither file reads a global or a config.
  - QA: `[1,"friendly"] call A3ACC_colourblind_fnc_paletteForMode` in the debug console returns `[0,0.35,0.85,1]`. Evidence is the RPT line from the console.
  - Commit: `colourblind: add pure mode-to-colour mapping`.
- [ ] 2. Add `CfgMarkerColors.hpp` with the 20 named classes.
  - Acceptance: 20 classes exist. Each inherits `Default`, sets `scope = 1` and a 4-element `color[]`, and matches sections 2.3 to 2.5.
  - QA: `hemtt check -p -e` exits 0. Evidence is the CI log.
  - Commit: `colourblind: add per-mode marker colour classes`.
- [ ] 3. Add `CfgStructuredText.hpp` with the addon-owned control.
  - Acceptance: `RscStructuredText` is forward-declared at the same scope, and `A3ACC_RscStructuredText` inherits it with a 12.6:1 text pair.
  - QA: `hemtt check -p -e` is clean, with no `L-C03` or `L-C04`.
  - Commit: `colourblind: add accessible structured-text control`.
- [ ] 4. Register the CBA setting.
  - Acceptance: `A3ACC_CVDMode` is a LIST with the five names of section 2.1, default index 0, `_isGlobal = 0`, and the `_script` hook. The strings `CBA_SettingsChanged` and `CBA_fnc_getSetting` appear nowhere in the repo.
  - QA: in Eden the setting appears under `A3 Accessibility` with five entries. Evidence is a screenshot in the PR.
  - Commit: `colourblind: register the CVD mode setting`.
- [ ] 5. Write the apply function, the cache, and the Off restore.
  - Acceptance: a mode change recolours every marker whose name is one of the five class names. Off restores every original name. An unrecognised name is skipped and logged once. No global marker command is called.
  - QA: change the setting in game, confirm the markers change, then confirm Off restores them. Evidence is the RPT and the QA checklist.
  - Commit: `colourblind: apply the mode to map markers`.
- [ ] 6. Write the watcher and start it in postInit.
  - Acceptance: a marker created after the apply pass is recoloured within 2 seconds, and the loop does not re-run work for a known marker.
  - QA: create a marker in Eden while mode 1 is active and confirm the change within 2 seconds. Evidence is the QA checklist.
  - Commit: `colourblind: recolour newly created markers`.
- [ ] 7. Write the three in-engine test files and `test.sqf`.
  - Acceptance: `test.sqf` iterates `A3ACC_Tests`, waits for each script, and returns `true` only when all pass. Every assertion of section 7.4 passes.
  - QA: `execVM "z\a3acc\addons\colourblind\test.sqf"` in the debug console, then read the RPT for `TEST_SUCCESS` lines and for zero failures.
  - Commit: `colourblind: add in-engine test suite`.
- [ ] 8. Write the SQF-VM runner.
  - Acceptance: `python3 tests/verify_palette.py` exits 0 and reports the 24 entries, the 20 classes in sync, and every gated pair at or above 3:1.
  - QA: run SQF-VM locally with the include path set to `include/`. The output has no `[FAIL]` line. Evidence is the local output and the CI log.
  - Commit: `tests: add offline palette runner`.
- [ ] 9. Add the CI workflow, the lint config, and the prefix check.
  - Acceptance: CI runs on push and pull request and passes all eight steps of section 7.6. A deliberately broken prefix fails the run.
  - QA: push a branch and read the CI result. Evidence is the CI run URL.
  - Commit: `ci: gate lint, SQF-VM and build`.
- [ ] 10. Write the manual QA checklist and the UNVERIFIED register.
  - Acceptance: `docs/QA-colourblind.md` holds the nine steps of section 7.5 and the list of section 11.
  - QA: a second person runs the checklist without asking a question.
  - Commit: `docs: add colour-blind QA checklist`.

## Final verification wave

- [ ] F1. Verify the palette gates numerically. Recompute the WCAG relative-luminance ratio for every mode and every gated pair of section 2, from the values read out of `configFile` in game. Every ratio must meet its stated minimum.
- [ ] F2. Verify the config-to-function sync for all 20 classes. Run `test_config.sqf` and confirm zero failures. A changed value in either copy must fail the run.
- [ ] F3. Verify the Off restore on a live marker set. Cycle Off to Protan and back on a mission with five class markers and one raw-array marker. Every named marker returns to vanilla, and the raw marker never moves.
- [ ] F4. Verify the RPT is clean. No `Error`, no `Updating base class`, and no warning outside the benign allowlist named in `05-aee-prior-art.md` section 4.

## 10. Acceptance criteria for the slice

1. `hemtt check -p -e` and `hemtt build` pass on Linux.
2. The SQF-VM run and the in-engine run both report zero failures.
3. All 20 `CfgMarkerColors` entries equal the pure function output.
4. The setting default is Off, and Off changes no marker.
5. Each of the four modes recolours all five verified class names.
6. Every gated pair of section 2 meets its stated ratio.
7. The RPT carries no error.

## 11. UNVERIFIED, and what must be checked first

From `06-arma3-colour-surface.md` section 6 and the other docs.
1. Whether Arma 3 has a native colour-blind setting. `06` section 4 says UNCONFIRMED. Check Options, Video and Game, in game.
2. The vanilla `CfgMarkerColors` class list and values. `06` section 6 item 4. Read the BIKI in a normal browser and dump the config from a game install.
3. The colour keys of `CfgInGameUI`. `06` section 1 marks them UNVERIFIED. This slice does not override them.
4. Whether `setMarkerColorLocal` accepts an RGBA array as well as a name. The BIKI returned 403. This slice uses names only, so the design does not depend on it.
5. Whether `getMarkerColor` returns a name for a marker whose colour came from a raw array. Check in game. Section 6.4 assumes it may return a non-name, and degrades.
6. The engine class that carries objective markers. `06` section 1. The objective class has palette values but no config entry until this is known.
7. Whether `CBA_fnc_test` resolves the `z\a3acc` addon path. `03` section 1 shows a `\x\<addon>\` path. Check in game. The debug-console `execVM` path is the fallback and is already the documented floor.
8. The SQF-VM command-line flags, its include-path flag, and its exit-code behaviour. `03` section 6. Check with `--help` and `help__` against the built binary.
9. The CBA settings persistence store and its lifetime. `02` section 2 names the sources but not the store. Check in game across two sessions.
10. Control of marker icon shape and outline weight. `01` section 3 makes these the carrier for the achromatopsia mode, and `05` section 3 records the marker texture aspect limit. This is the largest gap in the achromatopsia mode.
11. Whether `CfgMarkers` icon shape differences are addon-overridable for vanilla icons. `04` marks this INFERRED.
12. Whether the engine logs `Updating base class` for a parentless reopen, and whether the HEMTT `L-C03` and `L-C04` lints catch the file-root forward-declaration trap. `05` section 3. Confirm with a deliberate bad config, then revert.

## 12. Roadmap, noted and not planned

From `04-accessibility-features.md`. Not part of this slice: remappable controls through `CBA_fnc_addKeybind`, objective and control reminders as a persistent structured-text HUD, the marker icon shape layer that section 2.5 depends on, high-contrast mode with its vanilla-restyle caveat, text size and subtitle styling and the dyslexia-friendly font limited to the addon's own UI, the Docker headless soak harness on a self-hosted runner only, and a `stringtable.xml` plus `CONTRIBUTING.md` with the PR template.
