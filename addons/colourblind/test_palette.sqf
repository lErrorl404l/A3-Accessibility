#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Assert the pure palette and name functions.
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _fail = 0;
private _classes = ["friendly", "enemy", "neutral", "unknown", "civilian", "objective"];

{
    private _mode = _x;
    {
        private _rgba = [_mode, _x] call FUNC(paletteForMode);
        if (count _rgba != 4) then {
            _fail = _fail + 1;
            diag_log text format ["[A3ACC] palette %1 %2 bad length", _mode, _x];
        } else {
            {
                if (_x < 0 || _x > 1) then {
                    _fail = _fail + 1;
                    diag_log text format ["[A3ACC] palette %1 %2 out of range", _mode, _x];
                };
            } forEach _rgba;
            if ((_rgba select 3) != 1) then {
                _fail = _fail + 1;
                diag_log text format ["[A3ACC] palette %1 %2 alpha not 1", _mode, _x];
            };
        };
    } forEach _classes;
} forEach [1, 2, 3, 4];

{
    if (count ([0, _x] call FUNC(paletteForMode)) != 0) then { _fail = _fail + 1; };
} forEach _classes;
if (count ([1, "nope"] call FUNC(paletteForMode)) != 0) then { _fail = _fail + 1; };
if (count ([9, "friendly"] call FUNC(paletteForMode)) != 0) then { _fail = _fail + 1; };

if (([1, "ColorWEST"] call FUNC(colourNameFor)) != "A3ACC_ColorWEST_Protan") then { _fail = _fail + 1; };
if (([4, "ColorCIV"] call FUNC(colourNameFor)) != "A3ACC_ColorCIV_Achromatopsia") then { _fail = _fail + 1; };
if (([0, "ColorWEST"] call FUNC(colourNameFor)) != "") then { _fail = _fail + 1; };
if (([1, "#A1B2C3"] call FUNC(colourNameFor)) != "") then { _fail = _fail + 1; };

// Exact values for two load-bearing entries.
if (str ([1, "friendly"] call FUNC(paletteForMode)) != str [0.00, 0.35, 0.85, 1]) then { _fail = _fail + 1; };
if (str ([3, "objective"] call FUNC(paletteForMode)) != str [1.00, 0.85, 0.00, 1]) then { _fail = _fail + 1; };

(missionNamespace getVariable ["A3ACC_testResults", []]) pushBack (_fail == 0);
if (_fail == 0) then { diag_log text "[A3ACC] palette tests passed"; };
