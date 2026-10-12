// Addon keybinds. Every action is unbound by default, so a player who does not
// want a key sees no change. XAG 107 and 112: keyboard access to every addon
// action, with no mouse required.

[
    "a3acc",
    "cycleMode",
    ["Cycle colour-blind mode", "Cycle through the colour-blind modes."],
    0,
    0,
    [0, [false, false, false]],
    false,
    0,
    false
] call CBA_fnc_addKeybind;
