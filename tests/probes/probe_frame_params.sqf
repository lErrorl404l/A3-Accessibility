// Paste-in client probe for the per-mode frame parameters. Paste the body into
// the Arma 3 debug console at a client, with the mode set to Off, and read the
// result in the RPT.
//
// It answers four questions:
// 1. What does each shipped mode's six-value set look like on the screen?
// 2. Does a colorize alpha of 1 or of 0 grey the picture?
// 3. Does the engine accept the seven-element form?
// 4. Which patch colours move, and which stay as they are?
//
// It writes one line per step to the RPT. The eye judgements are the operator's,
// because no command reads the screen.
//
// It uses its own effect at priority 1500, the base priority the wiki gives for
// ColorCorrections. Set the mode to Off first, so only one transform is live.

private _tag = "[A3ACC-PROBE]";

if (!hasInterface) exitWith {
    diag_log text format ["%1 no interface, nothing applied", _tag];
};

private _frameFn = missionNamespace getVariable ["A3ACC_colourblind_fnc_frameParams", nil];
if (isNil "_frameFn") exitWith {
    diag_log text format ["%1 the addon is not loaded, nothing applied", _tag];
};

private _display = findDisplay 46;
if (isNull _display) exitWith {
    diag_log text format ["%1 no HUD display is open, nothing applied", _tag];
};

// Sixteen known patches. Red, yellow and blue are the three the owner named.
private _patches = [
    ["red",       [1, 0, 0, 1]],
    ["green",     [0, 1, 0, 1]],
    ["blue",      [0, 0, 1, 1]],
    ["yellow",    [1, 1, 0, 1]],
    ["cyan",      [0, 1, 1, 1]],
    ["magenta",   [1, 0, 1, 1]],
    ["white",     [1, 1, 1, 1]],
    ["grey",      [0.5, 0.5, 0.5, 1]],
    ["black",     [0, 0, 0, 1]],
    ["amber",     [1, 0.7, 0, 1]],
    ["mode blue", [0, 0.35, 0.85, 1]],
    ["WEST",      [0.13, 0.41, 0.87, 1]],
    ["EAST",      [0.83, 0.17, 0.17, 1]],
    ["GUER",      [0.18, 0.65, 0.12, 1]],
    ["skin",      [0.8, 0.6, 0.5, 1]],
    ["olive",     [0.4, 0.45, 0.2, 1]]
];

diag_log text format ["%1 patch table (%2 patches):", _tag, count _patches];
systemChat format ["%1 patch table: %2 patches on screen", _tag, count _patches];
{
    _x params ["_label", "_rgba"];
    diag_log text format ["%1   %2 = %3", _tag, _label, str _rgba];
    private _control = _display ctrlCreate ["RscText", 900 + _forEachIndex];
    _control ctrlSetPosition [0.02 + (0.06 * _forEachIndex), 0.86, 0.055, 0.06];
    _control ctrlSetBackgroundColor _rgba;
    _control ctrlSetText _label;
    _control ctrlSetTextColor [1, 1, 1, 1];
    _control ctrlCommit 0;
} forEach _patches;

if (!isNil { missionNamespace getVariable "A3ACC_colourblind_ppHandle" }) then {
    diag_log text format ["%1 the addon's effect is still live. Set the mode to Off and run the probe again, so one transform is on the screen", _tag];
    systemChat format ["%1 the addon's effect is still live. Set the mode to Off and run the probe again.", _tag];
};

[] spawn {
    private _tag = "[A3ACC-PROBE]";
    private _fn = missionNamespace getVariable ["A3ACC_colourblind_fnc_frameParams", nil];

    // One persistent on-screen label, so the operator sees which set is live
    // without reading the report file. It sits above the patch row, and its id
    // 916 is clear of the patch ids 900 to 915.
    private _display = findDisplay 46;
    private _stale = _display displayCtrl 916;
    if (!isNull _stale) then { ctrlDelete _stale; };
    private _stepLabel = _display ctrlCreate ["RscText", 916];
    _stepLabel ctrlSetPosition [0.02, 0.70, 0.96, 0.05];
    _stepLabel ctrlSetBackgroundColor [0, 0, 0, 0.8];
    _stepLabel ctrlSetTextColor [1, 1, 1, 1];
    _stepLabel ctrlSetFontHeight 0.05;
    _stepLabel ctrlSetText "A3ACC frame probe: starting";
    _stepLabel ctrlCommit 0;

    private _handle = ppEffectCreate ["colorCorrections", 1500];

    if (_handle < 0) then {
        diag_log text format ["%1 probe effect create returned %2, the priority is taken", _tag, _handle];
        systemChat format ["%1 probe effect create returned %2, the priority is taken", _tag, _handle];
        _stepLabel ctrlSetText "A3ACC frame probe: the priority is taken, nothing applied";
        _stepLabel ctrlCommit 0;
    } else {
        private _wait = 8;
        private _sets = [];

        for "_mode" from 0 to 4 do {
            _sets pushBack [format ["mode %1", _mode], [_mode] call _fn];
        };

        // The one open question. The wiki's parameter table says an alpha of 1
        // greys the frame. Every worked example and every shipped template says
        // an alpha of 1 is the neutral set and an alpha of 0 is the grey.
        _sets pushBack ["alpha 1 (the wiki table's reading)", [1, 1, 0, [0, 0, 0, 0], [1, 1, 1, 1], [0.299, 0.587, 0.114, 0]]];
        _sets pushBack ["alpha 0 (the shipped template's reading)", [1, 1, 0, [0, 0, 0, 0], [1, 1, 1, 0], [0.299, 0.587, 0.114, 0]]];

        // The seventh array, once. Read the RPT for a type error, and look for a
        // graded centre inside the ellipse.
        _sets pushBack ["seven elements (radial ellipse)", [1, 1, 0, [0, 0, 0, 0], [1, 1, 1, 0], [0.299, 0.587, 0.114, 0], [0.7, 0.7, 0, 0, -0.1, 0.4, 0.8]]];

        // Show the set name and its number of eight, and hold for the same
        // number of seconds the bare sleep used to hold, so the timing is
        // unchanged.
        private _total = count _sets;
        private _index = 0;
        {
            _index = _index + 1;
            _x params ["_label", "_values"];
            _handle ppEffectAdjust _values;
            _handle ppEffectCommit 0;
            _handle ppEffectEnable true;
            diag_log text format ["%1 apply %2 = %3", _tag, _label, str _values];
            systemChat format ["%1 SET %2 of %3: %4", _tag, _index, _total, _label];
            private _end = diag_tickTime + _wait;
            while { diag_tickTime < _end } do {
                _stepLabel ctrlSetText format ["SET %1 of %2: %3 (%4 s)", _index, _total, _label, ceil (_end - diag_tickTime)];
                _stepLabel ctrlCommit 0;
                sleep 0.25;
            };
        } forEach _sets;

        _handle ppEffectEnable false;
        ppEffectDestroy _handle;
        diag_log text format ["%1 done", _tag];
        systemChat format ["%1 frame probe done", _tag];
        diag_log text format ["%1 record one line per apply above: did the picture change, did it go grey or tinted, and did red, yellow and blue stay distinct?", _tag];
        systemChat format ["%1 record each set: did the picture change, did it go grey or tinted, and did red, yellow and blue stay distinct?", _tag];
        _stepLabel ctrlSetText "A3ACC frame probe: done. Paste probe_double_transform.console.sqf next.";
        _stepLabel ctrlCommit 0;
    };
};
