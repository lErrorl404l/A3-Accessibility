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

(missionNamespace getVariable ["A3ACC_testResults", []]) pushBack (_fail == 0);
if (_fail == 0) then { diag_log text "[A3ACC] setting tests passed"; };
