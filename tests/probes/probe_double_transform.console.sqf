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
    private _stale = _display displayCtrl 916;
    if (!isNull _stale) then { ctrlDelete _stale; };
    private _stepLabel = _display ctrlCreate ["RscText", 916];
    _stepLabel ctrlSetPosition [0.02, 0.70, 0.96, 0.05];
    _stepLabel ctrlSetBackgroundColor [0, 0, 0, 0.8];
    _stepLabel ctrlSetTextColor [1, 1, 1, 1];
    _stepLabel ctrlSetFontHeight 0.05;
    _stepLabel ctrlSetText "A3ACC probe: starting";
    _stepLabel ctrlCommit 0;
    private _fn_wait = {
        params ["_step", "_text", "_seconds"];
        private _end = diag_tickTime + _seconds;
        while { diag_tickTime < _end } do {
            _stepLabel ctrlSetText format ["STEP %1: %2 (%3 s)", _step, _text, ceil (_end - diag_tickTime)];
            _stepLabel ctrlCommit 0;
            sleep 0.25;
        };
    };
    if (!isNil { missionNamespace getVariable "A3ACC_colourblind_ppHandle" }) then {
        diag_log text format ["%1 the addon's frame is live. Set the mode to Off and run the probe again, so only this probe's transform is on the screen", _tag];
        systemChat format ["%1 the addon's frame is live. Set the mode to Off and run the probe again.", _tag];
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
        private _ctrl = _display ctrlCreate ["RscText", 920 + _forEachIndex];
        _ctrl ctrlSetPosition [0.02 + (0.075 * _forEachIndex), 0.80, 0.07, 0.06];
        _ctrl ctrlSetText _label;
        _ctrl ctrlSetTextColor [1, 1, 1, 1];
        _ctrl ctrlSetBackgroundColor _base;
        _ctrl ctrlCommit 0;
        _controls pushBack _ctrl;
    } forEach _specs;
    diag_log text format ["%1 double-transform probe, mode %2. Five controls across the bottom of the screen.", _tag, _mode];
    systemChat format ["%1 double-transform probe, mode %2. Five controls across the bottom of the screen.", _tag, _mode];
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
        systemChat format ["%1 STATE %2. Pick the five control colours now.", _tag, _name];
        {
            _x params ["_label", "_base", "_rule"];
            diag_log text format ["%1   %2 configured=%3", _tag, _label, str (if (_ruleOn) then { _rule } else { _base })];
        } forEach _specs;
        [1, format ["state %1", _name], 12] call _fn_wait;
    } forEach _states;
    [0] call _applyFrame;
    {
        _x params ["_label", "_base", "_rule"];
        (_controls select _forEachIndex) ctrlSetBackgroundColor _base;
        (_controls select _forEachIndex) ctrlCommit 0;
    } forEach _specs;
    diag_log text format ["%1 the frame is off and the controls are back at their base colours", _tag];
    systemChat format ["%1 the frame is off and the controls are back at their base colours", _tag];
    private _nameHandle = ppEffectCreate ["colorCorrections", 1700];
    if (_nameHandle < 0) then {
        diag_log text format ["%1 NAME-FORM: the probe effect create returned %2, so the priority 1700 is taken and this check is skipped", _tag, _nameHandle];
        systemChat format ["%1 NAME-FORM skipped: the priority 1700 is taken.", _tag];
    } else {
        _nameHandle ppEffectEnable true;
        sleep 0.5;
        private _byName = ppEffectEnabled "colorCorrections";
        private _byHandle = ppEffectEnabled _nameHandle;
        diag_log text format ["%1 NAME-FORM: enabled the probe handle %2 at priority 1700. ppEffectEnabled by name=%3, by handle=%4", _tag, _nameHandle, _byName, _byHandle];
        systemChat format ["%1 NAME-FORM: ppEffectEnabled by name=%2, by handle=%3.", _tag, _byName, _byHandle];
        "colorCorrections" ppEffectEnable false;
        sleep 0.5;
        private _afterName = ppEffectEnabled _nameHandle;
        diag_log text format ["%1 NAME-FORM: after the bare name is set to false, the probe handle reads %2", _tag, _afterName];
        ppEffectDestroy _nameHandle;
        private _afterDestroy = ppEffectEnabled "colorCorrections";
        diag_log text format ["%1 NAME-FORM: destroyed the probe handle. ppEffectEnabled by name now reads %2", _tag, _afterDestroy];
        private _answer = if (!_byName) then {
            "a bare name did not reach an enabled instance, so a name-form call cannot adjust or disable this effect"
        } else {
            if (!_afterName) then {
                "a bare name reached this probe's own instance, so a name-form call can adjust or disable this effect"
            } else {
                "a bare name reached a different instance, so this probe's own instance stayed enabled"
            }
        };
        diag_log text format ["%1 NAME-FORM CONCLUSION: %2", _tag, _answer];
        systemChat format ["%1 NAME-FORM CONCLUSION: %2", _tag, _answer];
        ["1b", "name form: does a bare effect name reach our instance?", 10] call _fn_wait;
    };
    if (isNil "CBA_settings_fnc_set") exitWith {
        diag_log text format ["%1 CBA settings are not available, the remaining checks are skipped", _tag];
        systemChat format ["%1 CBA settings are not available, the remaining checks are skipped", _tag];
        { ctrlDelete _x; } forEach _controls;
        ctrlDelete _stepLabel;
    };
    diag_log text format ["%1 SETTING A3ACC_ObjectiveHud: on", _tag];
    systemChat format ["%1 SETTING A3ACC_ObjectiveHud: on", _tag];
    ["A3ACC_ObjectiveHud", true] call CBA_settings_fnc_set;
    sleep 3;
    diag_log text format ["%1   on: playerEH=%2 pfh=%3 panel=%4", _tag, !isNil "A3ACC_objectivePlayerEH", !isNil "A3ACC_objectivePFH", !isNull (uiNamespace getVariable ["A3ACC_ObjectiveHud", displayNull])];
    diag_log text format ["%1   LOOK: the objective panel shows the current task. 15 seconds.", _tag];
    systemChat format ["%1 LOOK: the objective panel shows the current task.", _tag];
    [2, "objective panel: is the task shown?", 15] call _fn_wait;
    ["A3ACC_ObjectiveHud", false] call CBA_settings_fnc_set;
    sleep 3;
    diag_log text format ["%1   off: playerEH=%2 pfh=%3 panel=%4", _tag, !isNil "A3ACC_objectivePlayerEH", !isNil "A3ACC_objectivePFH", !isNull (uiNamespace getVariable ["A3ACC_ObjectiveHud", displayNull])];
    diag_log text format ["%1 SETTING A3ACC_SoundCues: on", _tag];
    systemChat format ["%1 SETTING A3ACC_SoundCues: on", _tag];
    ["A3ACC_SoundCues", true] call CBA_settings_fnc_set;
    sleep 3;
    diag_log text format ["%1   on: firedNear=%2 pfh=%3", _tag, !isNil "A3ACC_soundCueHandle", !isNil "A3ACC_soundCuePFH"];
    diag_log text format ["%1   LOOK: have a unit fire within 20 m. A GUNFIRE cue appears in the direction of the fire. 20 seconds.", _tag];
    systemChat format ["%1 LOOK: have a unit fire within 20 m. A GUNFIRE cue appears in the direction of the fire.", _tag];
    [3, "gunfire cue: have a unit fire near you", 20] call _fn_wait;
    ["A3ACC_SoundCues", false] call CBA_settings_fnc_set;
    sleep 3;
    diag_log text format ["%1   off: firedNear=%2 pfh=%3", _tag, !isNil "A3ACC_soundCueHandle", !isNil "A3ACC_soundCuePFH"];
    diag_log text format ["%1 SETTING A3ACC_ForceWalk: on. LOOK: try to sprint. You should walk only. 15 seconds.", _tag];
    systemChat format ["%1 LOOK: try to sprint. You should walk only.", _tag];
    ["A3ACC_ForceWalk", true] call CBA_settings_fnc_set;
    [4, "always walk: try to sprint", 15] call _fn_wait;
    ["A3ACC_ForceWalk", false] call CBA_settings_fnc_set;
    sleep 2;
    diag_log text format ["%1 SETTING A3ACC_ForceWalk: off. LOOK: try to sprint. Sprint returns. 10 seconds.", _tag];
    systemChat format ["%1 LOOK: try to sprint. Sprint returns.", _tag];
    [5, "always walk off: sprint returns", 10] call _fn_wait;
    ["A3ACC_ReduceMotion", false] call CBA_settings_fnc_set;
    sleep 2;
    addCamShake [6, 3, 30];
    diag_log text format ["%1 SETTING A3ACC_ReduceMotion: off. LOOK: the screen should shake. 10 seconds.", _tag];
    systemChat format ["%1 LOOK: the screen should shake.", _tag];
    [6, "reduce motion off: the screen should shake", 10] call _fn_wait;
    ["A3ACC_ReduceMotion", true] call CBA_settings_fnc_set;
    sleep 2;
    addCamShake [6, 3, 30];
    diag_log text format ["%1 SETTING A3ACC_ReduceMotion: on. LOOK: the screen should not shake. 10 seconds.", _tag];
    systemChat format ["%1 LOOK: the screen should not shake.", _tag];
    [7, "reduce motion on: the screen should not shake", 10] call _fn_wait;
    ["A3ACC_ReduceMotion", false] call CBA_settings_fnc_set;
    sleep 2;
    ["A3ACC_CVDMode", _mode] call CBA_settings_fnc_set;
    sleep 3;
    diag_log text format ["%1 ZEUS: open Zeus (Y). The SideOPFOR row should be amber and the SideIndependent row cyan, not vanilla red and green. 40 seconds.", _tag];
    systemChat format ["%1 LOOK: open Zeus (Y). SideOPFOR should be amber, SideIndependent cyan.", _tag];
    diag_log text format ["%1   machine: ColorEAST=%2 ColorGUER=%3", _tag, str getArray (configFile >> "CfgMarkerColors" >> "ColorEAST" >> "color"), str getArray (configFile >> "CfgMarkerColors" >> "ColorGUER" >> "color")];
    diag_log text format ["%1   machine: A3ACC_palette=%2", _tag, str (missionNamespace getVariable ["A3ACC_palette", []])];
    [8, "Zeus: are the SideOPFOR and SideIndependent rows the mode colours?", 40] call _fn_wait;
    diag_log text format ["%1 MARKERS: place a flag marker, a group icon, the ORBAT default and a Minefield marker. Each should follow the mode. 40 seconds.", _tag];
    systemChat format ["%1 LOOK: place a flag marker, a group icon, the ORBAT default and a Minefield marker.", _tag];
    [9, "markers: place the four markers, each should follow the mode", 40] call _fn_wait;
    diag_log text format ["%1 LINE 1: with the mode active, draw a freehand line on the map. Pick its colour. 30 seconds.", _tag];
    systemChat format ["%1 LOOK: draw a freehand line on the map with the mode active.", _tag];
    [10, "map line 1: draw a freehand line with the mode active", 30] call _fn_wait;
    ["A3ACC_CVDMode", 0] call CBA_settings_fnc_set;
    sleep 3;
    diag_log text format ["%1   machine: after Off, ColorEAST=%2", _tag, str getArray (configFile >> "CfgMarkerColors" >> "ColorEAST" >> "color")];
    diag_log text format ["%1 LINE 2: draw a second line now. The first must keep its mode colour, the second is vanilla. 30 seconds.", _tag];
    systemChat format ["%1 LOOK: draw a second line. The first must keep its colour.", _tag];
    [11, "map line 2: the first line keeps its colour", 30] call _fn_wait;
    ["A3ACC_CVDMode", _mode] call CBA_settings_fnc_set;
    sleep 3;
    diag_log text format ["%1 FRAME LINES: the RPT now holds 'frame handle=1991' and, from the Off above, 'frame off destroyed'.", _tag];
    systemChat format ["%1 FRAME LINES: the RPT now holds 'frame handle=1991' and 'frame off destroyed'.", _tag];
    diag_log text format ["%1 RESTART: leave the mode at %2. Quit and restart. The RPT must hold 'preStart: setting=nil saved=%2'.", _tag, _mode];
    systemChat format ["%1 RESTART: leave the mode at %2, quit, restart, and read the preStart line.", _tag, _mode];
    _stepLabel ctrlSetText format ["A3ACC probe: done. Leave the mode at %1 and restart.", _mode];
    _stepLabel ctrlCommit 0;
    { ctrlDelete _x; } forEach _controls;
    diag_log text format ["%1 probe controls removed. Leave the mode at %2 and restart for the last check.", _tag, _mode];
    systemChat format ["%1 probe controls removed. Leave the mode at %2 and restart for the last check.", _tag, _mode];
};
