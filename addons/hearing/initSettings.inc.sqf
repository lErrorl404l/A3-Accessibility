[
    "A3ACC_ForceCaptions",
    "CHECKBOX",
    ["Force subtitles on",
     "Turn the game subtitles on, and restore the previous setting when this is off."],
    "A3 Accessibility",
    false,
    0,
    { [_this] call FUNC(applyCaptions) },
    false
] call CBA_fnc_addSetting;
