[
    "A3ACC_CVDMode",
    "LIST",
    ["Colour blind mode",
     "Select a colour-vision-deficiency palette for map markers."],
    "A3 Accessibility",
    [[0, 1, 2, 3, 4],
     ["Off", "Protan", "Deutan", "Tritan", "Achromatopsia"],
     0],
    0,
    { [_this] call FUNC(applyMode); [_this] call FUNC(applyVars) },
    false
] call CBA_fnc_addSetting;
