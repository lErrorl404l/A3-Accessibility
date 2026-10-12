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
    { [_this] call A3ACC_colourblind_fnc_applyMode },
    false
] call CBA_fnc_addSetting;

[
    "A3ACC_ReduceMotion",
    "CHECKBOX",
    ["Reduce camera shake",
     "Remove camera shake, for motion sensitivity."],
    "A3 Accessibility",
    false,
    0,
    { [_this] call A3ACC_colourblind_fnc_applyMotion },
    false
] call CBA_fnc_addSetting;

[
    "A3ACC_ForceCaptions",
    "CHECKBOX",
    ["Force subtitles on",
     "Turn the game subtitles on, and restore the previous setting when this is off."],
    "A3 Accessibility",
    false,
    0,
    { [_this] call A3ACC_colourblind_fnc_applyCaptions },
    false
] call CBA_fnc_addSetting;

[
    "A3ACC_ReduceClutter",
    "CHECKBOX",
    ["Reduce HUD clutter",
     "Hide the kill feed and panel groups, hide the HUD group icons, and mute the radio chatter."],
    "A3 Accessibility",
    false,
    0,
    { [_this] call A3ACC_colourblind_fnc_applyClutter },
    false
] call CBA_fnc_addSetting;

[
    "A3ACC_MapLegibility",
    "CHECKBOX",
    ["Larger map markers",
     "Make map markers larger and fully opaque, for low vision."],
    "A3 Accessibility",
    false,
    0,
    { [_this] call A3ACC_colourblind_fnc_applyLegibility },
    false
] call CBA_fnc_addSetting;
