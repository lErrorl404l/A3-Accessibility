[
    "A3ACC_ReduceClutter",
    "CHECKBOX",
    ["Reduce HUD clutter",
     "Hide the kill feed and panel groups, hide the HUD group icons, and mute the radio chatter."],
    "A3 Accessibility",
    false,
    0,
    { [_this] call FUNC(applyClutter) },
    false
] call CBA_fnc_addSetting;

[
    "A3ACC_ObjectiveHud",
    "CHECKBOX",
    ["Show the current objective",
     "Show a small always-on panel with the current task."],
    "A3 Accessibility",
    false,
    0,
    { [_this] call FUNC(objectiveHud) },
    false
] call CBA_fnc_addSetting;
