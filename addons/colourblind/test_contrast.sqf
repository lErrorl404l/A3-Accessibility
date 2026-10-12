#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Recompute the WCAG 2.2 contrast ratio from the live config. The offline
 * verifier reads the source headers. This reads what the engine loaded, so a
 * build that mangles a value is caught. Every gated pair must clear 3:1.
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

// Read the live marker palette. The objective class has no config class, so it
// comes from the loaded function.
private _engineNames = ["ColorWEST", "ColorEAST", "ColorGUER", "ColorUNKNOWN", "ColorCIV"];
private _classNames = ["friendly", "enemy", "neutral", "unknown", "civilian"];

private _table = createHashMap;
{
    private _mode = _x;
    private _row = createHashMap;
    {
        private _className = _classNames select (_engineNames find _x);
        private _configName = [_mode, _x] call FUNC(colourNameFor);
        _row set [_className, getArray (configFile >> "CfgMarkerColors" >> _configName >> "color")];
    } forEach _engineNames;
    _row set ["objective", [_mode, "objective"] call FUNC(paletteForMode)];
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


// The fixed-name HUD surfaces carry the universal palette, and it must equal the
// Protan table, because those classes cannot switch mode.
private _side = configFile >> "CfgInGameUI" >> "SideColors";
private _hud = createHashMapFromArray [
    ["friendly", getArray (_side >> "colorFriendly")],
    ["enemy", getArray (_side >> "colorEnemy")],
    ["neutral", getArray (_side >> "colorNeutral")],
    ["civilian", getArray (_side >> "colorCivilian")],
    ["unknown", getArray (_side >> "colorUnknown")]
];

{
    _x params ["_a", "_b"];
    private _ratio = [(_hud get _a), (_hud get _b)] call _fnc_contrast;
    if (_ratio < 3) then {
        _fail = _fail + 1;
        diag_log text format ["[A3ACC] HUD contrast %1 vs %2 = %3, below 3:1", _a, _b, _ratio];
    };
} forEach [["friendly", "enemy"], ["friendly", "neutral"], ["enemy", "civilian"], ["friendly", "unknown"]];

{
    _x params ["_name", "_className"];
    private _protan = (_table get 1) get _className;
    if (((_hud get _name) select [0, 3]) isNotEqualTo (_protan select [0, 3])) then {
        _fail = _fail + 1;
        diag_log text format ["[A3ACC] HUD %1 does not equal protan %2", _name, _className];
    };
} forEach [["friendly", "friendly"], ["enemy", "enemy"], ["neutral", "neutral"], ["civilian", "civilian"], ["unknown", "unknown"]];


// The marker, group-icon and location side colours must also equal Protan.
{
    _x params ["_cfgPath", "_class", "_className"];
    private _rgba = getArray (configFile >> _cfgPath >> _class >> "color");
    private _protan = (_table get 1) get _className;
    if ((_rgba select [0, 3]) isNotEqualTo (_protan select [0, 3])) then {
        _fail = _fail + 1;
        diag_log text format ["[A3ACC] %1 %2 does not equal protan %3", _cfgPath, _class, _className];
    };
} forEach [
    ["CfgMarkers", "b_unknown", "friendly"],
    ["CfgMarkers", "o_unknown", "enemy"],
    ["CfgMarkers", "n_unknown", "neutral"],
    ["CfgGroupIcons", "b_unknown", "friendly"],
    ["CfgGroupIcons", "o_unknown", "enemy"],
    ["CfgGroupIcons", "n_unknown", "neutral"],
    ["CfgLocationTypes", "b_unknown", "friendly"],
    ["CfgLocationTypes", "o_unknown", "enemy"],
    ["CfgLocationTypes", "n_unknown", "neutral"]
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
    ["A3ACC_RscStructuredText", configFile >> "A3ACC_RscStructuredText"],
    ["objective panel", configFile >> "RscTitles" >> "A3ACC_ObjectiveHud" >> "controls" >> "Objective"]
];

(missionNamespace getVariable ["A3ACC_testResults", []]) pushBack (_fail == 0);
if (_fail == 0) then { diag_log text "[A3ACC] contrast tests passed"; };
