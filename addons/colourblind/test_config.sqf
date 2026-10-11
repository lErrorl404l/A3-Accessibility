#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Assert every CfgMarkerColors entry equals the pure function output.
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _fail = 0;
private _engineNames = ["ColorWEST", "ColorEAST", "ColorGUER", "ColorUNKNOWN", "ColorCIV"];
private _classNames = ["friendly", "enemy", "neutral", "unknown", "civilian"];

{
    private _mode = _x;
    {
        private _engineName = _x;
        private _className = _classNames select (_engineNames find _engineName);
        private _expected = [_mode, _className] call FUNC(paletteForMode);
        private _configName = [_mode, _engineName] call FUNC(colourNameFor);
        private _class = configFile >> "CfgMarkerColors" >> _configName;
        private _actual = getArray (_class >> "color");
        if ((getNumber (_class >> "scope")) < 1) then {
            _fail = _fail + 1;
            diag_log text format ["[A3ACC] config %1 scope is not public", _configName];
        };
        if ((count _actual) != 4) then {
            _fail = _fail + 1;
            diag_log text format ["[A3ACC] config %1 does not have four values", _configName];
        };
        if (_actual isNotEqualTo _expected) then {
            _fail = _fail + 1;
            diag_log text format ["[A3ACC] config %1 mismatch: %2 vs %3", _configName, str _actual, str _expected];
        };
    } forEach _engineNames;
} forEach [1, 2, 3, 4];

// The vanilla structured-text base must still resolve, and the addon copy must be well formed.
if (isNull (configFile >> "RscStructuredText")) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] RscStructuredText is missing";
};
private _addonText = configFile >> "A3ACC_RscStructuredText";
if (isNull _addonText) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] A3ACC_RscStructuredText is missing";
} else {
    if ((count (getArray (_addonText >> "colorBackground"))) != 4) then {
        _fail = _fail + 1;
        diag_log text "[A3ACC] A3ACC_RscStructuredText colorBackground is not four values";
    };
    if ((count (getArray (_addonText >> "colorText"))) != 4) then {
        _fail = _fail + 1;
        diag_log text "[A3ACC] A3ACC_RscStructuredText colorText is not four values";
    };
};

(missionNamespace getVariable ["A3ACC_testResults", []]) pushBack (_fail == 0);
if (_fail == 0) then { diag_log text "[A3ACC] config tests passed"; };
