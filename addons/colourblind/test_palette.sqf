#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Assert the pure palette and surface functions.
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

// The surface function resolves every key for every mode, and the Off value is
// the shipped colour.
private _keys = ["BLUFOR", "OPFOR", "Independent", "Civilian", "Unknown", "Error", "Warning"];
{
    private _mode = _x;
    {
        private _rgba = [_mode, _x] call FUNC(surfaceColourFor);
        if (count _rgba != 4) then {
            _fail = _fail + 1;
            diag_log text format ["[A3ACC] surface %1 %2 bad length", _mode, _x];
        } else {
            {
                if (_x < 0 || _x > 1) then {
                    _fail = _fail + 1;
                    diag_log text format ["[A3ACC] surface %1 %2 out of range", _mode, _x];
                };
            } forEach _rgba;
        };
    } forEach _keys;
} forEach [0, 1, 2, 3, 4];

if (str ([0, "BLUFOR"] call FUNC(surfaceColourFor)) != str [0, 1, 1, 1]) then { _fail = _fail + 1; };
if (str ([0, "Error"] call FUNC(surfaceColourFor)) != str [0.8, 0, 0, 1]) then { _fail = _fail + 1; };
// The tactical ping has no colour variable, so its key must not resolve. This
// guards the removal: re-adding the key fails here.
if (str ([0, "TacticalPing"] call FUNC(surfaceColourFor)) != str [1, 1, 1, 1]) then { _fail = _fail + 1; };
if (str ([1, "BLUFOR"] call FUNC(surfaceColourFor)) != str ([1, "friendly"] call FUNC(paletteForMode))) then { _fail = _fail + 1; };
if (str ([3, "OPFOR"] call FUNC(surfaceColourFor)) != str ([3, "enemy"] call FUNC(paletteForMode))) then { _fail = _fail + 1; };
if ((count ([1, "nope"] call FUNC(surfaceColourFor))) != 4) then { _fail = _fail + 1; };

// Exact values for two load-bearing entries.
if (str ([1, "friendly"] call FUNC(paletteForMode)) != str [0.00, 0.35, 0.85, 1]) then { _fail = _fail + 1; };
if (str ([3, "objective"] call FUNC(paletteForMode)) != str [1.00, 0.85, 0.00, 1]) then { _fail = _fail + 1; };

(missionNamespace getVariable ["A3ACC_testResults", []]) pushBack (_fail == 0);
if (_fail == 0) then { diag_log text "[A3ACC] palette tests passed"; };
