#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Assert the converted config surfaces read profile-variable expressions, and
 * that the deleted marker overrides are gone.
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _fail = 0;

// A converted colour is a three-expression triple plus a numeric alpha. The
// channel name must match the property. Returns the list of problems.
private _fnc_checkExpr = {
    params ["_cfg", "_varName", "_label"];
    private _problems = [];
    private _arr = getArray _cfg;
    if (count _arr != 4) then {
        _problems pushBack format ["[A3ACC] %1 is not four values", _label];
    } else {
        {
            private _channel = ["R", "G", "B"] select _forEachIndex;
            private _want = format ["A3ACC_Surf_%1_%2", _varName, _channel];
            if (_x isEqualType "") then {
                if !(_want in _x) then {
                    _problems pushBack format ["[A3ACC] %1 channel %2 does not read %3", _label, _channel, _want];
                };
            } else {
                _problems pushBack format ["[A3ACC] %1 channel %2 is not an expression", _label, _channel];
            };
        } forEach (_arr select [0, 3]);
        if !((_arr select 3) isEqualType 0) then {
            _problems pushBack format ["[A3ACC] %1 alpha is not a number", _label];
        };
    };
    _problems
};

private _igui = configFile >> "CfgInGameUI";
private _cursors = configFile >> "CfgWrapperUI" >> "Cursors";
private _eden = configFile >> "Cfg3DEN";
private _notif = configFile >> "CfgNotifications";
private _optic = configFile >> "RscInGameUI" >> "RscOptics_crows" >> "CA_IGUI_elements_group" >> "controls" >> "CA_TurretIndicator";

private _checks = [
    [_igui >> "SideColors" >> "colorFriendly", "SideColors_colorFriendly", "SideColors colorFriendly"],
    [_igui >> "SideColors" >> "colorEnemy", "SideColors_colorEnemy", "SideColors colorEnemy"],
    [_igui >> "SideColors" >> "colorNeutral", "SideColors_colorNeutral", "SideColors colorNeutral"],
    [_igui >> "SideColors" >> "colorCivilian", "SideColors_colorCivilian", "SideColors colorCivilian"],
    [_igui >> "SideColors" >> "colorUnknown", "SideColors_colorUnknown", "SideColors colorUnknown"],
    [_cursors >> "Move" >> "color", "Cursors_Move", "Cursors Move"],
    [_cursors >> "HC_move" >> "color", "Cursors_HC_move", "Cursors HC_move"],
    [_cursors >> "CuratorPlaceWaypointDestroy" >> "color", "Cursors_CuratorPlaceWaypointDestroy", "Cursors CuratorPlaceWaypointDestroy"],
    [_eden >> "Trigger" >> "Draw" >> "2D" >> "color", "Cfg3DEN_Trigger_Draw_2D", "Cfg3DEN Trigger 2D"],
    [_eden >> "Connections" >> "Group" >> "color", "Cfg3DEN_Connections_Group", "Cfg3DEN Connections Group"],
    [_notif >> "TaskFailed" >> "color", "CfgNotifications_TaskFailed_color", "CfgNotifications TaskFailed"],
    [_notif >> "TaskSucceededIcon" >> "colorIconPicture", "CfgNotifications_TaskSucceededIcon_colorIconPicture", "CfgNotifications TaskSucceededIcon picture"],
    [_optic >> "color", "RscOptics_crows_CA_TurretIndicator", "RscInGameUI optic"]
];

{
    {
        _fail = _fail + 1;
        diag_log text _x;
    } forEach (_x call _fnc_checkExpr);
} forEach _checks;

// The shipped marker catalogue still reads the engine side variables. The
// addon no longer overrides it.
private _marker = getArray (configFile >> "CfgMarkers" >> "b_unknown" >> "color");
if (count _marker != 4) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] CfgMarkers b_unknown is not four values";
} else {
    if !("Map_BLUFOR_R" in (_marker select 0)) then {
        _fail = _fail + 1;
        diag_log text "[A3ACC] CfgMarkers b_unknown does not read Map_BLUFOR_R";
    };
};
if (isNull (configFile >> "CfgMarkerColors" >> "ColorWEST")) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] the shipped CfgMarkerColors ColorWEST is missing";
};
if (isClass (configFile >> "CfgMarkerColors" >> "A3ACC_ColorWEST_Protan")) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] the deleted A3ACC_ColorWEST_Protan override is still present";
};

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

// The accessibility help screen must exist for the pause menu entry to open.
if (!isClass (configFile >> "A3ACC_RscDisplayAccessibility")) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] accessibility help display not found";
};

// The objective panel class must exist for cutRsc to find it.
if (!isClass (configFile >> "RscTitles" >> "A3ACC_ObjectiveHud")) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] objective HUD class not found";
};
if (isNil "BIS_fnc_taskCurrent") then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] BIS_fnc_taskCurrent not found";
};

(missionNamespace getVariable ["A3ACC_testResults", []]) pushBack (_fail == 0);
if (_fail == 0) then { diag_log text "[A3ACC] config tests passed"; };
