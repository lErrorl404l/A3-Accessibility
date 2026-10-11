#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Return the colour-vision-deficiency palette entry for one marker class.
 * Pure function: it reads only its arguments, so SQF-VM can run it.
 *
 * Arguments:
 * 0: Mode index: 0 Off, 1 Protan, 2 Deutan, 3 Tritan, 4 Achromatopsia <NUMBER>
 * 1: Marker class name <STRING>
 *
 * Return Value:
 * RGBA array in the range 0 to 1, or an empty array <ARRAY>
 *
 * Example:
 * [1, "friendly"] call A3ACC_colourblind_fnc_paletteForMode
 *
 * Public: No
 */

params [["_mode", 0, [0]], ["_class", "friendly", [""]]];

if (_mode < 1 || _mode > 4) exitWith { [] };

private _classes = ["friendly", "enemy", "neutral", "unknown", "civilian", "objective"];
private _index = _classes find _class;
if (_index < 0) exitWith { [] };

private _palettes = [
    // Protan and Deutan share the values of the plan.
    [
        [0.00, 0.35, 0.85, 1],
        [1.00, 0.70, 0.00, 1],
        [0.00, 0.80, 0.80, 1],
        [0.75, 0.75, 0.75, 1],
        [0.35, 0.35, 0.35, 1],
        [1.00, 1.00, 1.00, 1]
    ],
    [
        [0.00, 0.35, 0.85, 1],
        [1.00, 0.70, 0.00, 1],
        [0.00, 0.80, 0.80, 1],
        [0.75, 0.75, 0.75, 1],
        [0.35, 0.35, 0.35, 1],
        [1.00, 1.00, 1.00, 1]
    ],
    // Tritan: red against green, plus luminance tiers.
    [
        [0.70, 0.00, 0.00, 1],
        [0.30, 0.90, 0.30, 1],
        [0.75, 0.75, 0.75, 1],
        [0.45, 0.45, 0.45, 1],
        [0.20, 0.20, 0.20, 1],
        [1.00, 0.85, 0.00, 1]
    ],
    // Achromatopsia: hue-free luminance tiers.
    [
        [0.98, 0.98, 0.98, 1],
        [0.25, 0.25, 0.25, 1],
        [0.56, 0.56, 0.56, 1],
        [0.56, 0.56, 0.56, 1],
        [0.98, 0.98, 0.98, 1],
        [1.00, 1.00, 1.00, 1]
    ]
];

(_palettes select (_mode - 1)) select _index
