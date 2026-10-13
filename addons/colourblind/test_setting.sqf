#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Assert the CBA setting registered and holds a valid mode value.
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _fail = 0;

// Functions live in their own component addons; resolve them by name.
private _fnNames = ["A3ACC_motion_fnc_applyMotion", "A3ACC_hearing_fnc_applyCaptions", "A3ACC_cognitive_fnc_applyClutter", "A3ACC_lowvision_fnc_applyLegibility", "A3ACC_motor_fnc_applyWalk", "A3ACC_hearing_fnc_soundCue"];
{
    if (isNil {missionNamespace getVariable [_x, nil]}) then {
        _fail = _fail + 1;
        diag_log text format ["[A3ACC] function not found: %1", _x];
    };
} forEach _fnNames;
private _applyMotion = missionNamespace getVariable ["A3ACC_motion_fnc_applyMotion", {}];
private _applyCaptions = missionNamespace getVariable ["A3ACC_hearing_fnc_applyCaptions", {}];
private _applyClutter = missionNamespace getVariable ["A3ACC_cognitive_fnc_applyClutter", {}];
private _applyLegibility = missionNamespace getVariable ["A3ACC_lowvision_fnc_applyLegibility", {}];
private _applyWalk = missionNamespace getVariable ["A3ACC_motor_fnc_applyWalk", {}];

if (isNil "A3ACC_CVDMode") then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] setting A3ACC_CVDMode not found";
} else {
    private _value = missionNamespace getVariable ["A3ACC_CVDMode", -1];
    if !(_value in [0, 1, 2, 3, 4]) then {
        _fail = _fail + 1;
        diag_log text format ["[A3ACC] setting value out of range: %1", str _value];
    };
};

// The palette global tracks the mode: six entries for a mode, empty for Off.
[1] call FUNC(applyMode);
if ((count (missionNamespace getVariable ["A3ACC_palette", []])) != 6) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] palette global is not six entries after mode 1";
};

[0] call FUNC(applyMode);
if ((count (missionNamespace getVariable ["A3ACC_palette", []])) != 0) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] palette global is not empty after mode 0";
};

// A live marker is set to the direct colour string form, computed from the pure
// palette, because setMarkerColorLocal rejects an RGBA array. A foreign change
// is corrected, and Off restores the engine colour name.
private _marker = "a3acc_test_marker";
createMarker [_marker, [0, 0, 0]];
private _rgba = [1, "BLUFOR"] call FUNC(surfaceColourFor);
private _want = format ["#(%1,%2,%3,1)", _rgba select 0, _rgba select 1, _rgba select 2];
_marker setMarkerColorLocal "ColorWEST";
[1] call FUNC(applyMode);
if ((getMarkerColor _marker) != _want) then {
    _fail = _fail + 1;
    diag_log text format ["[A3ACC] marker colour on apply: %1 want %2", getMarkerColor _marker, _want];
};
_marker setMarkerColorLocal "ColorBlue";
[1] call FUNC(applyMode);
if ((getMarkerColor _marker) != _want) then {
    _fail = _fail + 1;
    diag_log text format ["[A3ACC] marker colour was not re-applied: %1", getMarkerColor _marker];
};
[0] call FUNC(applyMode);
if ((getMarkerColor _marker) != "ColorWEST") then {
    _fail = _fail + 1;
    diag_log text format ["[A3ACC] marker did not restore: %1", getMarkerColor _marker];
};
deleteMarker _marker;

// The registered default must be Off (0). CBA stores the setting definition in
// CBA_settings_default; the first element of that array is the default value.
private _defaults = missionNamespace getVariable ["CBA_settings_default", nil];
if (isNil "_defaults") then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] CBA_settings_default is missing";
} else {
    private _entry = _defaults getVariable ["A3ACC_CVDMode", []];
    if ((_entry isEqualType []) && {_entry isNotEqualTo []}) then {
        private _default = _entry select 0;
        if (_default != 0) then {
            _fail = _fail + 1;
            diag_log text format ["[A3ACC] setting default is %1, expected 0", str _default];
        };
    } else {
        _fail = _fail + 1;
        diag_log text "[A3ACC] setting default entry not found";
    };
};

// The motion setting must be registered, and applying it must not error.
if (isNil "A3ACC_ReduceMotion") then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] setting A3ACC_ReduceMotion not found";
};
[true] call _applyMotion;
[false] call _applyMotion;

// The caption setting must be registered, and it must force and then restore.
if (isNil "A3ACC_ForceCaptions") then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] setting A3ACC_ForceCaptions not found";
};
private _priorCaptions = shownSubtitles;
[true] call _applyCaptions;
if (!shownSubtitles) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] subtitles were not forced on";
};
[false] call _applyCaptions;
if (shownSubtitles != _priorCaptions) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] subtitles were not restored";
};

// The clutter setting must be registered, and it must reduce and then restore.
if (isNil "A3ACC_ReduceClutter") then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] setting A3ACC_ReduceClutter not found";
};
private _priorHud = shownHUD;
[true] call _applyClutter;
private _reduced = shownHUD;
if ((_reduced select 8) || {_reduced select 9}) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] clutter was not reduced";
};
[false] call _applyClutter;
if (shownHUD isNotEqualTo _priorHud) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] HUD was not restored";
};

// The legibility setting must be registered, and it must enlarge and restore.
if (isNil "A3ACC_MapLegibility") then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] setting A3ACC_MapLegibility not found";
};
private _legMarker = "a3acc_leg_marker";
createMarker [_legMarker, [0, 0, 0]];
_legMarker setMarkerSizeLocal [1, 1];
_legMarker setMarkerAlphaLocal 0.5;
[true] call _applyLegibility;
if ((markerSize _legMarker) isNotEqualTo [1.2, 1.2] || {markerAlpha _legMarker != 1}) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] marker was not enlarged";
};
[false] call _applyLegibility;
if ((markerSize _legMarker) isNotEqualTo [1, 1] || {markerAlpha _legMarker != 0.5}) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] marker size was not restored";
};
deleteMarker _legMarker;

// Cycling must advance the mode. The keybind itself is verified by a client test.
private _beforeCycle = missionNamespace getVariable ["A3ACC_CVDMode", 0];
call FUNC(cycleMode);
private _afterCycle = missionNamespace getVariable ["A3ACC_CVDMode", 0];
if (_afterCycle == _beforeCycle) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] cycleMode did not change the mode";
};
["A3ACC_CVDMode", _beforeCycle] call CBA_settings_fnc_set;

// The motor walk toggle must be registered and must not error.
if (isNil "A3ACC_ForceWalk") then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] setting A3ACC_ForceWalk not found";
};
[true] call _applyWalk;
[false] call _applyWalk;

// The directional cue setting must be registered.
if (isNil "A3ACC_SoundCues") then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] setting A3ACC_SoundCues not found";
};

(missionNamespace getVariable ["A3ACC_testResults", []]) pushBack (_fail == 0);
if (_fail == 0) then { diag_log text "[A3ACC] setting tests passed"; };
