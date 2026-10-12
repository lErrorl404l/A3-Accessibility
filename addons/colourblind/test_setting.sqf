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

// A live marker must recolour on apply and restore on Off.
private _marker = "a3acc_test_marker";
createMarker [_marker, [0, 0, 0]];
_marker setMarkerColor "ColorWEST";
[1] call FUNC(applyMode);
private _after = getMarkerColor _marker;
private _want = [1, "ColorWEST"] call FUNC(colourNameFor);
if (_after != _want) then {
    _fail = _fail + 1;
    diag_log text format ["[A3ACC] marker did not recolour: %1 want %2", _after, _want];
};
[0] call FUNC(applyMode);
_after = getMarkerColor _marker;
if (_after != "ColorWEST") then {
    _fail = _fail + 1;
    diag_log text format ["[A3ACC] marker did not restore: %1", _after];
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
[true] call FUNC(applyMotion);
[false] call FUNC(applyMotion);

// The caption setting must be registered, and it must force and then restore.
if (isNil "A3ACC_ForceCaptions") then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] setting A3ACC_ForceCaptions not found";
};
private _priorCaptions = shownSubtitles;
[true] call FUNC(applyCaptions);
if (!shownSubtitles) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] subtitles were not forced on";
};
[false] call FUNC(applyCaptions);
if (shownSubtitles != _priorCaptions) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] subtitles were not restored";
};

(missionNamespace getVariable ["A3ACC_testResults", []]) pushBack (_fail == 0);
if (_fail == 0) then { diag_log text "[A3ACC] setting tests passed"; };
