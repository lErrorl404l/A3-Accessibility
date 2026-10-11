#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Apply a colour-vision-deficiency mode to the local map markers.
 * Client-local only: it never broadcasts one player's mode to other machines.
 * The remap resolves from the cached original colour, so a mode change works.
 *
 * Arguments:
 * 0: Mode index <NUMBER>
 *
 * Return Value:
 * None
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
        private _target = [_mode, _original] call FUNC(colourNameFor);

        if (_target == "") then {
            if !(_original in _logged) then {
                _logged set [_original, true];
                diag_log format ["[A3ACC] marker colour '%1' has no remap and stays unchanged", _original];
            };
        } else {
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
