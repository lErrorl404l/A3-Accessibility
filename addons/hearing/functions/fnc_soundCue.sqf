#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Show a directional cue for nearby gunfire, for deaf and hard-of-hearing
 * players. The engine exposes no way to read a sound event, so the cue is built
 * from the FiredNear gameplay event. Coverage is therefore gunfire only.
 * Client-local.
 *
 * A respawn replaces the player unit and drops its event handlers, so the cue
 * also watches the player unit through the CBA player event handler. That
 * handler follows the unit across a respawn, moves the FiredNear handler from
 * the old unit to the new one, and re-arms the cue on the new unit.
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
    if (isNil "A3ACC_soundCuePlayerEH") then {
        A3ACC_soundCueList = [];
        A3ACC_soundCuePlayerEH = ["unit", {
            params ["_newPlayer", "_oldPlayer"];

            // The FiredNear handler sits on the unit, and a respawn replaces
            // the unit, so move the handler from the old unit to the new one.
            // The handler id lives on the unit, so each unit holds at most one.
            if (!isNull _oldPlayer) then {
                private _stale = _oldPlayer getVariable ["A3ACC_soundCueEH", -1];
                if (_stale isNotEqualTo -1) then {
                    _oldPlayer removeEventHandler ["FiredNear", _stale];
                    _oldPlayer setVariable ["A3ACC_soundCueEH", nil];
                };
            };
            if ((_newPlayer getVariable ["A3ACC_soundCueEH", -1]) isEqualTo -1) then {
                _newPlayer setVariable ["A3ACC_soundCueEH", _newPlayer addEventHandler ["FiredNear", {
                    private _firer = _this select 1;
                    private _distance = _this select 2;
                    if (isNull _firer) exitWith {};
                    // Build the label here, once per cue. A sustained burst can push many
                    // cues in two seconds, and the frame handler must not format a string
                    // for each of them on every frame.
                    A3ACC_soundCueList pushBack [_firer, format ["GUNFIRE %1 m", round _distance], diag_tickTime + 2];
                    // Keep the newest cues only. Several weapons at once must not grow
                    // the list without bound.
                    if (count A3ACC_soundCueList > 12) then {
                        A3ACC_soundCueList deleteAt 0;
                    };
                }]];
            };

            // Start the draw loop once. It reads the global `player`, so it
            // follows the new unit across a respawn and needs no restart.
            if (isNil "A3ACC_soundCuePFH") then {
                A3ACC_soundCuePFH = [{
                    A3ACC_soundCueList = A3ACC_soundCueList select { (_x select 2) > diag_tickTime };
                    {
                        _x params ["_firer", "_label"];
                        if (!isNull _firer) then {
                            private _player = getPosASL player;
                            private _dir = (getPosASL _firer) vectorDiff _player;
                            // drawIcon3D takes a PositionAGL, not a PositionASL. Passing
                            // an ASL position draws the cue above the ground by the
                            // elevation at the player, which grows on a hill. Every
                            // shipped caller converts first: see ASLToAGL in
                            // functions_f/Animation/Timeline/fn_timeline_simulateCurves.sqf.
                            private _at = ASLToAGL (_player vectorAdd ((vectorNormalized _dir) vectorMultiply 4));
                            drawIcon3D [
                                "#(rgb,1,1,1)color(1,0.6,0,1)",
                                [1, 1, 1, 1],
                                _at,
                                0.6, 0.6, 0,
                                _label,
                                1, 0.03, "TahomaB"
                            ];
                        };
                    } forEach A3ACC_soundCueList;
                }, 0, []] call CBA_fnc_addPerFrameHandler;
            };
        }, true] call CBA_fnc_addPlayerEventHandler;
    };
} else {
    if (!isNil "A3ACC_soundCuePlayerEH") then {
        ["unit", A3ACC_soundCuePlayerEH] call CBA_fnc_removePlayerEventHandler;
        A3ACC_soundCuePlayerEH = nil;
    };
    private _handler = player getVariable ["A3ACC_soundCueEH", -1];
    if (_handler isNotEqualTo -1) then {
        player removeEventHandler ["FiredNear", _handler];
        player setVariable ["A3ACC_soundCueEH", nil];
    };
    if (!isNil "A3ACC_soundCuePFH") then {
        [A3ACC_soundCuePFH] call CBA_fnc_removePerFrameHandler;
        A3ACC_soundCuePFH = nil;
        A3ACC_soundCueList = [];
    };
};
