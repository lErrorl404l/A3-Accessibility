#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Show a small always-on panel with the current task, for cognitive
 * accessibility. Client-local.
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

if (isNull player) exitWith {};

if (_enabled) then {
    if (isNil "A3ACC_objectivePFH") then {
        cutRsc ["A3ACC_ObjectiveHud", "PLAIN", 0, false];
        A3ACC_objectivePFH = [{
            private _task = player call BIS_fnc_taskCurrent;
            private _text = if (_task isEqualTo "") then {
                "No active task"
            } else {
                format ["Objective: %1", _task]
            };
            private _display = uiNamespace getVariable ["A3ACC_ObjectiveHud", displayNull];
            if (!isNull _display) then {
                (_display displayCtrl 1001) ctrlSetStructuredText parseText _text;
            };
        }, 0.5, []] call CBA_fnc_addPerFrameHandler;
    };
} else {
    if (!isNil "A3ACC_objectivePFH") then {
        [A3ACC_objectivePFH] call CBA_fnc_removePerFrameHandler;
        A3ACC_objectivePFH = nil;
        cutText ["", "PLAIN"];
    };
};
