#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Recompute the WCAG 2.2 contrast ratio from the live palette function, and
 * check the writer put those values in the profile variables. Every gated pair
 * must clear 3:1.
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _fail = 0;

private _fnc_luminance = {
    params ["_rgba"];
    _rgba params ["_r", "_g", "_b"];
    private _channel = {
        params ["_c"];
        if (_c <= 0.03928) then { _c / 12.92 } else { ((_c + 0.055) / 1.055) ^ 2.4 }
    };
    (0.2126 * ([_r] call _channel)) + (0.7152 * ([_g] call _channel)) + (0.0722 * ([_b] call _channel))
};

private _fnc_contrast = {
    params ["_a", "_b"];
    private _la = [_a] call _fnc_luminance;
    private _lb = [_b] call _fnc_luminance;
    ((_la max _lb) + 0.05) / ((_la min _lb) + 0.05)
};

// Read the live palette from the pure function. The objective class has no
// engine key, so it stays here.
private _classes = ["friendly", "enemy", "neutral", "unknown", "civilian", "objective"];
private _table = createHashMap;
{
    private _mode = _x;
    private _row = createHashMap;
    {
        _row set [_x, [_mode, _x] call FUNC(paletteForMode)];
    } forEach _classes;
    _table set [_mode, _row];
} forEach [1, 2, 3, 4];

private _gated = [
    [1, [["friendly", "enemy"], ["neutral", "civilian"], ["enemy", "civilian"], ["friendly", "unknown"]]],
    [2, [["friendly", "enemy"], ["neutral", "civilian"], ["enemy", "civilian"], ["friendly", "unknown"]]],
    [3, [["friendly", "enemy"], ["neutral", "civilian"], ["objective", "friendly"], ["enemy", "civilian"]]],
    [4, [["friendly", "enemy"], ["friendly", "neutral"], ["enemy", "neutral"], ["objective", "enemy"], ["objective", "neutral"]]]
];

{
    _x params ["_mode", "_pairs"];
    private _row = _table get _mode;
    {
        _x params ["_a", "_b"];
        private _ratio = [(_row get _a), (_row get _b)] call _fnc_contrast;
        if (_ratio < 3) then {
            _fail = _fail + 1;
            diag_log text format ["[A3ACC] contrast mode %1 %2 vs %3 = %4, below 3:1", _mode, _a, _b, _ratio];
        };
    } forEach _pairs;
} forEach _gated;

// The writer must put the mode colour into the engine variables, so the map,
// ORBAT and marker catalogue follow the mode.
private _engineVars = [
    ["Map_BLUFOR", "BLUFOR"],
    ["Map_OPFOR", "OPFOR"],
    ["Map_Independent", "Independent"],
    ["Map_Civilian", "Civilian"],
    ["Map_Unknown", "Unknown"],
    ["IGUI_ERROR_RGB", "Error"],
    ["IGUI_WARNING_RGB", "Warning"]
];
[2] call FUNC(applyVars);
{
    _x params ["_prefix", "_key"];
    private _want = ([2, _key] call FUNC(surfaceColourFor)) select [0, 3];
    private _got = [
        profileNamespace getVariable [_prefix + "_R", -1],
        profileNamespace getVariable [_prefix + "_G", -1],
        profileNamespace getVariable [_prefix + "_B", -1]
    ];
    if (_got isNotEqualTo _want) then {
        _fail = _fail + 1;
        diag_log text format ["[A3ACC] engine variable %1 = %2, want %3", _prefix, str _got, str _want];
    };
} forEach _engineVars;

// The shipped marker palette resolves a side colour through the engine
// variables. Prove the wiring headlessly: the expression names the variable and
// call compile of it equals the value applyVars wrote. The rendered result still
// needs a client, because no command reads a marker's resolved colour.
{
    _x params ["_class", "_prefix"];
    private _colour = getArray (configFile >> "CfgMarkerColors" >> _class >> "color");
    if (count _colour != 4) then {
        _fail = _fail + 1;
        diag_log text format ["[A3ACC] CfgMarkerColors %1 is not four values", _class];
    } else {
        {
            private _channel = ["R", "G", "B"] select _forEachIndex;
            private _varName = format ["%1_%2", _prefix, _channel];
            if (_x isEqualType "") then {
                if (_varName in _x) then {
                    private _resolved = call compile _x;
                    private _written = profileNamespace getVariable [_varName, -1];
                    if (_resolved != _written) then {
                        _fail = _fail + 1;
                        diag_log text format ["[A3ACC] %1 channel %2 resolves to %3, wrote %4", _class, _channel, _resolved, _written];
                    };
                } else {
                    _fail = _fail + 1;
                    diag_log text format ["[A3ACC] %1 channel %2 does not name %3", _class, _channel, _varName];
                };
            } else {
                _fail = _fail + 1;
                diag_log text format ["[A3ACC] %1 channel %2 is not an expression", _class, _channel];
            };
        } forEach (_colour select [0, 3]);
    };
} forEach [
    ["ColorWEST", "Map_BLUFOR"],
    ["ColorEAST", "Map_OPFOR"]
];

// Text pairs must clear 4.5:1. These are the addon's own text surfaces.
{
    _x params ["_label", "_class"];
    private _ratio = [getArray (_class >> "colorText"), getArray (_class >> "colorBackground")] call _fnc_contrast;
    if (_ratio < 4.5) then {
        _fail = _fail + 1;
        diag_log text format ["[A3ACC] text contrast %1 = %2, below 4.5:1", _label, _ratio];
    };
} forEach [
    ["help screen", configFile >> "A3ACC_RscDisplayAccessibility" >> "controls" >> "Body"],
    ["objective panel", configFile >> "RscTitles" >> "A3ACC_ObjectiveHud" >> "controls" >> "Objective"]
];

[0] call FUNC(applyVars);

(missionNamespace getVariable ["A3ACC_testResults", []]) pushBack (_fail == 0);
if (_fail == 0) then { diag_log text "[A3ACC] contrast tests passed"; };
