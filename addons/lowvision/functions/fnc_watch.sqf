#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Enlarge a marker when it is created, if the larger-marker setting is on. The
 * CBA marker event fires once per new marker, so a marker created after the
 * setting was enabled is enlarged at once instead of at the next toggle.
 * Client-local.
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
    if (missionNamespace getVariable ["A3ACC_MapLegibility", false]) then {
        [true, _this select 0] call FUNC(applyLegibility);
    };
}] call CBA_fnc_addMarkerEventHandler;
