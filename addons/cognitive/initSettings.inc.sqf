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
