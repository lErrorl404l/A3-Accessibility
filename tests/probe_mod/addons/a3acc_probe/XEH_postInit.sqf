// Test instrument. DEV ONLY. The probe is client only, because only a client has
// a renderer and an interface. A dedicated server logs that it skipped.
if (!hasInterface) exitWith {
    diag_log text "[A3ACC-PROBE] no interface, the client probe does not run here";
};

[] execVM "\z\a3acc_probe\addons\a3acc_probe\fnc_probeRun.sqf";
