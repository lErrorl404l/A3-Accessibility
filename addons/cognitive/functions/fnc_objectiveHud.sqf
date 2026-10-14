#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Show a small always-on panel with the current task, for cognitive
 * accessibility. The panel is cut only while a task is current, so the empty
 * state shows nothing. Client-local.
 *
 * A respawn replaces the player unit and drops its event handlers, so the panel
 * also watches the player unit through the CBA player event handler. That
 * handler follows the unit across a respawn, re-arms the task handler on the new
 * unit and re-runs the refresh, which re-cuts the panel while a task is current.
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
    if (isNil "A3ACC_objectivePlayerEH") then {
        // The engine fires no mission event handler for a task change, so the
        // panel watches the player object instead. The refresh function stops
        // the frame handler while no task is current, and this event starts it
        // again when one becomes current.
        A3ACC_objectivePlayerEH = ["unit", {
            params ["_newPlayer", "_oldPlayer"];

            // The task handler sits on the unit, and a respawn replaces the
            // unit, so move the handler from the old unit to the new one. The
            // handler id lives on the unit, so each unit holds at most one.
            if (!isNull _oldPlayer) then {
                private _stale = _oldPlayer getVariable ["A3ACC_objectiveEH", -1];
                if (_stale isNotEqualTo -1) then {
                    _oldPlayer removeEventHandler ["TaskSetAsCurrent", _stale];
                    _oldPlayer setVariable ["A3ACC_objectiveEH", nil];
                };
            };
            if ((_newPlayer getVariable ["A3ACC_objectiveEH", -1]) isEqualTo -1) then {
                _newPlayer setVariable ["A3ACC_objectiveEH", _newPlayer addEventHandler ["TaskSetAsCurrent", {
                    call FUNC(objectiveHudRefresh)
                }]];
            };

            // Restart the panel on the new unit: drop the frame handler so the
            // refresh re-cuts the panel while a task is current, and shows
            // nothing while none is.
            if (!isNil "A3ACC_objectivePFH") then {
                [A3ACC_objectivePFH] call CBA_fnc_removePerFrameHandler;
                A3ACC_objectivePFH = nil;
            };
            call FUNC(objectiveHudRefresh);
        }, true] call CBA_fnc_addPlayerEventHandler;
    };
} else {
    if (!isNil "A3ACC_objectivePlayerEH") then {
        ["unit", A3ACC_objectivePlayerEH] call CBA_fnc_removePlayerEventHandler;
        A3ACC_objectivePlayerEH = nil;
    };
    private _handler = player getVariable ["A3ACC_objectiveEH", -1];
    if (_handler isNotEqualTo -1) then {
        player removeEventHandler ["TaskSetAsCurrent", _handler];
        player setVariable ["A3ACC_objectiveEH", nil];
    };
    if (!isNil "A3ACC_objectivePFH") then {
        [A3ACC_objectivePFH] call CBA_fnc_removePerFrameHandler;
        A3ACC_objectivePFH = nil;
        cutText ["", "PLAIN"];
    };
};
