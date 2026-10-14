# Wiki command verification

Method: the wiki at community.bistudio.com returns HTTP 403 to a plain
fetcher. Every page below was read through the Wayback Machine, using the
`2024id_` redirect, which resolves to the nearest snapshot of that year.
The snapshot timestamp is in each URL. Where a page had no snapshot, the row
says UNVERIFIED and names the URL that was tried.

The code was read before it was judged. Files read:
`addons/colourblind/functions/fnc_applyVars.sqf`, `fnc_applyMode.sqf`,
`fnc_surfaceColourFor.sqf`, `fnc_watch.sqf`, `fnc_paletteForMode.sqf`,
`addons/lowvision/functions/fnc_applyLegibility.sqf`,
`addons/cognitive/functions/fnc_objectiveHud.sqf`, `fnc_applyClutter.sqf`,
`addons/motion/functions/fnc_applyMotion.sqf`,
`addons/hearing/functions/fnc_applyCaptions.sqf`,
`addons/motor/functions/fnc_applyWalk.sqf`,
`addons/colourblind/test_setting.sqf`, and the config files in
`addons/colourblind/`.

## Verification table

| Item | What the wiki says | URL (Wayback snapshot) | What our code does | Verdict |
|---|---|---|---|---|
| setMarkerColor | `markerName setMarkerColor color`. `color` is a String, the CfgMarkerColors class name. Global. | https://web.archive.org/web/20240906191455id_/https://community.bistudio.com/wiki/setMarkerColor | Not called. | CORRECT |
| setMarkerColorLocal | `markerName setMarkerColorLocal colour`. `colour` is a String, a CfgMarkerColors class name. Since 2.20 it also accepts a direct string `"#(r,g,b,a)"`. A raw RGBA array is not listed. | https://web.archive.org/web/20250116111934id_/https://community.bistudio.com/wiki/setMarkerColorLocal | `_name setMarkerColorLocal _original`, where `_original` is the String from `getMarkerColor`. | CORRECT |
| getMarkerColor | `getMarkerColor markerName`. Returns String. Identical to `markerColor`. | https://web.archive.org/web/20250120224947id_/https://community.bistudio.com/wiki/getMarkerColor | Caches and compares the String result. | CORRECT |
| markerColor | `markerColor markerName`. Returns String. | https://web.archive.org/web/20250121003558id_/https://community.bistudio.com/wiki/markerColor | Not called. | CORRECT |
| createMarker | `createMarker [name, position]`. Returns String. Marker is invisible until `setMarkerType`. | https://web.archive.org/web/20241206013309id_/https://community.bistudio.com/wiki/createMarker | `createMarker [_marker, [0,0,0]]` in `test_setting.sqf`. | CORRECT |
| deleteMarker | `deleteMarker name`. `name` is a String. Returns Nothing. | https://web.archive.org/web/20241212043619id_/https://community.bistudio.com/wiki/deleteMarker | `deleteMarker _marker` in `test_setting.sqf`. | CORRECT |
| profileNamespace | Returns the global namespace attached to the active user profile. Lifetime is the profile lifetime. Variables are loaded when the user profile is loaded or changed. | https://web.archive.org/web/20250114110904id_/https://community.bistudio.com/wiki/profileNamespace | Writes the 44 colour variables with `profileNamespace setVariable`. | CORRECT (wiki silent on server-start ordering) |
| missionNamespace | Returns the global namespace attached to the mission. Lifetime is the mission duration. | https://web.archive.org/web/20241127234453id_/https://community.bistudio.com/wiki/missionNamespace | Stores addon state (`A3ACC_*`) with `missionNamespace setVariable`. | CORRECT |
| setVariable | `varspace setVariable [name, value, public]`. Namespace variables cannot be named as commands. A command name causes "Reserved variable in expression". | https://web.archive.org/web/20250118102511id_/https://community.bistudio.com/wiki/setVariable | Names are `Map_BLUFOR_R` and `A3ACC_Surf_*`. None is a command name. | CORRECT |
| getVariable | `namespace getVariable [name, defaultValue]`. Returns the value, or the default. | https://web.archive.org/web/20250119163319id_/https://community.bistudio.com/wiki/getVariable | Uses the `[name, default]` form. | CORRECT |
| Config string expression | The wiki does not state when an addon config array element that is a string expression is evaluated. It does not state whether the engine re-evaluates it after the variable changes. | https://web.archive.org/web/20250119225640id_/https://community.bistudio.com/wiki/Config (also Config_Parser, Initialisation_Order) | `CfgInGameUI`, `CfgWrapperUI`, `CfgNotifications` and others use `"(profilenamespace getvariable ['...',default])"` strings. | UNVERIFIED |
| setGroupIconParams | `group setGroupIconParams [color, text, scale, visibility, WPvisibility, WPcolor]`. `color` is `[r,g,b,a]`. | https://web.archive.org/web/20250208091550id_/https://community.bistudio.com/wiki/setGroupIconParams | Not called. | CORRECT |
| ctrlSetTextColor | `control ctrlSetTextColor color`. `color` is an Array in RGBA format. | https://web.archive.org/web/20250319180123id_/https://community.bistudio.com/wiki/ctrlSetTextColor | Not called. | CORRECT |
| ctrlSetBackgroundColor | `control ctrlSetBackgroundColor color`. `color` is an Array of RGBA. | https://web.archive.org/web/20250117105548id_/https://community.bistudio.com/wiki/ctrlSetBackgroundColor | Not called. | CORRECT |
| ctrlSetTextSelectionColor | No wiki page found. The archive returns 404 for 2024 and 2020 snapshots. | https://web.archive.org/web/2024id_/https://community.bistudio.com/wiki/ctrlSetTextSelectionColor | Not called. | UNVERIFIED |
| allControls | `allControls display` returns an Array of Controls. Also accepts a CT_CONTROLS_GROUP. | https://web.archive.org/web/20250118041201id_/https://community.bistudio.com/wiki/allControls | Not called. | CORRECT |
| allDisplays | `allDisplays` returns an Array of GUI Displays. | https://web.archive.org/web/20241109164742id_/https://community.bistudio.com/wiki/allDisplays | Not called. | CORRECT |
| ctrlCommit | `control ctrlCommit time`. `time` is a Number. | https://web.archive.org/web/20250113175637id_/https://community.bistudio.com/wiki/ctrlCommit | Not called. | CORRECT |
| ctrlSetFontHeight | `control ctrlSetFontHeight size`. `size` is a Number. | https://web.archive.org/web/20241205213831id_/https://community.bistudio.com/wiki/ctrlSetFontHeight | Not called. | CORRECT |
| enableCamShake | `enableCamShake value`. `value` is a Boolean. False stops an active shake at once. | https://web.archive.org/web/20201101020759id_/https://community.bistudio.com/wiki/enableCamShake | `enableCamShake false` and `enableCamShake true`. | CORRECT |
| setCamShakeDefParams | `setCamShakeDefParams [power, duration, frequency, minSpeed, minMass, caliberCoefHit, vehicleCoef]`. | https://web.archive.org/web/20250207121639id_/https://community.bistudio.com/wiki/setCamShakeDefParams | Not called. | CORRECT |
| showSubtitles | `showSubtitles enable`. `enable` is a Boolean. Returns the previous state as a Boolean. | https://web.archive.org/web/20241206065117id_/https://community.bistudio.com/wiki/showSubtitles | `showSubtitles true` and `showSubtitles _prior`. Prior state read from `shownSubtitles`. | CORRECT |
| getSubtitleOptions | `getSubtitleOptions` returns `[subtitlesEnabled, radioSubtitlesEnabled]`. | https://web.archive.org/web/20241203214950id_/https://community.bistudio.com/wiki/getSubtitleOptions | Not called. | CORRECT |
| forceWalk | `unit forceWalk value`. `value` is a Boolean. | https://web.archive.org/web/20241204021549id_/https://community.bistudio.com/wiki/forceWalk | `player forceWalk _enabled`. | CORRECT |
| allowSprint | `unit allowSprint state`. `state` is a Boolean. | https://web.archive.org/web/20250217081729id_/https://community.bistudio.com/wiki/allowSprint | Not called. | CORRECT |
| shownHUD | `shownHUD` returns 11 Booleans: `[hud, info, radar, compass, direction, menu, group, cursors, panels, kills, icon3d]`. | https://web.archive.org/web/20241205003042id_/https://community.bistudio.com/wiki/shownHUD | Stores `shownHUD` and restores it with `showHUD _hud`. | CORRECT |
| showHUD | `showHUD [scriptedHUD, info, radar, compass, direction, menu, group, cursors, panels, kills, showIcon3D]`. | https://web.archive.org/web/20241203134801id_/https://community.bistudio.com/wiki/showHUD | `showHUD [true, true, true, true, true, true, true, true, false, false, true]` and `showHUD _hud`. | CORRECT |
| setMarkerSizeLocal | `markerName setMarkerSizeLocal [axisA, axisB]`. Both are Numbers. | https://web.archive.org/web/20241206005052id_/https://community.bistudio.com/wiki/setMarkerSizeLocal | `_name setMarkerSizeLocal [1.2, 1.2]` and `setMarkerSizeLocal _size`. | CORRECT |
| setMarkerAlphaLocal | `marker setMarkerAlphaLocal alpha`. `alpha` is a Number from 0 to 1. | https://web.archive.org/web/20241203171557id_/https://community.bistudio.com/wiki/setMarkerAlphaLocal | `setMarkerAlphaLocal 1` and `setMarkerAlphaLocal _alpha`. | CORRECT |
| cutRsc | `cutRsc [class, effect, speed, showInMap, drawOverHUD]`. `class` is a String. The wiki recommends registering a layer with `BIS_fnc_rscLayer`. | https://web.archive.org/web/20250112204328id_/https://community.bistudio.com/wiki/cutRsc | `cutRsc ["A3ACC_ObjectiveHud", "PLAIN", 0, false]`. | CORRECT (see recommendation) |
| cutText | `cutText [text, type, speed, showInMap, isStructuredText, drawOverHUD]`. `text` is a String. | https://web.archive.org/web/20250119170256id_/https://community.bistudio.com/wiki/cutText | `cutText ["", "PLAIN"]`. | CORRECT |
| BIS_fnc_rscLayer | `[layerName] call BIS_fnc_rscLayer`. Returns a Number, the layer ID. | https://web.archive.org/web/20250211114453id_/https://community.bistudio.com/wiki/BIS_fnc_rscLayer | Not called. The RSC class is used directly. | CORRECT (recommendation) |
| BIS_fnc_taskCurrent | `unit call BIS_fnc_taskCurrent`. Returns a String, the task ID. | https://web.archive.org/web/20241214071857id_/https://community.bistudio.com/wiki/BIS_fnc_taskCurrent | `player call BIS_fnc_taskCurrent`, compared to `""`. | CORRECT |
| BIS_fnc_taskState | `taskID call BIS_fnc_taskState`. Returns a String state. | https://web.archive.org/web/20250214120501id_/https://community.bistudio.com/wiki/BIS_fnc_taskState | Not called. | CORRECT |
| ppEffectCreate | `ppEffectCreate [name, priority]`. The priority is unique. Returns a handle, or -1 on failure. | https://web.archive.org/web/20250114020503id_/https://community.bistudio.com/wiki/ppEffectCreate | Not called. Deliberately avoided. | CORRECT |
| ppEffectAdjust | `effect ppEffectAdjust settings`. `settings` is an Array. | https://web.archive.org/web/20250121160207id_/https://community.bistudio.com/wiki/ppEffectAdjust | Not called. Deliberately avoided. | CORRECT |
| ppEffectCommit | `effect ppEffectCommit commit`. `commit` is a Number. | https://web.archive.org/web/20241008152220id_/https://community.bistudio.com/wiki/ppEffectCommit | Not called. Deliberately avoided. | CORRECT |
| setAperture | `setAperture aperture`. The engine resets the aperture at mission start. | https://web.archive.org/web/20241209005642id_/https://community.bistudio.com/wiki/setAperture | Not called. Deliberately avoided. | CORRECT |
| setApertureNew | `setApertureNew [minimum, standard, maximum, luminance]`. Run it after mission start. | https://web.archive.org/web/20250119125600id_/https://community.bistudio.com/wiki/setApertureNew | Not called. Deliberately avoided. | CORRECT |

## Must change

1. No misuse was found. Every command our code calls is used with the
   argument type and order the wiki gives. No wrong return type was found.
2. The engine rejection of an array by `setMarkerColorLocal` is confirmed.
   The wiki lists only a String and, since 2.20, the string `"#(r,g,b,a)"`.
   Our code passes a String from `getMarkerColor`, so the rejection does not
   affect us. No change.
3. Register the cutRsc layer. The wiki warns that a bare class name can
   collide with an existing layer and recommends `BIS_fnc_rscLayer`. Change
   `fnc_objectiveHud.sqf` to register `"A3ACC_ObjectiveHud"` once and use the
   returned name. This is a recommendation, not a defect.
4. `showSubtitles` returns the previous state. `fnc_applyCaptions.sqf` reads
   `shownSubtitles` separately. That read is valid. You can drop it and use
   the return value instead. Optional.

## Where the wiki is silent

1. The single most important item is unanswered. The wiki does not state
   when an addon config array element that is a string expression is
   evaluated. It does not state whether the engine re-evaluates the
   expression after the variable changes. The closest statement is on
   Initialisation Order, which says that expressions of Eden Editor entity
   and scenario attributes are called during mission initialisation. That
   covers mission attributes, not addon config entries.
   https://web.archive.org/web/20250114030259id_/https://community.bistudio.com/wiki/Initialisation_Order
2. The Config Parser page covers `__EXEC` and `__EVAL`. Those macros are
   resolved when the config is parsed, not at runtime. That page does not
   answer the runtime question.
   https://web.archive.org/web/20240805201159id_/https://community.bistudio.com/wiki/Config_Parser
3. The wiki does not state when `profileNamespace` becomes available relative
   to world initialisation. It states only the profile lifetime and that the
   variables load when the user profile is loaded or changed. The startup
   error "world is not initialized yet" is not explained by the wiki.
4. `ctrlSetTextSelectionColor` has no wiki page in the archive. Our code does
   not call it.

No rendered result is claimed here. Only a human at a client can see the
screen.

## Post-process effect names and ranges

Four answers, each cited. The BIKI page "Post Process Effects" is the source for
the family list and the parameter table. Its snapshot is
https://web.archive.org/web/20250117220255id_/https://community.bistudio.com/wiki/Post_Process_Effects
(17 January 2025).

### The name form

`ppEffectAdjust`, `ppEffectEnable`, `ppEffectCommit` and `ppEffectEnabled` each
accept a bare effect name as well as a handle. `ppEffectDestroy` has NO name
form. Nothing can destroy another party's effect by name.

| Command | What the wiki gives | Snapshot |
|---|---|---|
| `ppEffectAdjust` | `effect` is String or Number. A String is the effect name. | https://web.archive.org/web/20250121160207id_/https://community.bistudio.com/wiki/ppEffectAdjust |
| `ppEffectEnable` | Syntax 1 takes a String, the name of the effect. Syntax 2 takes a Number handle. | https://web.archive.org/web/20250121124253id_/https://community.bistudio.com/wiki/ppEffectEnable |
| `ppEffectCommit` | Syntax 1 takes a String, the name of the effect. Syntax 2 takes a Number handle. | https://web.archive.org/web/20241008152220id_/https://community.bistudio.com/wiki/ppEffectCommit |
| `ppEffectEnabled` | The alternative syntax since 2.04 takes a String, the effect name. | https://web.archive.org/web/20250211105737id_/https://community.bistudio.com/wiki/ppEffectEnabled |
| `ppEffectDestroy` | `effect` is a Number handle, or an array of Numbers. No name form. | https://web.archive.org/web/20250317130657id_/https://community.bistudio.com/wiki/ppEffectDestroy |

### A bare name and a handle

Whether a bare name reaches the same instance as one that `ppEffectCreate`
created and the caller holds as a handle is UNDOCUMENTED. Two facts make the
ambiguity real.

1. The engine holds many `ColorCorrections` instances at once at different
   priorities. The "Post Process Effects" page gives `ColorCorrections` a base
   priority of 1500. `tests/gen_pp_priorities.py` reads a CBA_A3 optics priority
   of 950 from `cba_optics.pbo`, a second instance below the base.
2. The engine's own template applier uses the name form and creates no handle.
   See `Addons__functions_f/a3/functions_f/Environment/fn_setPPeffectTemplate.sqf:40-50`.
   It loops over the names `["colorCorrections","filmGrain"]` and calls
   `_x ppeffectadjust _data`, `_x ppeffectcommit _commit` and
   `_x ppeffectenable true`. It calls no `ppEffectCreate`.

### The parameter ranges are nominal

The wiki gives a range for each `ColorCorrections` parameter. The range is
nominal. Shipped content exceeds it.

| Parameter | Documented range | Default |
|---|---|---|
| brightness | 0..2 | 1 |
| contrast | 0.. (open) | 1 |
| offset | 0.. (open) | 0 |
| blend `[r, g, b, a]` | 0..1 | `[0, 0, 0, 0]` |
| colorize `[r, g, b, a]` | 0..1 | `[1, 1, 1, 1]` |
| desaturation weights `[r, g, b, 0]` | 0..1 | `[0.299, 0.587, 0.114, 0]` |

Source: the "Post Process Effects" snapshot above.

Two shipped counter-examples sit outside the nominal 0..1 channel range. The
`CfgPostProcessTemplates` block spans
`Curator__Addons__ui_f_curator/a3/ui_f_curator/config.cpp:865-895`.

- `Curator__Addons__ui_f_curator/a3/ui_f_curator/config.cpp:881`: the
  `RealIsBrown` template holds
  `colorCorrections[] = {1,1,0,{0.1,0.2,0.3,-0.5},{1,1,1,0.4},{0.5,0.2,0.0,1.0}};`.
  The blend alpha is -0.5.
- `Curator__Addons__ui_f_curator/a3/ui_f_curator/config.cpp:876`: the `EastWind`
  template holds
  `colorCorrections[] = {1,1.08,-0.06,{0.5,0.5,0.5,0},{1.0,1.0,1.0,1.21},{0.09,0.09,0.09,0.0}};`.
  The colorize alpha is 1.21.

### The nine families and the corpus sweep

The wiki documents nine effect families for `ppEffectCreate`:

RadialBlur, ChromAberration, WetDistortion, ColorCorrections, DynamicBlur,
FilmGrain, ColorInversion, SSAO and Resolution.

Source: the "Post Process Effects" snapshot above. `tests/verify_postprocess.py`
owns the ban. Its token list holds the eight families other than
`ColorCorrections`, plus the capital-C class name `ColorCorrections` as a guard.

A sweep of the extracted corpus at `/ext/Development/.opencode/a3code/` found no
hue-selective, lookup-table, matrix, grading, white-balance or hue-shift lever
that a config or a script can reach. The corpus holds 508 extracted trees. The
file counts are 6699 `.sqf`, 1438 `.cpp`, 1120 `.sqfc`, 618 `.fsm`, 499 `.txt`,
385 `.ext`, 280 `.inc` and 274 `.hpp`.

- `colorgrading`, `color_grading`, `hueshift`, `whitebalance`, `ColorMatrix` and
  `\bLUT\b`: no file.
- `\bHue\b`: no file. The four case-insensitive `hue` hits are surnames in a
  credit list.
- `\bMatrix\b`: three files. Each is a geometry or a transform matrix
  (`fn_convertUnits.sqf`, `fn_spawnObjects.sqf`, `fn_objectsMapper.sqf`), not a
  colour matrix.
- `LookUpTable`: one file, `fn_arsenal.sqf`, an item lookup, not a colour lookup.
- `CfgPostProcessTemplates`: the only post-process config root. It appears 18
  times.

LIMITATION. The corpus holds no engine binaries and no shader files. A hardcoded
engine shader therefore cannot be excluded by this evidence. Every lever a config
or a script can reach is covered.
