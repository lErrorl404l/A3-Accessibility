[
    "A3ACC_ForceWalk",
    "CHECKBOX",
    ["Always walk",
     "Force a walk, so no key is needed to change speed. This is visible to other players."],
    "A3 Accessibility",
    false,
    0,
    { [_this] call FUNC(applyWalk) },
    false
] call CBA_fnc_addSetting;
