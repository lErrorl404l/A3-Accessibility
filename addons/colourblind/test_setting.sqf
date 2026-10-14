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

// The created-marker event path recolours one marker, not the whole set. It must
// set the marker it is given and leave every other marker alone.
private _one = "a3acc_test_marker_one";
private _other = "a3acc_test_marker_other";
createMarker [_one, [0, 0, 0]];
createMarker [_other, [0, 0, 0]];
_one setMarkerColorLocal "ColorEAST";
_other setMarkerColorLocal "ColorWEST";
private _rgbaEast = [1, "OPFOR"] call FUNC(surfaceColourFor);
private _wantEast = format ["#(%1,%2,%3,1)", _rgbaEast select 0, _rgbaEast select 1, _rgbaEast select 2];
[1, _one] call FUNC(applyMode);
if ((getMarkerColor _one) != _wantEast) then {
    _fail = _fail + 1;
    diag_log text format ["[A3ACC] single-marker apply: %1 want %2", getMarkerColor _one, _wantEast];
};
if ((getMarkerColor _other) != "ColorWEST") then {
    _fail = _fail + 1;
    diag_log text format ["[A3ACC] single-marker apply touched another marker: %1", getMarkerColor _other];
};
deleteMarker _one;
deleteMarker _other;

// The created-marker event must recolour a marker created after the mode is on,
// with no toggle. fnc_watch returns early without an interface, so a dedicated
// server never registers the handler and this block is skipped here. The client
// tier covers it: docs/QA-accessibility.md.
if (hasInterface) then {
    missionNamespace setVariable ["A3ACC_CVDMode", 1];
    private _late = "a3acc_test_marker_late";
    createMarker [_late, [0, 0, 0]];
    _late setMarkerColorLocal "ColorWEST";
    private _deadline = diag_tickTime + 5;
    waitUntil { (getMarkerColor _late) isNotEqualTo "ColorWEST" || {diag_tickTime > _deadline} };
    if ((getMarkerColor _late) != _want) then {
        _fail = _fail + 1;
        diag_log text format ["[A3ACC] the created-marker handler did not recolour a new marker: %1", getMarkerColor _late];
    };
    deleteMarker _late;
    missionNamespace setVariable ["A3ACC_CVDMode", 0];
};

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

// Cycling must advance the mode. The keybind itself is verified by a client test.
private _beforeCycle = missionNamespace getVariable ["A3ACC_CVDMode", 0];
call FUNC(cycleMode);
private _afterCycle = missionNamespace getVariable ["A3ACC_CVDMode", 0];
if (_afterCycle == _beforeCycle) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] cycleMode did not change the mode";
};
["A3ACC_CVDMode", _beforeCycle] call CBA_settings_fnc_set;

(missionNamespace getVariable ["A3ACC_testResults", []]) pushBack (_fail == 0);
if (_fail == 0) then { diag_log text "[A3ACC] setting tests passed"; };
