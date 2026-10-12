#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Make map markers larger and fully opaque, for low vision.
 * Client-local: it changes only the local player's own map.
 *
 * Arguments:
 * 0: Enabled <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_enabled", false, [false]]];

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
} forEach allMapMarkers;

if (!_enabled) then {
    _cache = createHashMap;
};

missionNamespace setVariable ["A3ACC_markerLegibilityPrior", _cache];
