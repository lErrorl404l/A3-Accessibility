// In-engine test entry point. Runs the addon's CBA test suite on the server and
// writes the result to the RPT. tests/ingame/run.sh greps for the DONE marker.
diag_log "[A3ACC-TEST] START";

execVM "z\a3acc\addons\colourblind\test.sqf";

// Wait on the flag the suite sets, not on scriptDone, which is unreliable here.
// The deadline stops a stuck suite from hanging the run for ever.
private _deadline = diag_tickTime + 120;
waitUntil {
    !isNil {missionNamespace getVariable "A3ACC_testComplete"}
    || {diag_tickTime > _deadline}
};

diag_log format ["[A3ACC-TEST] results=%1", missionNamespace getVariable ["A3ACC_testResults", "MISSING"]];
diag_log "[A3ACC-TEST] DONE";
