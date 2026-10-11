#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Map an engine marker colour name to the addon colour class for a mode.
 * Pure function: it reads only its arguments, so SQF-VM can run it.
 *
 * Arguments:
 * 0: Mode index: 0 Off, 1 Protan, 2 Deutan, 3 Tritan, 4 Achromatopsia <NUMBER>
 * 1: Engine marker colour name <STRING>
 *
 * Return Value:
 * Addon colour class name, or an empty string when there is no remap <STRING>
 *
 * Example:
 * [1, "ColorWEST"] call A3ACC_colourblind_fnc_colourNameFor
 *
 * Public: No
 */

params [["_mode", 0, [0]], ["_colourName", "", [""]]];

if (_mode < 1 || _mode > 4) exitWith { "" };

private _engineNames = ["ColorWEST", "ColorEAST", "ColorGUER", "ColorCIV", "ColorUNKNOWN"];
if !(_colourName in _engineNames) exitWith { "" };

private _suffixes = ["Protan", "Deutan", "Tritan", "Achromatopsia"];

format ["A3ACC_%1_%2", _colourName, _suffixes select (_mode - 1)]
