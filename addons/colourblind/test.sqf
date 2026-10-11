#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Run every colour-blind test and return true when all pass.
 * Run from the debug console:
 * execVM "z\a3acc\addons\colourblind\test.sqf"
 *
 * Return Value:
 * All tests passed <BOOL>
 *
 * Public: No
 */

missionNamespace setVariable ["A3ACC_testResults", []];

private _entries = configProperties [configFile >> "A3ACC_Tests", "true"];
{
    private _handle = execVM getText _x;
    waitUntil { scriptDone _handle };
} forEach _entries;

private _results = missionNamespace getVariable ["A3ACC_testResults", []];
private _allPassed = ((count _results) == (count _entries)) && {(_results find false) == -1};

if (_allPassed) then {
    diag_log text "[A3ACC] all tests passed";
} else {
    diag_log text format ["[A3ACC] tests failed: %1", str _results];
};

_allPassed
