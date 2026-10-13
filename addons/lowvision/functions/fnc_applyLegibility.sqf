#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Make map markers larger and fully opaque, for low vision.
 * Client-local: it changes only the local player's own map.
 *
 * Pass one marker name to resize a single marker. The created-marker event uses
 * that path, so a marker created after the setting is on is enlarged at once
 * rather than at the next toggle.
 *
 * Arguments:
 * 0: Enabled <BOOL>
 * 1: One marker name, or "" for every marker <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_enabled", false, [false]], ["_only", "", [""]]];

private _cache = missionNamespace getVariable ["A3ACC_markerLegibilityPrior", createHashMap];

{
    private _name = _x;

    if (_enabled) then {
        if !(_name in _cache) then {
            _cache set [_name, [markerSize _name, markerAlpha _name]];
        };
        _name setMarkerSizeLocal [1.2, 1.2];
        _name setMarkerAlphaLocal 1;
    } else {
        private _prior = _cache get _name;
        if (!isNil "_prior") then {
            _prior params ["_size", "_alpha"];
            _name setMarkerSizeLocal _size;
            _name setMarkerAlphaLocal _alpha;
        };
    };
} forEach (if (_only isEqualTo "") then { allMapMarkers } else { [_only] });

// A full pass also drops the entries for markers that no longer exist, so a long
// session does not keep every name it has ever seen.
if (_only isEqualTo "") then {
    if (_enabled) then {
        private _live = createHashMapFromArray (allMapMarkers apply { [_x, true] });
        {
            if !(_x in _live) then {
                _cache deleteAt _x;
            };
        } forEach keys _cache;
    } else {
        _cache = createHashMap;
    };
};

missionNamespace setVariable ["A3ACC_markerLegibilityPrior", _cache];
