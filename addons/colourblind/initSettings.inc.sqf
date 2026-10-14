[
    "A3ACC_CVDMode",
    "LIST",
    ["Colour blind mode",
     "Recolour the colours that carry side and status meaning, so sides and status stay distinct."],
    "A3 Accessibility",
    [[0, 1, 2, 3, 4],
     ["Off", "Protan", "Deutan", "Tritan", "Achromatopsia"],
     0],
    0,
    { [_this] call FUNC(applyMode); [_this] call FUNC(applyVars); [_this] call FUNC(applyFrame); [_this] call FUNC(reapplyDisplays); diag_log text format ["[A3ACC] setting changed to %1", _this]; ["setting"] call FUNC(logState) },
    false
] call CBA_fnc_addSetting;
