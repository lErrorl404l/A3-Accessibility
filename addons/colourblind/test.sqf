#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Run every colour-blind test and return true when all pass.
 * Run from the debug console:
 * execVM "z\a3acc\addons\colourblind\test.sqf"
 *
 * The wait is on the recorded result, not on scriptDone. scriptDone does not
 * become true for every test here, even after the test body has run to its last
 * line, so it cannot be used as the completion signal. The deadline stops one
 * stuck test from hanging the suite. A test that misses the deadline records no
 * result, and the count check below then fails, so the deadline hides nothing.
 *
 * Return Value:
 * All tests passed <BOOL>
 *
 * Public: No
 */

missionNamespace setVariable ["A3ACC_testResults", []];

private _entries = configProperties [configFile >> "A3ACC_Tests", "true"];
{
    private _before = count (missionNamespace getVariable ["A3ACC_testResults", []]);
    execVM getText _x;
    private _deadline = diag_tickTime + 30;
    waitUntil {
        (count (missionNamespace getVariable ["A3ACC_testResults", []])) > _before
        || {diag_tickTime > _deadline}
    };
} forEach _entries;

private _results = missionNamespace getVariable ["A3ACC_testResults", []];
private _allPassed = ((count _results) == (count _entries)) && {(_results find false) == -1};

if (_allPassed) then {
    diag_log text "[A3ACC] all tests passed";
} else {
    diag_log text format ["[A3ACC] tests failed: %1", str _results];
};

// An explicit completion flag. scriptDone does not become true for every test
// here, so it cannot signal that this suite has finished.
missionNamespace setVariable ["A3ACC_testComplete", true];

_allPassed
