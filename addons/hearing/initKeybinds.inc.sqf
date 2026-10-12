// Unbound by default. CBA keybinds are client-only, so this registers at a
// client, not on a dedicated server.

[
    "a3acc",
    "toggleCues",
    ["Toggle gunfire cues", "Toggle the directional gunfire cues."],
    { ["A3ACC_SoundCues"] call (missionNamespace getVariable ["A3ACC_main_fnc_toggleSetting", {}]) },
    "",
    [0, [false, false, false]],
    false,
    0,
    false
] call CBA_fnc_addKeybind;
