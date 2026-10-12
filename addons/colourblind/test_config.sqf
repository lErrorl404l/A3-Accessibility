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

// The fixed-name HUD, scoreboard and notification surfaces must carry the
// universal palette, because they cannot switch mode.
private _side = configFile >> "CfgInGameUI" >> "SideColors";
if ((getArray (_side >> "colorFriendly")) isNotEqualTo [0, 0.35, 0.85, 1]) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] SideColors colorFriendly not overridden";
};
if ((getArray (_side >> "colorEnemy")) isNotEqualTo [1, 0.7, 0, 1]) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] SideColors colorEnemy not overridden";
};
if ((getArray (configFile >> "CfgInGameUI" >> "MPTable" >> "colorWest")) isNotEqualTo [0, 0.35, 0.85, 1]) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] MPTable colorWest not overridden";
};
if ((getArray (configFile >> "CfgNotifications" >> "TaskFailed" >> "color")) isNotEqualTo [1, 0.7, 0, 1]) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] CfgNotifications TaskFailed not overridden";
};


// The marker and group-icon side colours must carry the universal palette.
private _markerSide = configFile >> "CfgMarkers" >> "b_unknown" >> "color";
if ((getArray _markerSide) isNotEqualTo [0, 0.35, 0.85, 1]) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] CfgMarkers b_unknown not overridden";
};
private _groupSide = configFile >> "CfgGroupIcons" >> "o_unknown" >> "color";
if ((getArray _groupSide) isNotEqualTo [1, 0.7, 0, 1]) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] CfgGroupIcons o_unknown not overridden";
};


// The accessibility help screen must exist for the pause menu entry to open.
if (!isClass (configFile >> "A3ACC_RscDisplayAccessibility")) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] accessibility help display not found";
};


// The vehicle optic HUD must carry the universal palette, not the side red.
private _opticRed = configFile >> "RscInGameUI" >> "RscOptics_crows" >> "CA_IGUI_elements_group" >> "controls" >> "CA_TurretIndicator" >> "color";
if ((getArray _opticRed) isNotEqualTo [1, 0.7, 0, 1]) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] RscInGameUI optic colour not overridden";
};


// The map location side colours must carry the universal palette.
private _locSide = configFile >> "CfgLocationTypes" >> "n_unknown" >> "color";
if ((getArray _locSide) isNotEqualTo [0, 0.8, 0.8, 1]) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] CfgLocationTypes n_unknown not overridden";
};

(missionNamespace getVariable ["A3ACC_testResults", []]) pushBack (_fail == 0);
if (_fail == 0) then { diag_log text "[A3ACC] config tests passed"; };
