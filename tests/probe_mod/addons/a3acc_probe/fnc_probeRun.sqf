// A3ACC client probe driver. DEV ONLY.
//
// This script carries the machine-checkable part of the two client probes in
// tests/probes/. It runs when a mission starts, logs every reading with the
// [A3ACC-PROBE] tag, and writes a DONE marker, so a runner waits on the marker
// and not on a timer.
//
// A rendered claim still needs an eye. Every check that only a person can judge
// is logged as UNVERIFIABLE with its reason, and the runner captures one
// screenshot per STEP line, so the judgement is made from the images.
//
// The probe creates its own task, so the objective-panel check does not depend
// on the mission, and it removes the task and its controls when it finishes.

A3ACC_probe_fnc_log = {
    diag_log text format ["[A3ACC-PROBE] %1", _this];
    systemChat format ["[A3ACC-PROBE] %1", _this];
};

A3ACC_probe_fnc_step = {
    params ["_index", "_label", "_seconds"];
    diag_log text format ["[A3ACC-PROBE] STEP %1 %2", _index, _label];
    systemChat format ["[A3ACC-PROBE] STEP %1 %2", _index, _label];
    private _end = diag_tickTime + _seconds;
    waitUntil { diag_tickTime >= _end };
};

A3ACC_probe_fnc_verdict = {
    params ["_check", "_state", "_detail"];
    diag_log text format ["[A3ACC-PROBE] VERDICT %1 %2 %3", _check, _state, _detail];
    systemChat format ["[A3ACC-PROBE] VERDICT %1 %2", _check, _state];
};

A3ACC_probe_fnc_done = {
    diag_log text "[A3ACC-PROBE] DONE";
    systemChat "[A3ACC-PROBE] DONE";
};

// Compare two RGBA arrays with a small tolerance, because the engine may return
// a stored colour at a different precision.
A3ACC_probe_fnc_same = {
    params ["_a", "_b"];
    if (count _a != count _b) exitWith { false };
    private _ok = true;
    {
        if (abs ((_a select _forEachIndex) - _x) > 0.001) exitWith { _ok = false; };
    } forEach _b;
    _ok
};

// A HUD display (idd 46) exists once the mission runs with a player.
private _deadline = diag_tickTime + 90;
waitUntil { !isNull (findDisplay 46) || diag_tickTime > _deadline };

if (isNull (findDisplay 46)) exitWith {
    "no HUD display opened within 90 s, the probe did not run" call A3ACC_probe_fnc_log;
    ["probe", "FAIL", "no HUD display, so no client interface"] call A3ACC_probe_fnc_verdict;
    call A3ACC_probe_fnc_done;
};

private _frameParams = missionNamespace getVariable ["A3ACC_colourblind_fnc_frameParams", nil];
private _applyFrame = missionNamespace getVariable ["A3ACC_colourblind_fnc_applyFrame", nil];
private _colourForRole = missionNamespace getVariable ["A3ACC_colourblind_fnc_colourForRole", nil];

if (isNil "_frameParams" || isNil "_applyFrame" || isNil "_colourForRole") exitWith {
    "the addon is not loaded, nothing can be checked" call A3ACC_probe_fnc_log;
    ["addon-loaded", "FAIL", "frameParams, applyFrame or colourForRole did not resolve"] call A3ACC_probe_fnc_verdict;
    call A3ACC_probe_fnc_done;
};

["addon-loaded", "PASS", "frameParams, applyFrame and colourForRole resolved"] call A3ACC_probe_fnc_verdict;

// The probe creates its own task. A state of true sets the task current.
private _taskId = "a3acc_probe_task";
private _taskTitle = "A3ACC client probe";
[player, _taskId, [_taskTitle, _taskTitle, ""], objNull, true, 1, false, "default", false] call BIS_fnc_taskCreate;
sleep 2;
private _current = player call BIS_fnc_taskCurrent;
["probe-task", (if (_current isEqualTo _taskId) then {"PASS"} else {"FAIL"}), format ["the probe's own task is current=%1", _current]] call A3ACC_probe_fnc_verdict;

// 1. The per-mode frame parameters. The machine reading is the six values and
//    the effect handle. Whether the picture tints is the eye's.
private _handle = -1;
private _sizes = [];
{
    private _values = [_x] call _frameParams;
    _sizes pushBack (count _values);
    [_x] call _applyFrame;
    private _h = missionNamespace getVariable ["A3ACC_colourblind_ppHandle", nil];
    if (!isNil "_h" && {_h >= 0}) then { _handle = _h; };
    format ["frame mode %1: %2", _x, str _values] call A3ACC_probe_fnc_log;
    [1 + _x, format ["frame mode %1, %2 (5 s)", _x, if (_x == 0) then {"off"} else {"on"}], 5] call A3ACC_probe_fnc_step;
} forEach [0, 1, 2, 3, 4];

["frame-create", (if (_handle >= 0) then {"PASS"} else {"FAIL"}), format ["A3ACC_colourblind_ppHandle=%1 at priority 1991", _handle]] call A3ACC_probe_fnc_verdict;
["frame-sets", (if (_sizes isEqualTo [6, 6, 6, 6, 6]) then {"PASS"} else {"FAIL"}), format ["the six-value set size per mode=%1", str _sizes]] call A3ACC_probe_fnc_verdict;
["frame-render", "UNVERIFIABLE", "whether a mode tints or greys the frame is an eye judgement; judge the five frame-mode images"] call A3ACC_probe_fnc_verdict;

[0] call _applyFrame;
sleep 1;

// 2. The colorize-alpha conflict and the seven-element form, on the probe's own
//    effect at priority 1500. The machine reading is that each adjust was
//    accepted without error. Whether the frame greys is the eye's.
private _alphaHandle = ppEffectCreate ["colorCorrections", 1500];
if (_alphaHandle < 0) then {
    ["frame-alpha", "FAIL", format ["ppEffectCreate returned %1, so priority 1500 is taken", _alphaHandle]] call A3ACC_probe_fnc_verdict;
} else {
    _alphaHandle ppEffectAdjust [1, 1, 0, [0, 0, 0, 0], [1, 1, 1, 1], [0.299, 0.587, 0.114, 0]];
    _alphaHandle ppEffectCommit 0;
    _alphaHandle ppEffectEnable true;
    [6, "alpha 1, the wiki table's reading (5 s)", 5] call A3ACC_probe_fnc_step;
    _alphaHandle ppEffectAdjust [1, 1, 0, [0, 0, 0, 0], [1, 1, 1, 0], [0.299, 0.587, 0.114, 0]];
    _alphaHandle ppEffectCommit 0;
    [7, "alpha 0, the shipped template's reading (5 s)", 5] call A3ACC_probe_fnc_step;
    _alphaHandle ppEffectAdjust [1, 1, 0, [0, 0, 0, 0], [1, 1, 1, 0], [0.299, 0.587, 0.114, 0], [0.7, 0.7, 0, 0, -0.1, 0.4, 0.8]];
    _alphaHandle ppEffectCommit 0;
    [8, "seven elements, radial ellipse (5 s)", 5] call A3ACC_probe_fnc_step;
    _alphaHandle ppEffectEnable false;
    ppEffectDestroy _alphaHandle;
    ["frame-alpha", "UNVERIFIABLE", "the effect was created, adjusted and destroyed with no error; only an eye reads whether an alpha greys the frame, so judge steps 6 and 7"] call A3ACC_probe_fnc_verdict;
};

// 3. The double-transform question. Five controls, four states of the two
//    mechanisms. The machine reading is that each control reads back the colour
//    it was given. Whether the frame transform moves a 2D control is the eye's.
private _mode = 1;
private _display = findDisplay 46;
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

private _states = [
    ["A rule off frame off", false, false],
    ["B rule off frame on",  false, true],
    ["C rule on frame off",  true,  false],
    ["D rule on frame on",   true,  true]
];
private _mismatch = 0;
{
    _x params ["_name", "_ruleOn", "_frameOn"];
    private _stateIndex = _forEachIndex;
    [if (_frameOn) then { _mode } else { 0 }] call _applyFrame;
    {
        _x params ["_label", "_base", "_rule"];
        private _colour = if (_ruleOn) then { _rule } else { _base };
        private _ctrl = _controls select _forEachIndex;
        _ctrl ctrlSetBackgroundColor _colour;
        _ctrl ctrlCommit 0;
        private _read = ctrlBackgroundColor _ctrl;
        if !([_read, _colour] call A3ACC_probe_fnc_same) then { _mismatch = _mismatch + 1; };
        format ["double transform %1: %2 configured=%3 read=%4", _name, _label, str _colour, str _read] call A3ACC_probe_fnc_log;
    } forEach _specs;
    [9 + _stateIndex, format ["double transform %1 (6 s)", _name], 6] call A3ACC_probe_fnc_step;
} forEach _states;

[0] call _applyFrame;
{
    _x params ["_label", "_base", "_rule"];
    (_controls select _forEachIndex) ctrlSetBackgroundColor _base;
    (_controls select _forEachIndex) ctrlCommit 0;
} forEach _specs;

["double-transform", (if (_mismatch == 0) then {"PASS"} else {"FAIL"}), format ["%1 of 20 control reads did not match the colour they were given", _mismatch]] call A3ACC_probe_fnc_verdict;
["double-transform-render", "UNVERIFIABLE", "whether the frame transform moves a 2D control is an eye judgement; judge steps 9 to 12"] call A3ACC_probe_fnc_verdict;

// 4. The objective panel, against the probe's own task. The machine reading is
//    that the frame handler runs and the panel is cut. Whether the task text is
//    legible is the eye's.
["A3ACC_ObjectiveHud", true] call CBA_settings_fnc_set;
sleep 3;
private _pfh = !isNil "A3ACC_objectivePFH";
private _panel = !isNull (uiNamespace getVariable ["A3ACC_ObjectiveHud", displayNull]);
["objective-panel", (if (_pfh && _panel) then {"PASS"} else {"FAIL"}), format ["handler=%1 cut=%2", _pfh, _panel]] call A3ACC_probe_fnc_verdict;
[13, "objective panel on, the probe's own task (6 s)", 6] call A3ACC_probe_fnc_step;
["A3ACC_ObjectiveHud", false] call CBA_settings_fnc_set;
sleep 2;

// 5. The marker colour, driven through the real setting chain. A marker set to
//    a side colour name is recoloured when the mode changes.
private _markerName = "a3acc_probe_marker";
if ((markerShape _markerName) != "") then { deleteMarker _markerName; };
private _marker = createMarker [_markerName, [0, 0, 0]];
_marker setMarkerColor "ColorEAST";
["A3ACC_CVDMode", 1] call CBA_settings_fnc_set;
sleep 3;
private _readMarker = markerColor _marker;
private _wantRgba = [1, "enemy"] call _colourForRole;
private _readRgba = {
    private _s = _this;
    if ((_s select [0, 2]) isEqualTo "#(") then { _s = _s select [2, (count _s) - 3]; };
    (_s splitString ",") apply { parseNumber _x };
} call _readMarker;
private _close = false;
if ((count _readRgba) >= 3 && (count _wantRgba) >= 3) then {
    _close = (abs ((_readRgba select 0) - (_wantRgba select 0)) < 0.03)
        && (abs ((_readRgba select 1) - (_wantRgba select 1)) < 0.03)
        && (abs ((_readRgba select 2) - (_wantRgba select 2)) < 0.03);
};
["markers", (if (_close) then {"PASS"} else {"FAIL"}), format ["markerColor=%1 want=%2", _readMarker, str _wantRgba]] call A3ACC_probe_fnc_verdict;
[14, "markers, mode 1 active (5 s)", 5] call A3ACC_probe_fnc_step;
deleteMarker _markerName;
["A3ACC_CVDMode", 0] call CBA_settings_fnc_set;
sleep 2;

// 6. The four settings the server tier cannot observe. The machine reading is
//    the handler global where one exists. The behaviour is the eye's.
["A3ACC_SoundCues", true] call CBA_settings_fnc_set;
sleep 3;
private _cueOn = !isNil "A3ACC_soundCueHandle";
[15, "sound cues on (4 s)", 4] call A3ACC_probe_fnc_step;
["A3ACC_SoundCues", false] call CBA_settings_fnc_set;
sleep 2;
private _cueOff = isNil "A3ACC_soundCueHandle";
["settings-sound-cues", (if (_cueOn && _cueOff) then {"PASS"} else {"FAIL"}), format ["handle present when on=%1, absent when off=%2", _cueOn, _cueOff]] call A3ACC_probe_fnc_verdict;

["A3ACC_ForceWalk", true] call CBA_settings_fnc_set;
[16, "always walk on, try to sprint (4 s)", 4] call A3ACC_probe_fnc_step;
["A3ACC_ForceWalk", false] call CBA_settings_fnc_set;
["settings-force-walk", "UNVERIFIABLE", "whether sprint is removed is a motor behaviour, not a reading; judge step 16"] call A3ACC_probe_fnc_verdict;

["A3ACC_ReduceMotion", false] call CBA_settings_fnc_set;
addCamShake [6, 3, 30];
[17, "reduce motion off, the screen should shake (4 s)", 4] call A3ACC_probe_fnc_step;
["A3ACC_ReduceMotion", true] call CBA_settings_fnc_set;
addCamShake [6, 3, 30];
[18, "reduce motion on, the screen should not shake (4 s)", 4] call A3ACC_probe_fnc_step;
["A3ACC_ReduceMotion", false] call CBA_settings_fnc_set;
["settings-reduce-motion", "UNVERIFIABLE", "the shake is an eye judgement and no command reads it; judge steps 17 and 18"] call A3ACC_probe_fnc_verdict;

// 7. The Zeus display. It is opened by the player pressing Y, and no command
//    opens it or reads the SideOPFOR row, so this cannot be automated.
[19, "Zeus display, cannot be opened without input (3 s)", 3] call A3ACC_probe_fnc_step;
["zeus-display", "UNVERIFIABLE", "the Zeus display (RscDisplayCurator) is opened by the player pressing Y, and no command opens it or reads the SideOPFOR and SideIndependent rows"] call A3ACC_probe_fnc_verdict;

// Clean up the task and the controls the probe created.
{
    _x params ["_label", "_base", "_rule"];
    private _ctrl = _controls select _forEachIndex;
    if (!isNull _ctrl) then { ctrlDelete _ctrl; };
} forEach _specs;
[_taskId] call BIS_fnc_deleteTask;
["probe-cleanup", "PASS", "the probe's task and controls were removed"] call A3ACC_probe_fnc_verdict;

"every reading above is a machine value, and every UNVERIFIABLE check names the step whose image holds the judgement" call A3ACC_probe_fnc_log;
call A3ACC_probe_fnc_done;
