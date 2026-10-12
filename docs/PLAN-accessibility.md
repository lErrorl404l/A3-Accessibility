# A3 Accessibility - whole-addon accessibility roadmap

Status: decision complete for planning. No implementation is authorised by this file.
Scope: every addon-able accessibility feature, grouped by impairment.
Evidence base: `docs/research/11-config-sweep.md` (3453 colour properties, in-engine),
`docs/research/12-command-capability.md` (32 commands accepted in-engine on an Arma 3 2.20
dedicated server), `docs/research/10-colour-surface-dump.md`, `docs/research/01` to `09`,
and `docs/PLAN.md` (the plan of record). British English. ASD-STE100. ASCII only.

Companion: `docs/PLAN-colour-surface.md` holds the colour-surface design in full. That
design is shipped. This file is the roadmap for everything else.

## 1. What is already shipped, and must not be re-planned

Two features are done. Both are the pattern the rest of this roadmap copies.

| Shipped feature | Files | Gate that holds it |
|---|---|---|
| Colour-vision modes over markers and the fixed-name colour surface | `CfgMarkerColors.hpp`, `CfgInGameUI.hpp`, `CfgNotifications.hpp`, `CfgStructuredText.hpp`, `fnc_paletteForMode.sqf`, `fnc_colourNameFor.sqf`, `fnc_applyMode.sqf`, `fnc_watch.sqf` | `tests/verify_palette.py` offline, `tests/ingame` in-engine |
| Camera-shake reduction | `functions/fnc_applyMotion.sqf`, the `A3ACC_ReduceMotion` checkbox in `initSettings.inc.sqf`, `XEH_PREP.hpp` | in-engine `TEST_OP` on the setting, client QA |

`fnc_applyMotion.sqf` is the template for every feature in this roadmap:

1. A pure or near-pure function that takes one argument and writes one effect.
2. One CBA setting in `initSettings.inc.sqf`, `_isGlobal = 0`, and the 7th argument
   `_script` as the hook.
3. The effect is client-local. The function calls `enableCamShake`, which is a client
   effect, and never broadcasts.
4. The Off or false branch restores the vanilla behaviour. `resetCamShake` does that.
5. `XEH_PREP.hpp` lists the function. The in-engine suite asserts the setting exists and
   holds a valid value.

Every feature below reuses that shape. A feature that cannot restore its vanilla behaviour
does not ship.

## 2. How to read the roadmap

Each feature has an identifier, the exact mechanism, the value or behaviour, the risk of
breaking the game, a verification gate, and a client-test flag.

Gate types, so the worker needs no judgement call:

| Gate | Meaning | Where it runs |
|---|---|---|
| `G-OFF` | offline assertion in a Python verifier, no game needed | CI |
| `G-ENG` | in-engine assertion on the dedicated server | `tests/ingame` |
| `G-CLI` | rendered or interactive result, a person must look | `docs/QA-accessibility.md` |
| `G-PROBE` | the mechanism is UNVERIFIED. Probe it in-engine before any feature code is written | `tests/ingame` |

A `G-PROBE` feature is not built until its probe passes. The probe is a task in its own
right, and its result is recorded in `docs/QA-accessibility.md`.

Risk levels are stated as LOW, MEDIUM or HIGH. HIGH means the feature can change how the
game plays, not only how it looks, so it is off by default and carries a fairness note.

## 3. Group H - hearing

The engine exposes no command to read a sound event (`12-command-capability.md`). A cue or
a caption therefore comes from gameplay events, not from the audio mixer. Coverage is
finite by construction, and the roadmap states that in the addon's own accessibility note.

Sources for this group: the BI wiki snapshots for `SoundPlayed`, `FiredNear`, `Suppressed`,
`MusicStart`/`MusicStop`, `showSubtitles`, `getSubtitleOptions`, `Description.ext`
(`CfgRadio`, `CfgSounds`, `CfgSentences`) and `BIS_fnc_showSubtitle`.

| ID | Feature | Exact mechanism | Value or behaviour | Risk | Gate | Client test |
|---|---|---|---|---|---|---|
| H1 | Directional sound cue | Object event handlers `addEventHandler ["FiredNear", ...]` with payload `_unit, _firer, _distance, _weapon, _muzzle, _mode, _ammo`, `["Explosion", ...]`, `["Suppressed", ...]` (distance only), and `["SoundPlayed", ...]` (id 1 to 15, breath and injury only). Direction is computed by the addon from `getPosASL` and `vectorDir`. The cue is placed with `playSound3D` | On a firing, explosion or hit event within a radius, play a short cue at the source position. Radius is a setting, default 300 m. No event carries an azimuth, so the addon computes it | MEDIUM. `playSound3D` is a real sound, so it enters the mix and can mask the vanilla audio the player relies on | `G-PROBE` then `G-ENG`: assert each handler registers and fires on a scripted shot. `G-CLI`: confirm the direction reads correctly | yes |
| H2 | Caption line for non-speech audio | The same events, plus `cutRsc` with an addon `RscTitles` class. For the addon's own sounds, `CfgSounds >> <class> >> titles[]` renders the caption with no script | One short caption line per event, for example `GUNFIRE, LEFT, 200 M`. The table is finite and documented. `FiredNear` gives distance, not direction, so the direction word comes from the computed vector of H1 | LOW for the addon's own display. It draws over the game, so it can obscure the view if placed badly | `G-PROBE` on `cutRsc` and the `RscTitles` shape, then `G-ENG`, then `G-CLI` | yes |
| H3 | Caption size, colour and background | `CfgSounds >> <class>` keys `titlesFont`, `titlesSize`, `titlesStructured` and `forceTitles`. Addon `RscTitles` and `RscStructuredText` with `sizeEx`, `font`, `colorText[]`, `colorBackground[]`. Runtime `ctrlSetFont` and `ctrlSetFontHeight` | `colorText[]` at or above 4.5:1 against `colorBackground[]`. Background at least 60 percent opaque. `forceTitles = 0`, so the player's own subtitle option still decides | LOW | `G-OFF`: the offline verifier recomputes the WCAG ratio and fails below 4.5:1 | no |
| H4 | Vanilla subtitle restyle | The engine subtitle control is reachable. `BIS_fnc_showSubtitle` runs `cutRsc ["RscDynamicText", "PLAIN"]`, stores the display in the `uiNamespace` variable `BIS_dynamicText`, and writes control idc 9999. The addon re-skins that control with `ctrlSetFont` and `ctrlSetFontHeight` | A player-chosen font and text height for the game's own subtitles. The function re-creates the control on every call, so the addon must re-apply after each call | MEDIUM. Hooking a vanilla function is a compatibility risk. A wrong idc or a missed re-apply leaves the vanilla style | `G-PROBE` that `RscDynamicText` resolves and idc 9999 exists, then `G-CLI` that the restyle survives a second subtitle | yes |
| H5 | Mono audio downmix | None. The engine exposes no downmix command and no channel matrix. `getAudioOptionVolumes` returns six volume factors only | Excluded. The operating system or driver owns this | Not applicable | Not applicable | no |
| H6 | Text to speech of captions | `callExtension` to a small signed extension, Windows SAPI | Speak each caption line. Needs a compiled, signed, BattlEye-safe binary | HIGH. A binary dependency, Windows only, and a signing key | `G-PROBE` on `callExtension` loading, then `G-CLI` | yes |
| H7 | Subtitle state control | `showSubtitles Bool`, `getSubtitleOptions`, `shownSubtitles`, `enableRadio Bool`, `enableSentences Bool` | Force subtitles on for the player who wants them, and report the current state. `enableSentences false` removes the radio chatter sentences, which is also a clutter feature of C2 | LOW. It changes only the local player's own display | `G-ENG`: assert `showSubtitles true` returns the prior value and `getSubtitleOptions` reports the new state. `G-CLI` | yes |

## 4. Group M - motor

The verified motor commands are `forceWalk`, `allowSprint` and `setCustomAimCoef`
(`12-command-capability.md`). They are gameplay levers, not input remapping.
`12-command-capability.md` also states plainly that Arma exposes no command to add a
toggle for a held key. So a toggle is built for the addon's own actions only.

Sources for this group: the CBA_A3 `fnc_addKeybind` and `fnc_getKeybind` sources, the BI wiki
snapshots for `BIS_fnc_holdActionAdd`, `BIS_fnc_holdActionRemove`, `ctrlSetPosition`,
`ctrlSetFontHeight`, `difficultyOption`, `Arma_3:_Difficulty_Settings` and the GUI
configuration page, and shipped mod configs for `CfgDifficultyPresets` and
`CfgDefaultKeysPresets`.

| ID | Feature | Exact mechanism | Value or behaviour | Risk | Gate | Client test |
|---|---|---|---|---|---|---|
| M1 | Remappable addon controls | `CBA_fnc_addKeybind` with its full argument list: `[addon, action, title, downCode, upCode, defaultKeybind, holdKey, holdDelay, overwrite]`. `title` is a string or `[displayName, tooltip]`. `defaultKeybind` is `[DIK, [shift, ctrl, alt]]`. Read a binding back with `["a3acc", "action"] call CBA_fnc_getKeybind`. Needs `#include "\a3\ui_f\hpp\defineDIKCodes.inc"` | Every addon action is a keybind. The default is unbound, `[0, [false, false, false]]`, so nothing changes for a player who does not want it. CBA also accepts mouse codes `0xF0` to `0xF9` and user actions `0xFA` to `0x10D` | LOW. A keybind with no default cannot collide | `G-ENG`: assert the keybind registers and `CBA_fnc_getKeybind` returns the action. `G-CLI`: press the key and confirm the action | yes |
| M2 | Reduced repeated input | `CBA_fnc_addKeybind` arguments `holdKey` (Boolean, fires the down code every frame while held) and `holdDelay` (Number seconds). For an interaction, `BIS_fnc_holdActionAdd` with its 16 arguments, where `conditionProgress` returning false pauses the progress | The player holds one key, or holds one interaction, instead of repeating a press. A toggle is a keybind plus a mission-namespace Boolean | LOW | `G-ENG`: assert the keybind registers with `holdKey` and the hold action is added and then removed. `G-CLI` | yes |
| M3 | Larger interaction targets | Config `RscText`, `RscButton`, `RscStructuredText`, `RscTitles` with `idc`, `style`, `font`, `x`, `y`, `w`, `h`, `sizeEx`, `lineSpacing`, `fixedWidth`, `shadow`, `colorShadow[]`. Runtime `ctrlSetPosition [x, y, w, h]` in the 2D form, then `ctrlCommit`, and `ctrlSetFontHeight size`. The action-menu icon size is `CfgInGameUI >> DefaultAction >> size` | A minimum target of 44 by 44 pixels at 1080p, per XAG 101. `ctrlSetFontH` does not exist, so the height command is `ctrlSetFontHeight` | LOW for the addon's own UI. Vanilla controls are out of reach except the action icon | `G-OFF` on the config values, `G-ENG` that `ctrlSetFontHeight` returns the new height, `G-CLI` on the rendered size | yes |
| M4 | Reduced movement demand | `forceWalk` and `allowSprint`, both Boolean | Optionally hold a walk, or remove the need to hold a key to sprint | HIGH. It changes movement, it is visible to other players, and a mission may depend on sprint. Multiplayer fairness risk. Default off | `G-PROBE` on semantics, `G-ENG` on acceptance, `G-CLI` | yes |
| M5 | Aim assistance | No engine command exists. `setAimAssist` is absent. The nearest reachable control is the difficulty options `visionAid` and `weaponCrosshair` of M6. `setCustomAimCoef` is verified available but its semantics are not | Reduce the demand for precise aim | HIGH. A competitive advantage in multiplayer. Default off | `G-PROBE` on `setCustomAimCoef` semantics first. If the probe is unclear, the feature does not ship | yes |
| M6 | Difficulty and assist presets | `CfgDifficultyPresets` with `defaultPreset` and a class that inherits `Custom`, holding `displayName`, `description`, `optionDescription`, `levelAI` and `class Options`. `class Flags` was renamed to `class Options` in 1.58. Options include `visionAid`, `weaponCrosshair`, `thirdPersonView`, `cameraShake`, `staminaBar`, `groupIndicators`, `friendlyTags`, `enemyTags`. Read with `difficultyOption "friendlyTags"`. `difficultyEnabled` is obsolete and always returns false | One accessibility-oriented preset that a player selects in Options. There is NO scripting command that sets a preset. The server config parameter `forcedDifficulty` sets it. A mission `Description.ext >> showHUD[]` disables the `showHUD` command entirely | HIGH. A preset override is global, it applies to every mission, and the merge is last-loaded-wins | `G-PROBE` on the merge and on `forcedDifficulty`, then `G-OFF` on the config, then `G-CLI` | yes |
| M7 | Remappable native keys and keybind presets | `CfgDefaultKeysPresets` with `class Mappings`, and a mapping word of the form `0xaaBBccDD`. Action declarations live in `CfgDefaultKeysMapping` | Ship an accessibility-oriented key preset for the native actions | MEDIUM. A preset override can clash with another mod's preset, and the merge order decides | `G-PROBE` that the preset reaches the vanilla mappings, then `G-OFF` on the config, then `G-CLI` | yes |

## 5. Group C - cognitive

Sources for this group: the BI wiki snapshots for `BIS_fnc_taskState`, `BIS_fnc_taskExists`,
`BIS_fnc_taskDescription`, `BIS_fnc_taskCurrent`, `BIS_fnc_taskHint`, `taskHint`, `showHUD`,
`shownHUD`, `setGroupIconsVisible`, `showScoretable`, `BIS_fnc_advHint`, `BIS_fnc_rscLayer`,
`cutRsc`, `displayAddEventHandler` and `BIS_fnc_countdown`.

| ID | Feature | Exact mechanism | Value or behaviour | Risk | Gate | Client test |
|---|---|---|---|---|---|---|
| C1 | Persistent objective HUD | Read the task with `[taskName] call BIS_fnc_taskState`, `[taskName] call BIS_fnc_taskExists`, `taskName call BIS_fnc_taskDescription`, `unit call BIS_fnc_taskCurrent`. Draw with an `RscTitles` class that has `idd = -1`, `duration = 1e10`, `fadeIn = 0`, `fadeOut = 0`, shown with `(("TAG_a3acc_hud" call BIS_fnc_rscLayer)) cutRsc ["A3ACC_ObjectiveHUD", "PLAIN", 0, false]` and updated with `disableSerialization` then `(uiNamespace getVariable "BIS_InfoText") displayCtrl 1 ctrlSetStructuredText parseText "..."` | A small always-on panel that lists the current task and the next step, so a player who loses the brief can recover it. Note that `taskState` takes a Task handle and `BIS_fnc_taskState` takes a String ID. They are not interchangeable | MEDIUM. A permanent panel covers the view. It must be movable and hideable | `G-PROBE` on `BIS_fnc_rscLayer`, `cutRsc` and `BIS_fnc_taskState`, then `G-ENG`, then `G-CLI` | yes |
| C2 | Reduced clutter | `showHUD` in its array form: `[scriptedHUD, info, radar, compass, direction, menu, group, cursors, panels, kills, showIcon3D]`. Read the state back with `shownHUD`. Also `setGroupIconsVisible [showOnMap, showOnHUD]`, `setGroupIconsSelectable`, `enableSentences false`, `showScoretable force` with 1 visible and 0 invisible | One toggle hides the group icons, the map indicators, the radio chatter sentences and the chosen HUD panels. `showIcon3D` stays true, so `drawIcon3D` markers remain visible while the HUD is hidden | MEDIUM. It removes information, so it can hide a contact the player needs. A mission `Description.ext >> showHUD[]` disables the command entirely | `G-ENG` on acceptance of each command with its argument and on `shownHUD` reporting the new state, `G-CLI` on playability | yes |
| C3 | Reminder prompt for the addon's own features | `taskHint [text, colour, icon]`, where `icon` is `"taskNew"`, `"taskCurrent"`, `"taskDone"` or `"taskFailed"`. Also `[taskName, taskState] call BIS_fnc_taskHint` | A one-line prompt when an addon feature becomes relevant, for example the caption toggle | LOW | `G-ENG` plus `G-CLI` | yes |
| C4 | Tutorial and help overlay | `CfgHints` with a class per hint, and `BIS_fnc_advHint` with its nine arguments. The `showing` argument set to true pushes the hint even when the player has tutorial hints off. The addon's own help screen is an `RscTitles` class shown through `BIS_fnc_rscLayer` and `cutRsc` | One screen that explains every addon feature and its setting | LOW. `BIS_fnc_advHint` is gated by the player's tutorial setting unless `showing` is true | `G-PROBE` on `CfgHints` and `BIS_fnc_advHint`, then `G-ENG`, then `G-CLI` | yes |
| C5 | No time pressure | `BIS_fnc_countdown` with a larger value extends a running countdown, and `-1` clears it. There is no command that pauses one | Extend or clear a mission countdown that the mission itself started | MEDIUM. It changes mission timing, so it must be an explicit player choice, and the global form writes `serverTime` | `G-PROBE` on extend and clear, then `G-CLI`. Never on by default | yes |
| C6 | Keyboard access to every addon action | `findDisplay 46 displayAddEventHandler ["KeyDown", { ... }]`, plus the M1 keybinds | Every addon action is reachable from the keyboard with no mouse | LOW | `G-ENG` that the handler registers and returns an index, `G-CLI` | yes |

## 6. Group LV - low vision

The font surface is fully documented in
`/ext/Development/AEE/docs/wiki/research/arma-font-surface.md`, graded S against the shipped
engine config on this machine.

| ID | Feature | Exact mechanism | Value or behaviour | Risk | Gate | Client test |
|---|---|---|---|---|---|---|
| LV1 | Text size for the addon's own UI | `CfgFontFamilies` with `fonts[]`, one entry per point size. Controls set `font` and `sizeEx`. Runtime `ctrlSetFont` with a `CfgFontFamilies` class name and `ctrlSetFontHeight size` for the height. `ctrlFontHeight` is the getter. No `setFont` command exists | Ship a family at three point sizes and let the player choose. Target XAG 101: 26 pixels at 1080p | MEDIUM. Bitmap fonts do not scale. A `.fxy` plus `.paa` set exists per size only, so a missing size renders nothing. No global UI scale command exists, so scaling is per control or per structured-text fragment | `G-OFF` on the config shape, `G-ENG` that the family resolves and `ctrlSetFontHeight` returns the new height, `G-CLI` that the text renders at the chosen size | yes |
| LV2 | Map label and marker legibility | `RscMapControl` `fontGrid`, `sizeExGrid`, `colorGrid[]`, `colorGridMap[]`. Runtime `setMarkerSize` and `setMarkerAlpha`, both verified | Larger grid labels and larger, fully opaque markers. `setMarkerAlpha` at 1 | MEDIUM. `setMarkerSize` changes the map's look and can overlap markers. `colorGrid[]` is a load-time override only, because no script command repoints `fontGrid` | `G-ENG` on `setMarkerSize` and `setMarkerAlpha` acceptance, `G-OFF` on the config, `G-CLI` | yes |
| LV3 | View distance | `setViewDistance`, `setObjectViewDistance`, `setTerrainGrid`, all verified | Raise the view distance for legibility | HIGH. A longer view distance is a competitive advantage and a frame-rate cost. `setTerrainGrid` changes terrain detail. Default off | `G-ENG` on acceptance, `G-CLI` on the frame rate and the look. A fairness note in `ACCESSIBILITY.md` | yes |
| LV4 | High-contrast mode for the addon's own UI | `RscStructuredText` and `RscText` `colorText[]` and `colorBackground[]` | Text at 4.5:1 or better, non-text at 3:1 or better | LOW | `G-OFF`: the offline verifier recomputes every ratio and fails below the floor | no |
| LV5 | Dyslexia-friendly font | `CfgFontFamilies` plus `ctrlSetFont`. Assets built with `FontToTGA` from Arma 3 Tools on Windows, or `hemtt utils paa convert` on Linux | Ship one SIL OFL family and apply it to the addon's own controls | HIGH. Asset risk. The `.fxy` structure is undocumented, the atlas is DXT5, a missing glyph is invisible, and the family licence must ship beside it | `G-OFF` that the family and its licence are present, `G-CLI` that every glyph renders | yes |
| LV6 | Restyle of the vanilla menus and HUD text | None confirmed. A wholesale vanilla `RscDisplay*` restyle is not guaranteed (`04-accessibility-features.md`) | Excluded. The addon styles only what it owns | Not applicable | Not applicable | no |

## 7. Group MP - motion and photosensitivity

| ID | Feature | Exact mechanism | Value or behaviour | Risk | Gate | Client test |
|---|---|---|---|---|---|---|
| MP1 | Camera-shake reduction | DONE. `enableCamShake false` and `resetCamShake` in `fnc_applyMotion.sqf`, plus `setCamShakeDefParams` | The shipped call passes seven numbers, each 0.01, because HEMTT rejects any other arity. The BI wiki documents `setCamShakeDefParams` as having no effect in Arma 3, so `enableCamShake false` is the effective lever | LOW. Shipped and gated | existing in-engine assertion | yes |
| MP2 | Flash and brightness reduction | `setAperture value` and `setApertureNew [minimum, standard, maximum, luminance]`. Both are camera exposure, not post-process | Clamp the exposure so a bright flash cannot spike. `setAperture` must run after mission start, for example `0 spawn { sleep 0.1; setAperture 50 };`. Run `setApertureNew` after `setAperture`, because `setAperture` also forces a `setApertureNew` range under HDR. `setApertureNew [-1]` resets | MEDIUM. It changes the brightness of the whole screen, so it can make night unplayable. It must be a bounded range, not a fixed value | `G-PROBE` on the safe range, `G-ENG` on acceptance, `G-CLI` on day and night readability | yes |
| MP3 | Post-process strength reduction | `ppEffectCreate [name, priority]` returns a handle or -1. Adjust with `ppEffectAdjust`, apply with `ppEffectCommit`, hold with `ppEffectEnable`, release with `ppEffectDestroy`. The accepted names include `ColorCorrections`, `FilmGrain`, `DynamicBlur`, `RadialBlur` and `ChromAberration` | A `ColorCorrections` effect at a low brightness damps the vanilla flash and bloom | HIGH. A post-process touches the whole picture and costs frame rate. **This is brightness only. It must never be a colour-simulation filter.** `01-cvd-types.md` section 4 forbids a filter that simulates CVD | `G-PROBE` on the handle, the priority and a clean destroy, then `G-CLI`. The offline verifier asserts that no colour matrix is present in the source | yes |
| MP4 | Motion blur and film grain removal | `ppEffectCreate` with the `FilmGrain` and `DynamicBlur` names, then `ppEffectAdjust`, `ppEffectEnable`, `ppEffectCommit` and `ppEffectDestroy` | Neutralise the vanilla motion blur and grain | MEDIUM to HIGH. A stuck effect is worse than the blur, and a priority already in use fails creation | `G-PROBE` first. If the handle cannot be adjusted and released cleanly, the feature does not ship | yes |
| MP5 | Field of view | `camSetFov level`, with `camPrepareFov`, `camSetFovRange` and `camCommitFov`. FOV is per camera only, and a commit is required | Widen or narrow the camera field of view for a custom camera. There is no global FOV command | MEDIUM. Some seats and views override the camera, so a camera-level change is not a monitor-level one | `G-PROBE` first, then `G-CLI` | yes |
| MP6 | Head bob and weapon sway reduction | `setCustomAimCoef` is verified but its semantics are not | Reduce the sway | HIGH. Same fairness concern as M5 | `G-PROBE` first. Shared with M5 | yes |

## 8. Component and setting layout

Add one new component. Do not move shipped code.

```
addons/accessibility/$PBOPREFIX$                 z\a3acc\addons\accessibility
addons/accessibility/config.cpp                  CfgPatches plus the new headers
addons/accessibility/script_component.hpp        COMPONENT accessibility
addons/accessibility/CfgEventHandlers.hpp        preStart, preInit, postInit
addons/accessibility/XEH_PREP.hpp                one PREP per new function
addons/accessibility/XEH_preInit.sqf             PREP, then initSettings.inc.sqf
addons/accessibility/XEH_postInit.sqf            start the keybinds and the watchers
addons/accessibility/initSettings.inc.sqf        one CBA setting per feature
addons/accessibility/functions/fnc_*.sqf         one function per feature
addons/accessibility/CfgTitles.hpp               the addon caption and objective displays
addons/accessibility/CfgFontFamilies.hpp         the low-vision families
addons/accessibility/CfgTests.hpp                the discovery list for the new tests
addons/accessibility/test_*.sqf                  the in-engine assertions
```

`addons/colourblind` is untouched. It keeps the colour work and the shipped camera-shake
feature. The component name is now narrow for what it holds. A rename is deliberately not
planned, because it would move a shipped CBA settings category, the shipped test paths and
the shipped PBO prefix. Record the naming debt in `CHANGELOG.md` instead.

Setting names, one per feature, all `_isGlobal = 0` and all default off or default vanilla:

| Setting | Type | Default | Hook |
|---|---|---|---|
| `A3ACC_SoundCues` | CHECKBOX | false | `fnc_applySoundCues` |
| `A3ACC_Captions` | CHECKBOX | false | `fnc_applyCaptions` |
| `A3ACC_Subtitles` | CHECKBOX | false | `fnc_applySubtitles` |
| `A3ACC_HoldToToggle` | CHECKBOX | false | `fnc_applyInputMode` |
| `A3ACC_BiggerTargets` | CHECKBOX | false | `fnc_applyTargetSize` |
| `A3ACC_KeyPreset` | CHECKBOX | false | `fnc_applyKeyPreset` |
| `A3ACC_ReduceClutter` | CHECKBOX | false | `fnc_applyClutter` |
| `A3ACC_ObjectiveHUD` | CHECKBOX | false | `fnc_applyObjectiveHud` |
| `A3ACC_Countdown` | SLIDER | 0, no change | `fnc_applyCountdown` |
| `A3ACC_TextSize` | LIST | 0, vanilla | `fnc_applyTextSize` |
| `A3ACC_MarkerLegibility` | CHECKBOX | false | `fnc_applyMarkerLegibility` |
| `A3ACC_ViewDistance` | SLIDER | vanilla | `fnc_applyViewDistance` |
| `A3ACC_HighContrast` | CHECKBOX | false | `fnc_applyContrast` |
| `A3ACC_Font` | LIST | 0, vanilla | `fnc_applyFont` |
| `A3ACC_ReduceFlash` | CHECKBOX | false | `fnc_applyFlash` |

Every setting restores the vanilla value on its Off or false branch, exactly as
`A3ACC_ReduceMotion` does.

## 9. Verification gates, by tier

| Tier | File | What it proves | What it cannot prove |
|---|---|---|---|
| Offline | `tests/verify_accessibility.py`, a sibling of `tests/verify_palette.py` | every config value, every text contrast ratio at 4.5:1, every non-text ratio at 3:1, every setting name and default, the absence of a colour matrix in the source | nothing about the engine |
| In-engine | `addons/accessibility/test_*.sqf` on the Docker tier, plus `tests/ingame/verify.py` | every command accepts its arguments, every event handler registers, every keybind registers, every setting holds a valid value, every config class resolves | the rendered result |
| Client | `docs/QA-accessibility.md` | the rendered cue, the rendered text size, the flash reduction, the clutter reduction, the fairness of the movement levers | nothing. It is not repeatable |

Extend `tests/ingame/verify.py` with one rule: fail on any line that contains
`[A3ACC-ACC]` and `FAIL`. Extend the mission `init.sqf` to `execVM` the new probe files.

## 10. Delivery waves

Wave 1 needs no probe. It ships first.

- M1 remappable addon controls.
- M3 larger interaction targets.
- H3 caption styling.
- H7 subtitle state control.
- LV4 high-contrast addon UI.
- C6 keyboard access to every addon action.

Wave 2 needs one probe each. The probe runs before the feature.

- H1 sound cues, H2 captions, H4 vanilla subtitle restyle.
- C1 objective HUD, C2 reduced clutter, C4 tutorial overlay.
- LV1 text size, LV2 marker legibility.
- M7 native key presets.
- MP2 flash reduction.

Wave 3 needs a probe and carries a HIGH risk. Each is off by default and carries a fairness
note in `ACCESSIBILITY.md`.

- M4 movement levers, M5 aim assistance, M6 difficulty presets.
- C5 countdown control.
- LV3 view distance, LV5 dyslexia-friendly font.
- MP3 post-process strength, MP4 blur and grain, MP5 field of view.
- H6 text to speech.

## 11. Todos

- [ ] 1. Create the `addons/accessibility` component skeleton.
  - Acceptance: the component has `$PBOPREFIX$` `z\a3acc\addons\accessibility`, a `config.cpp` with `CfgPatches`, the three `CfgEventHandlers` blocks, `XEH_PREP.hpp`, the three `XEH_*.sqf` files, an empty `initSettings.inc.sqf` and a `CfgTests.hpp`. `requiredAddons[]` names `A3ACC_main`, `cba_common`, `cba_events` and `cba_settings`.
  - QA: `hemtt check -p -e` exits 0 and `hemtt script check_prefixes` passes. Evidence is the CI log.
  - Commit: `access: add the accessibility component skeleton`.
- [ ] 2. Add the offline verifier.
  - Acceptance: `tests/verify_accessibility.py` reads the real config and the real settings file, checks every text pair at 4.5:1 and every non-text pair at 3:1, checks every setting name and its default, and fails if the source contains a colour matrix or a CVD simulation. It exits 0 only when all gates pass.
  - QA: `python3 tests/verify_accessibility.py` exits 0. Then break one value and confirm exit 1. Evidence is both outputs.
  - Commit: `tests: gate the accessibility config offline`.
- [ ] 3. Ship Wave 1, the six features with no probe.
  - Acceptance: `A3ACC_BiggerTargets`, `A3ACC_HighContrast` and `A3ACC_Subtitles` each register a CBA setting with the hook named in section 8, each has one function, and each restores vanilla on Off. `CBA_fnc_addKeybind` registers every addon action unbound by default with the full nine-argument list of section 4, and `CBA_fnc_getKeybind` reads one back. `findDisplay 46 displayAddEventHandler ["KeyDown", ...]` returns an index. The caption display meets 4.5:1. `showSubtitles true` and `getSubtitleOptions` report the subtitle state.
  - QA: `python3 tests/verify_accessibility.py` exits 0, the in-engine suite reports no failure, and the client steps of `docs/QA-accessibility.md` pass for the five features. Evidence is the CI log, the RPT and the checklist.
  - Commit: `access: add the first accessibility features`.
- [ ] 4. Probe Wave 2 and record every result.
  - Acceptance: one probe per Wave 2 feature asserts the exact mechanism inside the engine. `showHUD` in its array form and `shownHUD` agree. `setGroupIconsVisible`, `setGroupIconsSelectable`, `enableSentences` and `showScoretable` accept their arguments. `RscDynamicText` resolves and control idc 9999 exists. `BIS_fnc_rscLayer` and `cutRsc` draw an `RscTitles` class. `BIS_fnc_taskState` reports a state for a created task. `CfgHints` resolves and `BIS_fnc_advHint` returns. `setAperture` and `setApertureNew` accept a bounded range. `setMarkerSize` and `setMarkerAlpha` accept their arguments. `showSubtitles` returns the prior value. A `CfgDefaultKeysPresets` override resolves. Each result is recorded as VERIFIED or UNVERIFIED in `docs/QA-accessibility.md`.
  - QA: `tests/ingame/run.sh` exits 0 and the probe lines are in `tests/ingame/run.log`. Evidence is the log.
  - Commit: `access: probe the wave two mechanisms`.
- [ ] 5. Ship Wave 2, the probed features.
  - Acceptance: H1, H2, H4, C1, C2, C4, LV1, LV2, M7 and MP2 each have one setting, one function and one restore branch. A probe that returned UNVERIFIED leaves its feature unbuilt and the reason recorded.
  - QA: the offline verifier exits 0, the in-engine suite reports no failure, and the client steps pass. Evidence is the CI log, the RPT and the checklist.
  - Commit: `access: add the hearing, clutter, vision and flash features`.
- [ ] 6. Ship Wave 3, the high-risk features.
  - Acceptance: every Wave 3 feature is off by default, restores vanilla on Off, and carries a fairness note in `ACCESSIBILITY.md`. The offline verifier asserts that no colour matrix is present. Each feature states its multiplayer fairness risk in its own tooltip.
  - QA: the offline verifier exits 0, the in-engine suite reports no failure, and the client steps pass, including a day and a night pass for MP2 and a frame-rate pass for LV3. Evidence is the CI log, the RPT and the checklist.
  - Commit: `access: add the high-risk accessibility features`.
- [ ] 7. Wire the tests and the CI.
  - Acceptance: `tests/ingame/verify.py` fails on any `[A3ACC-ACC] ... FAIL` line. The mission `init.sqf` runs the new probes. `.github/workflows/ci.yml` runs `python3 tests/verify_accessibility.py` after the palette step.
  - QA: push a branch and read the CI result. Evidence is the CI run URL.
  - Commit: `ci: gate the accessibility config and probes`.
- [ ] 8. Write the client checklist and the accessibility note.
  - Acceptance: `docs/QA-accessibility.md` holds one step per client-tested feature, the fairness notes, and the probe results. `ACCESSIBILITY.md` names every feature, its scope limit and its fairness risk. `README.md` lists the features and carries no table.
  - QA: a second person runs the checklist without asking a question. Evidence is the completed checklist.
  - Commit: `docs: record the accessibility features and their limits`.

## 12. Final verification wave

- [x] F1. Recompute every contrast gate from the live config. Read each colour pair out of `configFile` in the Docker tier, recompute the WCAG ratio, and require 4.5:1 for text and 3:1 for non-text. Done by `addons/colourblind/test_contrast.sqf`.
- [ ] F2. Prove every command is accepted with its real arguments. Run the Wave 2 and Wave 3 probes on the dedicated server and confirm zero exceptions.
- [ ] F3. Prove every feature restores vanilla. For each setting, set it, then clear it, and confirm the vanilla behaviour returns. The camera-shake feature is the reference.
- [x] F4. Prove no feature is a colour filter. The offline verifier finds no colour matrix, no `ColorCorrections` strength above the flash-damping value, and no CVD simulation. Done by `tests/verify_no_filter.py`.
- [ ] F5. Prove the RPT is clean. No `Error`, no `Updating base class`, and no warning outside the allowlist of `tests/ingame/verify.py`.
- [ ] F6. Prove the client checklist is complete. Every feature marked client-test yes has a recorded result and evidence.

## 13. Acceptance criteria for the roadmap

1. `hemtt check -p -e`, `hemtt script check_prefixes` and `hemtt build` pass on Linux.
2. `python3 tests/verify_palette.py` and `python3 tests/verify_accessibility.py` both exit 0.
3. `tests/ingame/run.sh` exits 0, with no `[A3ACC-ACC] ... FAIL` line and no `Updating base class` line.
4. Every feature in sections 3 to 7 is either shipped with a gate, or explicitly excluded with a reason.
5. Every shipped feature has one CBA setting, default off, and a restore branch.
6. Every command claim cites `docs/research/12-command-capability.md` or a probe result.
7. No feature applies a colour matrix or a CVD simulation.
8. `ACCESSIBILITY.md` states the scope limit and the fairness risk of every movement, aim, difficulty and view-distance feature.

## 14. UNVERIFIED, and what must be checked first

1. The semantics and the safe ranges of every command in `12-command-capability.md`. The
   probe proved existence only.
2. Whether any probed command is client-only and therefore inert on a dedicated server.
3. The payload of `Explosion`. `FiredNear`, `SoundPlayed` and `Suppressed` are confirmed.
   `Suppressed` carries a distance only.
4. Whether an addon `RscTitles` class is reachable from the addon. `RscDynamicText` and
   control idc 9999 are confirmed for the vanilla subtitle control, and the addon one is not.
5. Whether `taskState` and `BIS_fnc_taskState` report the current task without a mission
   dependency.
6. Whether `ppEffectCreate` returns a handle that `ppEffectAdjust` and `ppEffectDestroy`
   release cleanly on this build, and whether the priority it asks for is free.
7. Whether `camSetFov` is stable across seats and views. The command itself is confirmed.
8. Whether the addon can re-apply the H4 subtitle restyle after every call to
   `BIS_fnc_showSubtitle`, because that function re-creates the control each time.
9. Whether a `CfgDefaultKeysPresets` override reaches the vanilla action mappings, and
   whether it clashes with another mod's preset. The class and the `0xaaBBccDD` mapping
   word are confirmed in shipped mods.
10. Whether a `CfgDifficultyPresets` override wins the merge, and whether the server
    parameter `forcedDifficulty` overrides it. No scripting command sets a preset.
11. Whether a signed `callExtension` binary can load under BattlEye.
12. The rendered result of every feature. `03-testing.md` section 2 states the rendered
    pixel is not observable to an automated test. The client checklist is the only check.
13. Whether the shipped `CfgInGameUI` and `CfgNotifications` reopens restate their parents.
    `ACCESSIBILITY.md` already states the fixed-name classes use one universal palette. A
    client test of the rendered result is still outstanding.
14. Whether an addon `RscTitles` class and `BIS_fnc_rscLayer` draw on a dedicated server,
    and whether the `findDisplay 46` KeyDown handler survives a display rebuild.
15. Whether `BIS_fnc_countdown` can extend a countdown that the mission started without
    desynchronising other clients. The global form writes `serverTime`.

## 15. Must NOT have

- No colour matrix, no CVD simulation, no full-screen render filter.
- No `RscDisplaySubtitle`. That class does not exist. The reachable control is
  `RscDynamicText`, control idc 9999, in the `uiNamespace` variable `BIS_dynamicText`.
- No `setAimAssist`, no `BIS_fnc_setDifficulty`, no `ctrlSetFontH`, no `difficultyEnabled`.
  None of them does what the name suggests.
- No `CBA_fnc_registerKeybind`. It is deprecated in favour of `CBA_fnc_addKeybind`.
- No change to any shipped colour value, marker value, or shipped test.
- No edit to `addons/colourblind`. New work goes in `addons/accessibility`.
- No override of vanilla `RscDisplay*` screens, of `CfgVehicles`, of `CfgCloudlets` or of
  `RscMapControl` terrain. Those are art, per `11-config-sweep.md`.
- No feature that cannot restore its vanilla behaviour.
- No HIGH risk feature on by default.
- No binary dependency without a signed extension and a stated BattlEye risk.
- No table in `README.md`.
- No feature outside accessibility. Aim assist, difficulty presets and view distance are
  included only as accessibility assists with a stated fairness risk.
