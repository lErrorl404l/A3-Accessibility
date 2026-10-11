// In-engine test entry point. Runs the addon's CBA test suite on the server and
// writes the result to the RPT. tests/ingame/run.sh greps for the DONE marker.
diag_log "[A3ACC-TEST] START";

private _handle = execVM "z\a3acc\addons\colourblind\test.sqf";
waitUntil { scriptDone _handle };

diag_log format ["[A3ACC-TEST] results=%1", missionNamespace getVariable ["A3ACC_testResults", "MISSING"]];
diag_log "[A3ACC-TEST] DONE";
