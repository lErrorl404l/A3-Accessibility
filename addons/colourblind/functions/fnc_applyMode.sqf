#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Apply a colour-vision-deficiency mode to the local map markers.
 * Client-local only: it never broadcasts one player's mode to other machines.
 *
 * setMarkerColorLocal accepts a colour name, or the direct string form
 * "#(r,g,b,a)" since Arma 3 2.20. It does not accept an RGBA array. So the mode
 * sets each marker to the direct string form, computed from the pure palette.
 * That path is independent of whether the engine re-evaluates the config
 * expression, and it works for any marker whose current colour is one of the
 * five side names. A marker on another name, or on a mission raw value, stays as
 * it is and is logged once.
 *
 * Arguments:
 * 0: Mode index <NUMBER>
 *
 * Return Value:
 * None
 *
 * Sets:
 * A3ACC_palette - the six palette entries for the mode, or empty for Off. The
 * in-engine suite reads it to assert the apply and the restore.
 *
 * Public: No
 */

params [["_mode", 0, [0]]];

_mode = _mode max 0 min 4;

private _classes = ["friendly", "enemy", "neutral", "unknown", "civilian", "objective"];
private _palette = [];
if (_mode > 0) then {
    {
        _palette pushBack ([_mode, _x] call FUNC(paletteForMode));
    } forEach _classes;
};

missionNamespace setVariable ["A3ACC_palette", _palette];

// The five engine marker colour names map to the five surface keys.
private _keyFor = createHashMapFromArray [
    ["ColorWEST", "BLUFOR"],
    ["ColorEAST", "OPFOR"],
    ["ColorGUER", "Independent"],
    ["ColorCIV", "Civilian"],
    ["ColorUNKNOWN", "Unknown"]
];

private _cache = missionNamespace getVariable ["A3ACC_colourblind_markerCache", createHashMap];
private _logged = missionNamespace getVariable ["A3ACC_colourblind_loggedNames", createHashMap];

{
    private _name = _x;

    if !(_name in _cache) then {
        _cache set [_name, getMarkerColor _name];
    };

    private _original = _cache get _name;
    private _current = getMarkerColor _name;

    if (_mode == 0) then {
        if (_current != _original) then {
            _name setMarkerColorLocal _original;
        };
    } else {
        private _key = _keyFor getOrDefault [_original, ""];

        if (_key == "") then {
            if !(_original in _logged) then {
                _logged set [_original, true];
                diag_log format ["[A3ACC] marker colour '%1' has no remap and stays unchanged", _original];
            };
        } else {
            private _rgba = [_mode, _key] call FUNC(surfaceColourFor);
            private _target = format ["#(%1,%2,%3,1)", _rgba select 0, _rgba select 1, _rgba select 2];
            if (_current != _target) then {
                _name setMarkerColorLocal _target;
            };
        };
    };
} forEach allMapMarkers;

if (_mode == 0) then {
    _cache = createHashMap;
};

missionNamespace setVariable ["A3ACC_colourblind_markerCache", _cache];
missionNamespace setVariable ["A3ACC_colourblind_loggedNames", _logged];
