[
    "A3ACC_ForceWalk",
    "CHECKBOX",
    ["Always walk",
     "Force a walk. This removes sprint. Other players see the change, and a mission that depends on sprint can break."],
    "A3 Accessibility",
    false,
    0,
    { [_this] call FUNC(applyWalk) },
    false
] call CBA_fnc_addSetting;
