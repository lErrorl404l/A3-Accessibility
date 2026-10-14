#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Apply one colour-vision-deficiency mode to the whole rendered frame with a
 * single colour-corrections post-process effect. It is the only mechanism in
 * this engine that reaches every colour, because a deficiency affects the whole
 * picture and not only the colours that carry side and status meaning.
 *
 * Client only. A dedicated server has no renderer, so the function returns early
 * without an interface. The create and the destroy are therefore never asserted
 * from the server suite, only from a client record.
 *
 * The effect is created once, at the pinned priority 1991, and its handle lives
 * in the mission namespace. The handle never goes to the profile namespace,
 * because a profile expression can terminate the client at startup.
 *
 * A priority collision makes ppEffectCreate return -1. On that value the
 * function records the failure once and returns without enabling the effect, so
 * a collision leaves the picture as it is and never blanks it.
 *
 * The side and status rule does the precise work. This transform cannot make a
 * hue-selective correction, because the grade treats every pixel the same.
 *
 * Arguments:
 * 0: Mode index: 0 Off, 1 Protan, 2 Deutan, 3 Tritan, 4 Achromatopsia <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_mode", 0, [0]]];

if (!hasInterface) exitWith {};

_mode = _mode max 0 min 4;

private _handle = missionNamespace getVariable ["A3ACC_colourblind_ppHandle", nil];

// Create the effect once. A later call reuses the handle from the mission
// namespace, so the effect is never created twice.
if (isNil "_handle") then {
    _handle = ppEffectCreate ["colorCorrections", 1991];
    missionNamespace setVariable ["A3ACC_colourblind_ppHandle", _handle];

    if (_handle < 0) then {
        // The priority is taken or the effect is unknown. Record it once and
        // leave the picture alone, because enabling an invalid handle would
        // break the render.
        diag_log text format ["[A3ACC] frame create returned %1: the priority is taken or the effect is unknown, the picture is left unchanged", _handle];
    } else {
        diag_log text format ["[A3ACC] frame handle=%1", _handle];
    };
};

// A handle of -1 never reaches the engine.
if (_handle < 0) exitWith {};

if (_mode == 0) then {
    _handle ppEffectEnable false;
    ppEffectDestroy _handle;
    missionNamespace setVariable ["A3ACC_colourblind_ppHandle", nil];
    diag_log text "[A3ACC] frame off destroyed";
} else {
    _handle ppEffectAdjust ([_mode] call FUNC(frameParams));
    _handle ppEffectCommit 0;
    _handle ppEffectEnable true;
    diag_log text format ["[A3ACC] frame mode %1 applied", _mode];
};
