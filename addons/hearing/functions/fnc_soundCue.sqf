#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Show a directional cue for nearby gunfire, for deaf and hard-of-hearing
 * players. The engine exposes no way to read a sound event, so the cue is built
 * from the FiredNear gameplay event. Coverage is therefore gunfire only.
 * Client-local.
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
    if (isNil "A3ACC_soundCueHandle") then {
        A3ACC_soundCues = [];
        A3ACC_soundCueHandle = player addEventHandler ["FiredNear", {
            private _firer = _this select 1;
            private _distance = _this select 2;
            if (isNull _firer) exitWith {};
            // Build the label here, once per cue. A sustained burst can push many
            // cues in two seconds, and the frame handler must not format a string
            // for each of them on every frame.
            A3ACC_soundCues pushBack [_firer, format ["GUNFIRE %1 m", round _distance], diag_tickTime + 2];
            // Keep the newest cues only. Several weapons at once must not grow
            // the list without bound.
            if (count A3ACC_soundCues > 12) then {
                A3ACC_soundCues deleteAt 0;
            };
        }];
        A3ACC_soundCuePFH = [{
            A3ACC_soundCues = A3ACC_soundCues select { (_x select 2) > diag_tickTime };
            {
                _x params ["_firer", "_label"];
                if (!isNull _firer) then {
                    private _dir = (getPosASL _firer) vectorDiff (getPosASL player);
                    private _at = (getPosASL player) vectorAdd ((vectorNormalized _dir) vectorMultiply 4);
                    drawIcon3D [
                        "#(rgb,1,1,1)color(1,0.6,0,1)",
                        [1, 1, 1, 1],
                        _at,
                        0.6, 0.6, 0,
                        _label,
                        1, 0.03, "TahomaB"
                    ];
                };
            } forEach A3ACC_soundCues;
        }, 0, []] call CBA_fnc_addPerFrameHandler;
    };
} else {
    if (!isNil "A3ACC_soundCueHandle") then {
        player removeEventHandler ["FiredNear", A3ACC_soundCueHandle];
        [A3ACC_soundCuePFH] call CBA_fnc_removePerFrameHandler;
        A3ACC_soundCueHandle = nil;
        A3ACC_soundCues = [];
    };
};
