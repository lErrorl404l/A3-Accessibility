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
            A3ACC_soundCues pushBack [_firer, _distance, diag_tickTime + 2];
        }];
        A3ACC_soundCuePFH = [{
            A3ACC_soundCues = A3ACC_soundCues select { (_x select 2) > diag_tickTime };
            {
                _x params ["_firer", "_distance"];
                if (!isNull _firer) then {
                    private _dir = (getPosASL _firer) vectorDiff (getPosASL player);
                    private _at = (getPosASL player) vectorAdd ((vectorNormalized _dir) vectorMultiply 4);
                    drawIcon3D [
                        "#(rgb,1,1,1)color(1,0.6,0,1)",
                        [1, 1, 1, 1],
                        _at,
                        0.6, 0.6, 0,
                        format ["GUNFIRE %1 m", round _distance],
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
