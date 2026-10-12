[
    "A3ACC_MapLegibility",
    "CHECKBOX",
    ["Larger map markers",
     "Make map markers larger and fully opaque, for low vision."],
    "A3 Accessibility",
    false,
    0,
    { [_this] call FUNC(applyLegibility) },
    false
] call CBA_fnc_addSetting;
