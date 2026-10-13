#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Return the RGBA colour one engine surface key shows for a mode.
 * Pure function: it reads only its arguments, so SQF-VM can run it.
 *
 * The mode values come from fnc_paletteForMode. The Off value is the shipped
 * channel, read offline from the extracted ui_f config. See
 * docs/research/16-vanilla-surface-values.md and docs/research/17-dynamic-variable-layer.md.
 *
 * Arguments:
 * 0: Mode index: 0 Off, 1 Protan, 2 Deutan, 3 Tritan, 4 Achromatopsia <NUMBER>
 * 1: Surface key <STRING>
 *
 * Return Value:
 * RGBA array in the range 0 to 1 <ARRAY>
 *
 * Example:
 * [1, "BLUFOR"] call A3ACC_colourblind_fnc_surfaceColourFor
 *
 * Public: No
 */

params [["_mode", 0, [0]], ["_key", "", [""]]];

private _keyToClass = createHashMapFromArray [
    ["BLUFOR", "friendly"],
    ["OPFOR", "enemy"],
    ["Independent", "neutral"],
    ["Civilian", "civilian"],
    ["Unknown", "unknown"],
    ["Error", "enemy"],
    ["Warning", "unknown"]
];

if !(_key in _keyToClass) exitWith { [1, 1, 1, 1] };

// The shipped colour each key shows when the addon is Off. The five map keys are
// the engine's own side colours. Error is the default of IGUI_ERROR_RGB_* and
// Warning is the default of IGUI_WARNING_RGB_*, both read from the shipped
// CfgInGameUI/Radar block, which binds those two families to the radar's danger
// and waypoint colours.
//
// There is no key for the tactical ping. It has no colour variable: the name
// IGUI_TACTPING_RGB appears in no engine string, no shipped config and no
// script, and "tactping" appears nowhere in arma3_x64.exe. See
// docs/research/17-dynamic-variable-layer.md.
private _vanilla = createHashMapFromArray [
    ["BLUFOR", [0, 1, 1, 1]],
    ["OPFOR", [1, 0, 0, 1]],
    ["Independent", [0, 1, 0, 1]],
    ["Civilian", [1, 0, 1, 1]],
    ["Unknown", [1, 1, 0, 1]],
    ["Error", [0.8, 0, 0, 1]],
    ["Warning", [0.8, 0.5, 0, 1]]
];

if (_mode < 1) exitWith { _vanilla get _key };

[_mode, _keyToClass get _key] call FUNC(paletteForMode)
