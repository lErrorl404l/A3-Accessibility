// Unbound by default. CBA keybinds are client-only, so this registers at a
// client, not on a dedicated server.

[
    "a3acc",
    "toggleWalk",
    ["Toggle always walk", "Toggle the always-walk setting."],
    { ["A3ACC_ForceWalk"] call (missionNamespace getVariable ["A3ACC_main_fnc_toggleSetting", {}]) },
    "",
    [0, [false, false, false]],
    false,
    0,
    false
] call CBA_fnc_addKeybind;
