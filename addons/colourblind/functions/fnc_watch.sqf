#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Recolour a marker when it is created, using the CBA marker event. The event is
 * preferred over polling: it fires once per new marker instead of a rescan every
 * two seconds. It recolours that one marker, not the whole set, so a mission
 * that creates markers in a loop does not cost a rescan each time. The apply
 * path is idempotent, so it only sets a colour that differs. Client-local.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

["created", {
    private _mode = missionNamespace getVariable ["A3ACC_CVDMode", 0];
    if (_mode > 0) then {
        [_mode, _this select 0] call FUNC(applyMode);
    };
}] call CBA_fnc_addMarkerEventHandler;
