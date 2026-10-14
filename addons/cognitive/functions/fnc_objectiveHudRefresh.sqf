#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Cut, update or remove the objective panel to match the current task.
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

private _task = player call BIS_fnc_taskCurrent;

if (_task isEqualTo "") exitWith {
    if (!isNil "A3ACC_objectivePFH") then {
        [A3ACC_objectivePFH] call CBA_fnc_removePerFrameHandler;
        A3ACC_objectivePFH = nil;
        cutText ["", "PLAIN"];
    };
};

// The frame handler runs only while a task is current, so its absence means
// the panel is not cut.
if (isNil "A3ACC_objectivePFH") then {
    cutRsc ["A3ACC_ObjectiveHud", "PLAIN", 0, false];
};

// BIS_fnc_taskCurrent returns the task ID, not the title. The description
// function returns [description, title, marker], and vanilla localises the
// title when the task is set.
private _desc = [_task] call BIS_fnc_taskDescription;
private _title = _task;
if (count _desc > 0) then {
    _title = _desc select 1;
    if (_title isEqualTo "") then { _title = _desc select 0; };
    if (_title isEqualTo "") then { _title = _task; };
};

private _display = uiNamespace getVariable ["A3ACC_ObjectiveHud", displayNull];
if (!isNull _display) then {
    (_display displayCtrl 1001) ctrlSetStructuredText parseText format ["Objective: %1", _title];
};

if (isNil "A3ACC_objectivePFH") then {
    A3ACC_objectivePFH = [{
        call FUNC(objectiveHudRefresh)
    }, 0.5, []] call CBA_fnc_addPerFrameHandler;
};
