[] spawn {
    private _tag = "[A3ACC-PROBE]";
    if (!hasInterface) exitWith {
        diag_log text format ["%1 no interface, nothing applied", _tag];
    };
    private _applyFrame = missionNamespace getVariable ["A3ACC_colourblind_fnc_applyFrame", nil];
    private _colourForRole = missionNamespace getVariable ["A3ACC_colourblind_fnc_colourForRole", nil];
    if (isNil "_applyFrame" || isNil "_colourForRole") exitWith {
        diag_log text format ["%1 the addon is not loaded, nothing applied", _tag];
    };
    private _display = findDisplay 46;
    if (isNull _display) exitWith {
        diag_log text format ["%1 no HUD display is open, nothing applied", _tag];
    };
    if (!isNil { missionNamespace getVariable "A3ACC_colourblind_ppHandle" }) then {
        diag_log text format ["%1 the addon's frame is live. Set the mode to Off and run the probe again, so only this probe's transform is on the screen", _tag];
    };
    private _mode = 1;
    private _specs = [
        ["OPFOR",   [1, 0, 0, 1], [_mode, "enemy"] call _colourForRole],
        ["BLUFOR",  [0, 1, 1, 1], [_mode, "friendly"] call _colourForRole],
        ["white",   [1, 1, 1, 1], [1, 1, 1, 1]],
        ["black",   [0, 0, 0, 1], [0, 0, 0, 1]],
        ["no-role", [0, 1, 0, 1], [0, 1, 0, 1]]
    ];
    private _controls = [];
    {
        _x params ["_label", "_base", "_rule"];
        private _ctrl = _display ctrlCreate ["RscText", 910 + _forEachIndex];
        _ctrl ctrlSetPosition [0.02 + (0.075 * _forEachIndex), 0.80, 0.07, 0.06];
        _ctrl ctrlSetText _label;
        _ctrl ctrlSetTextColor [1, 1, 1, 1];
        _ctrl ctrlSetBackgroundColor _base;
        _ctrl ctrlCommit 0;
        _controls pushBack _ctrl;
    } forEach _specs;
    diag_log text format ["%1 double-transform probe, mode %2. Five controls across the bottom of the screen.", _tag, _mode];
    {
        _x params ["_label", "_base", "_rule"];
        diag_log text format ["%1   %2 base=%3 rule=%4", _tag, _label, str _base, str _rule];
    } forEach _specs;
    private _states = [
        ["A rule off, frame off", false, false],
        ["B rule off, frame on",  false, true],
        ["C rule on,  frame off", true,  false],
        ["D rule on,  frame on",  true,  true]
    ];
    {
        _x params ["_name", "_ruleOn", "_frameOn"];
        [if (_frameOn) then { _mode } else { 0 }] call _applyFrame;
        {
            _x params ["_label", "_base", "_rule"];
            private _colour = if (_ruleOn) then { _rule } else { _base };
            private _ctrl = _controls select _forEachIndex;
            _ctrl ctrlSetBackgroundColor _colour;
            _ctrl ctrlCommit 0;
        } forEach _specs;
        diag_log text format ["%1 STATE %2. Look now: pick the on-screen colour of each of the five controls.", _tag, _name];
        {
            _x params ["_label", "_base", "_rule"];
            diag_log text format ["%1   %2 configured=%3", _tag, _label, str (if (_ruleOn) then { _rule } else { _base })];
        } forEach _specs;
        sleep 12;
    } forEach _states;
    [0] call _applyFrame;
    {
        _x params ["_label", "_base", "_rule"];
        (_controls select _forEachIndex) ctrlSetBackgroundColor _base;
        (_controls select _forEachIndex) ctrlCommit 0;
    } forEach _specs;
    diag_log text format ["%1 the frame is off and the controls are back at their base colours", _tag];
    if (isNil "CBA_settings_fnc_set") exitWith {
        diag_log text format ["%1 CBA settings are not available, the remaining checks are skipped", _tag];
        { ctrlDelete _x; } forEach _controls;
    };
    diag_log text format ["%1 SETTING A3ACC_ObjectiveHud: on", _tag];
    ["A3ACC_ObjectiveHud", true] call CBA_settings_fnc_set;
    sleep 3;
    diag_log text format ["%1   on: playerEH=%2 pfh=%3 panel=%4", _tag, !isNil "A3ACC_objectivePlayerEH", !isNil "A3ACC_objectivePFH", !isNull (uiNamespace getVariable ["A3ACC_ObjectiveHud", displayNull])];
    diag_log text format ["%1   LOOK: the objective panel shows the current task. 15 seconds.", _tag];
    sleep 15;
    ["A3ACC_ObjectiveHud", false] call CBA_settings_fnc_set;
    sleep 3;
    diag_log text format ["%1   off: playerEH=%2 pfh=%3 panel=%4", _tag, !isNil "A3ACC_objectivePlayerEH", !isNil "A3ACC_objectivePFH", !isNull (uiNamespace getVariable ["A3ACC_ObjectiveHud", displayNull])];
    diag_log text format ["%1 SETTING A3ACC_SoundCues: on", _tag];
    ["A3ACC_SoundCues", true] call CBA_settings_fnc_set;
    sleep 3;
    diag_log text format ["%1   on: firedNear=%2 pfh=%3", _tag, !isNil "A3ACC_soundCueHandle", !isNil "A3ACC_soundCuePFH"];
    diag_log text format ["%1   LOOK: have a unit fire within 20 m. A GUNFIRE cue appears in the direction of the fire. 20 seconds.", _tag];
    sleep 20;
    ["A3ACC_SoundCues", false] call CBA_settings_fnc_set;
    sleep 3;
    diag_log text format ["%1   off: firedNear=%2 pfh=%3", _tag, !isNil "A3ACC_soundCueHandle", !isNil "A3ACC_soundCuePFH"];
    diag_log text format ["%1 SETTING A3ACC_ForceWalk: on. LOOK: try to sprint. You should walk only. 15 seconds.", _tag];
    ["A3ACC_ForceWalk", true] call CBA_settings_fnc_set;
    sleep 15;
    ["A3ACC_ForceWalk", false] call CBA_settings_fnc_set;
    sleep 2;
    diag_log text format ["%1 SETTING A3ACC_ForceWalk: off. LOOK: try to sprint. Sprint returns. 10 seconds.", _tag];
    sleep 10;
    ["A3ACC_ReduceMotion", false] call CBA_settings_fnc_set;
    sleep 2;
    addCamShake [6, 3, 30];
    diag_log text format ["%1 SETTING A3ACC_ReduceMotion: off. LOOK: the screen should shake. 10 seconds.", _tag];
    sleep 10;
    ["A3ACC_ReduceMotion", true] call CBA_settings_fnc_set;
    sleep 2;
    addCamShake [6, 3, 30];
    diag_log text format ["%1 SETTING A3ACC_ReduceMotion: on. LOOK: the screen should not shake. 10 seconds.", _tag];
    sleep 10;
    ["A3ACC_ReduceMotion", false] call CBA_settings_fnc_set;
    sleep 2;
    ["A3ACC_CVDMode", _mode] call CBA_settings_fnc_set;
    sleep 3;
    diag_log text format ["%1 ZEUS: open Zeus (Y). The SideOPFOR row should be amber and the SideIndependent row cyan, not vanilla red and green. 40 seconds.", _tag];
    diag_log text format ["%1   machine: ColorEAST=%2 ColorGUER=%3", _tag, str getArray (configFile >> "CfgMarkerColors" >> "ColorEAST" >> "color"), str getArray (configFile >> "CfgMarkerColors" >> "ColorGUER" >> "color")];
    diag_log text format ["%1   machine: A3ACC_palette=%2", _tag, str (missionNamespace getVariable ["A3ACC_palette", []])];
    sleep 40;
    diag_log text format ["%1 MARKERS: place a flag marker, a group icon, the ORBAT default and a Minefield marker. Each should follow the mode. 40 seconds.", _tag];
    sleep 40;
    diag_log text format ["%1 LINE 1: with the mode active, draw a freehand line on the map. Pick its colour. 30 seconds.", _tag];
    sleep 30;
    ["A3ACC_CVDMode", 0] call CBA_settings_fnc_set;
    sleep 3;
    diag_log text format ["%1   machine: after Off, ColorEAST=%2", _tag, str getArray (configFile >> "CfgMarkerColors" >> "ColorEAST" >> "color")];
    diag_log text format ["%1 LINE 2: draw a second line now. The first must keep its mode colour, the second is vanilla. 30 seconds.", _tag];
    sleep 30;
    ["A3ACC_CVDMode", _mode] call CBA_settings_fnc_set;
    sleep 3;
    diag_log text format ["%1 FRAME LINES: the RPT now holds 'frame handle=1991' and, from the Off above, 'frame off destroyed'.", _tag];
    diag_log text format ["%1 RESTART: leave the mode at %2. Quit and restart. The RPT must hold 'preStart: setting=nil saved=%2'.", _tag, _mode];
    { ctrlDelete _x; } forEach _controls;
    diag_log text format ["%1 probe controls removed. Leave the mode at %2 and restart for the last check.", _tag, _mode];
};
