[
    "A3ACC_ReduceMotion",
    "CHECKBOX",
    ["Reduce camera shake",
     "Remove camera shake, for motion sensitivity."],
    "A3 Accessibility",
    false,
    0,
    { [_this] call FUNC(applyMotion) },
    false
] call CBA_fnc_addSetting;
