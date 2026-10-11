#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Rescan the map markers every 2 seconds and recolour any new marker.
 *
 * Return Value:
 * None
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

[{
    private _mode = missionNamespace getVariable ["A3ACC_CVDMode", 0];
    if (_mode > 0) then {
        [_mode] call FUNC(applyMode);
    };
}, 2] call CBA_fnc_addPerFrameHandler;
