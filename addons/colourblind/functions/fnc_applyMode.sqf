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
 * Pass one marker name to recolour a single marker. The created-marker event
 * uses that path, so a new marker costs one lookup rather than a full rescan.
 *
 * Arguments:
 * 0: Mode index <NUMBER>
 * 1: One marker name, or "" for every marker <STRING>
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

params [["_mode", 0, [0]], ["_only", "", [""]]];

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

// The string form of this mode's colour for each marker colour name. Built once
// per call, so the per-marker work below is a lookup.
private _colourFor = createHashMap;
if (_mode > 0) then {
    {
        private _rgba = [_mode, _keyFor get _x] call FUNC(surfaceColourFor);
        _colourFor set [_x, format ["#(%1,%2,%3,1)", _rgba select 0, _rgba select 1, _rgba select 2]];
    } forEach keys _keyFor;
};

private _cache = missionNamespace getVariable ["A3ACC_colourblind_markerCache", createHashMap];
private _logged = missionNamespace getVariable ["A3ACC_colourblind_loggedNames", createHashMap];
private _visited = 0;
private _changed = 0;

{
    private _name = _x;
    _visited = _visited + 1;

    if !(_name in _cache) then {
        _cache set [_name, getMarkerColor _name];
    };

    private _original = _cache get _name;
    private _current = getMarkerColor _name;

    if (_mode == 0) then {
        if (_current != _original) then {
            _name setMarkerColorLocal _original;
            _changed = _changed + 1;
        };
    } else {
        private _target = _colourFor getOrDefault [_original, ""];

        if (_target == "") then {
            if !(_original in _logged) then {
                _logged set [_original, true];
                diag_log format ["[A3ACC] marker colour '%1' has no remap and stays unchanged", _original];
            };
        } else {
            if (_current != _target) then {
                _name setMarkerColorLocal _target;
                _changed = _changed + 1;
            };
        };
    };
} forEach (if (_only isEqualTo "") then { allMapMarkers } else { [_only] });

diag_log text format ["[A3ACC] applyMode %1 scope=%2 visited=%3 recoloured=%4 live=%5",
    _mode, ([_only, "all"] select (_only isEqualTo "")), _visited, _changed, count allMapMarkers];

// A full pass also drops the entries for markers that no longer exist, so a long
// session does not keep every name it has ever seen.
if (_only isEqualTo "") then {
    if (_mode == 0) then {
        _cache = createHashMap;
    } else {
        private _live = createHashMapFromArray (allMapMarkers apply { [_x, true] });
        {
            if !(_x in _live) then {
                _cache deleteAt _x;
            };
        } forEach keys _cache;
    };
};

missionNamespace setVariable ["A3ACC_colourblind_markerCache", _cache];
missionNamespace setVariable ["A3ACC_colourblind_loggedNames", _logged];
