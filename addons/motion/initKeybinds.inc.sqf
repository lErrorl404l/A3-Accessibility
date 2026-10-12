// Unbound by default. CBA keybinds are client-only, so this registers at a
// client, not on a dedicated server.

[
    "a3acc",
    "toggleShake",
    ["Toggle camera shake reduction", "Toggle the camera shake reduction."],
    { ["A3ACC_ReduceMotion"] call (missionNamespace getVariable ["A3ACC_main_fnc_toggleSetting", {}]) },
    "",
    [0, [false, false, false]],
    false,
    0,
    false
] call CBA_fnc_addKeybind;
