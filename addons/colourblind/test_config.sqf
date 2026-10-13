#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Assert the converted config surfaces read mission-variable expressions, and
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

// A class that belongs to a DLC addon must keep its shipped value where the
// engine skipped that addon's whole config. Asserting that proves the skip,
// which a missing override alone would not.
private _fnc_checkShipped = {
    params ["_cfg", "_label"];
    private _problems = [];
    private _arr = getArray _cfg;
    if (count _arr != 4) then {
        _problems pushBack format ["[A3ACC] %1 is not four values", _label];
    } else {
        {
            if (_x isEqualType "") then {
                _problems pushBack format ["[A3ACC] %1 still reads an expression where its DLC is absent", _label];
            };
        } forEach (_arr select [0, 3]);
    };
    _problems
};

private _igui = configFile >> "CfgInGameUI";
private _cursors = configFile >> "CfgWrapperUI" >> "Cursors";
private _eden = configFile >> "Cfg3DEN";
private _notif = configFile >> "CfgNotifications";
private _curator = configFile >> "CfgCurator";
private _optic = configFile >> "RscInGameUI" >> "RscOptics_crows" >> "CA_IGUI_elements_group" >> "controls" >> "CA_TurretIndicator";

private _checks = [
    [_igui >> "SideColors" >> "colorFriendly", "SideColors_colorFriendly", "SideColors colorFriendly"],
    [_igui >> "SideColors" >> "colorEnemy", "SideColors_colorEnemy", "SideColors colorEnemy"],
    [_igui >> "SideColors" >> "colorNeutral", "SideColors_colorNeutral", "SideColors colorNeutral"],
    [_igui >> "SideColors" >> "colorCivilian", "SideColors_colorCivilian", "SideColors colorCivilian"],
    [_igui >> "SideColors" >> "colorUnknown", "SideColors_colorUnknown", "SideColors colorUnknown"],
    [_cursors >> "HC_move" >> "color", "Cursors_HC_move", "Cursors HC_move"],
    [_cursors >> "CuratorPlaceWaypointDestroy" >> "color", "Cursors_CuratorPlaceWaypointDestroy", "Cursors CuratorPlaceWaypointDestroy"],
    [_eden >> "Trigger" >> "Draw" >> "2D" >> "color", "Cfg3DEN_Trigger_Draw_2D", "Cfg3DEN Trigger 2D"],
    [_eden >> "Connections" >> "Group" >> "color", "Cfg3DEN_Connections_Group", "Cfg3DEN Connections Group"],
    [_notif >> "TaskFailed" >> "color", "CfgNotifications_TaskFailed_color", "CfgNotifications TaskFailed"],
    [_notif >> "TaskSucceededIcon" >> "colorIconPicture", "CfgNotifications_TaskSucceededIcon_colorIconPicture", "CfgNotifications TaskSucceededIcon picture"],
    [_optic >> "color", "RscOptics_crows_CA_TurretIndicator", "RscInGameUI optic"],
    [_curator >> "DrawObject" >> "2D" >> "colorSelectionSquare", "CfgCurator_DrawObject_2D_colorSelectionSquare", "CfgCurator DrawObject 2D selection square"],
    [_curator >> "DrawObject" >> "2D" >> "colorPreviewDisabled", "CfgCurator_DrawObject_2D_colorPreviewDisabled", "CfgCurator DrawObject 2D preview disabled"],
    [_curator >> "DrawObject" >> "3D" >> "colorSelectionSquare", "CfgCurator_DrawObject_3D_colorSelectionSquare", "CfgCurator DrawObject 3D selection square"],
    [_curator >> "DrawObject" >> "3D" >> "colorPreviewDisabled", "CfgCurator_DrawObject_3D_colorPreviewDisabled", "CfgCurator DrawObject 3D preview disabled"],
    [_curator >> "DrawWaypoint" >> "3D" >> "colorNormal", "CfgCurator_DrawWaypoint_3D_colorNormal", "CfgCurator DrawWaypoint normal"],
    [_curator >> "DrawWaypoint" >> "3D" >> "colorCycleNormal", "CfgCurator_DrawWaypoint_3D_colorCycleNormal", "CfgCurator DrawWaypoint cycle normal"],
    [_curator >> "DrawPlayer" >> "2D" >> "color", "CfgCurator_DrawPlayer_2D_color", "CfgCurator DrawPlayer 2D"],
    [_curator >> "DrawPlayer" >> "3D" >> "color", "CfgCurator_DrawPlayer_3D_color", "CfgCurator DrawPlayer 3D"],
    [configFile >> "CfgMarkers" >> "Flag" >> "color", "CfgMarkers_Flag_color", "CfgMarkers Flag"],
    [configFile >> "CfgMarkers" >> "Select" >> "color", "CfgMarkers_Select_color", "CfgMarkers Select"],
    [configFile >> "CfgMarkers" >> "GroundSupport_CAS_EAST" >> "color", "CfgMarkers_GroundSupport_CAS_EAST_color", "CfgMarkers CAS east"],
    [configFile >> "CfgMarkers" >> "GroundSupport_ARTY_EAST" >> "color", "CfgMarkers_GroundSupport_ARTY_EAST_color", "CfgMarkers arty east"],
    [configFile >> "CfgMarkers" >> "Minefield" >> "color", "CfgMarkers_Minefield_color", "CfgMarkers minefield"],
    [configFile >> "CfgMarkers" >> "GroundSupport_CAS_RESISTANCE" >> "color", "CfgMarkers_GroundSupport_CAS_RESISTANCE_color", "CfgMarkers CAS resistance"],
    [configFile >> "CfgMarkers" >> "GroundSupport_ARTY_RESISTANCE" >> "color", "CfgMarkers_GroundSupport_ARTY_RESISTANCE_color", "CfgMarkers arty resistance"],
    [configFile >> "CfgGroupIcons" >> "Flag" >> "color", "CfgGroupIcons_Flag_color", "CfgGroupIcons Flag"],
    [configFile >> "CfgGroupIcons" >> "Select" >> "color", "CfgGroupIcons_Select_color", "CfgGroupIcons Select"],
    [configFile >> "CfgORBATDefault" >> "color", "CfgORBATDefault_color", "CfgORBATDefault"],
    [configFile >> "CfgInGameUI" >> "CommandBar" >> "colorRedTeam", "CfgInGameUI_CommandBar_colorRedTeam", "CfgInGameUI CommandBar"],
    [configFile >> "CfgInGameUI" >> "CommandBar" >> "UnitInfo" >> "UnitCombatMode" >> "colorBlue", "CfgInGameUI_UnitCombatMode_colorBlue", "CfgInGameUI combat mode blue"],
    [configFile >> "CfgInGameUI" >> "CommandBar" >> "UnitInfo" >> "UnitCombatMode" >> "colorGreen", "CfgInGameUI_UnitCombatMode_colorGreen", "CfgInGameUI combat mode green"],
    [configFile >> "CfgInGameUI" >> "CommandBar" >> "UnitInfo" >> "UnitCombatMode" >> "colorWhite", "CfgInGameUI_UnitCombatMode_colorWhite", "CfgInGameUI combat mode white"],
    [configFile >> "CfgInGameUI" >> "CommandBar" >> "UnitInfo" >> "UnitCombatMode" >> "colorText", "CfgInGameUI_UnitCombatMode_colorText", "CfgInGameUI combat mode text"],
    [configFile >> "CfgInGameUI" >> "DragAndDropFont" >> "colorEnabled", "CfgInGameUI_DragAndDropFont_colorEnabled", "CfgInGameUI font enabled"],
    [configFile >> "CfgInGameUI" >> "DragAndDropFont" >> "colorDisabled", "CfgInGameUI_DragAndDropFont_colorDisabled", "CfgInGameUI font disabled"],
    [configFile >> "CfgWrapperUI" >> "Cursors" >> "3DENPlaceWaypoint" >> "color", "Cursors_3DENPlaceWaypoint", "Cursors 3DEN place waypoint"],
    [configFile >> "CfgWrapperUI" >> "Cursors" >> "3DENPlaceWaypointMulti" >> "color", "Cursors_3DENPlaceWaypointMulti", "Cursors 3DEN place waypoint multi"],
    [configFile >> "CfgWrapperUI" >> "Cursors" >> "3DENPlaceWaypointAttach" >> "color", "Cursors_3DENPlaceWaypointAttach", "Cursors 3DEN place waypoint attach"],
    [configFile >> "CfgWrapperUI" >> "Cursors" >> "3DENPlaceWaypointAttachMulti" >> "color", "Cursors_3DENPlaceWaypointAttachMulti", "Cursors 3DEN place waypoint attach multi"],
    [configFile >> "RscCustomInfoSensors" >> "targets" >> "colorFriendly", "RscCustomInfoSensors_targets_colorFriendly", "sensors friendly"],
    [configFile >> "RscCustomInfoSensors" >> "targets" >> "colorEnemy", "RscCustomInfoSensors_targets_colorEnemy", "sensors enemy"],
    [configFile >> "RscCustomInfoSensors" >> "targets" >> "colorAssigned", "RscCustomInfoSensors_targets_colorAssigned", "sensors assigned"],
    [configFile >> "RscCustomInfoSensors" >> "threats" >> "colorMissile", "RscCustomInfoSensors_threats_colorMissile", "sensors missile"],
    [configFile >> "RscChatListDefault" >> "colorGroupChannel", "RscChatListDefault_colorGroupChannel", "chat group channel"],
    [configFile >> "RscChatListDefault" >> "colorGroupChannelPlayerBackground", "RscChatListDefault_colorGroupChannelPlayerBackground", "chat group channel background"],
    [configFile >> "RscDisplayMultiplayer" >> "colorPingGood", "RscDisplayMultiplayer_colorPingGood", "server browser ping good"],
    [configFile >> "RscDisplayMultiplayer" >> "colorPingBad", "RscDisplayMultiplayer_colorPingBad", "server browser ping bad"],
    [configFile >> "RscDisplayMultiplayer" >> "colorVersionBad", "RscDisplayMultiplayer_colorVersionBad", "server browser version bad"],
    [configFile >> "RscDisplayMultiplayer" >> "controls" >> "CA_ValueSessions" >> "colorPingGood", "RscDisplayMultiplayer_CA_ValueSessions_colorPingGood", "server list ping good"],
    [configFile >> "RscDisplayMultiplayer" >> "controls" >> "CA_ValueSessions" >> "colorPingBad", "RscDisplayMultiplayer_CA_ValueSessions_colorPingBad", "server list ping bad"],
    [configFile >> "RscDisplayCurator" >> "Controls" >> "Add" >> "controls" >> "SideOPFOR" >> "colorText", "RscDisplayCurator_SideOPFOR_colorText", "Zeus side OPFOR"],
    [configFile >> "RscDisplayCurator" >> "Controls" >> "Add" >> "controls" >> "SideIndependent" >> "colorText", "RscDisplayCurator_SideIndependent_colorText", "Zeus side Independent"],
    [configFile >> "RscInGameUI" >> "RscWeaponRangeArtillery" >> "CA_IGUI_elements_group" >> "controls" >> "CA_Distance" >> "colorText", "RscWeaponRangeArtillery_CA_Distance_colorText", "artillery distance"],
    [configFile >> "RscInGameUI" >> "RscWeaponRangeArtilleryAuto" >> "CA_IGUI_elements_group" >> "controls" >> "CA_Distance" >> "colorText", "RscWeaponRangeArtilleryAuto_CA_Distance_colorText", "artillery auto distance"],
    [configFile >> "RscInGameUI" >> "RscOptics_Rangefinder" >> "CA_IGUI_elements_group" >> "controls" >> "CA_Distance" >> "colorText", "RscOptics_Rangefinder_CA_Distance_colorText", "rangefinder distance"],
    [configFile >> "RscInGameUI" >> "RscOptics_LaserDesignator" >> "CA_IGUI_elements_group" >> "controls" >> "CA_Distance" >> "colorText", "RscOptics_LaserDesignator_CA_Distance_colorText", "laser designator distance"],
    [configFile >> "RscInGameUI" >> "RscOptics_LaserDesignator_02" >> "CA_IGUI_elements_group" >> "controls" >> "CA_Distance" >> "colorText", "RscOptics_LaserDesignator_02_CA_Distance_colorText", "laser designator 02 distance"],
    [configFile >> "RscInGameUI" >> "RscOptics_strider_commander" >> "CA_IGUI_elements_group" >> "controls" >> "CA_Distance" >> "colorText", "RscOptics_strider_commander_CA_Distance_colorText", "strider commander distance"],
    [configFile >> "RscInGameUI" >> "RscOpticsRangeFinderMRAWS" >> "CA_IGUI_elements_group" >> "controls" >> "CA_Distance" >> "colorText", "RscOpticsRangeFinderMRAWS_CA_Distance_colorText", "MRAWS rangefinder distance"],
    [configFile >> "RscCustomInfoAirborneMiniMap" >> "controls" >> "MiniMap" >> "Controls" >> "CA_MiniMap" >> "altitudeMapColorLow", "RscCustomInfoAirborneMiniMap_CA_MiniMap_altitudeMapColorLow", "airborne map altitude low"],
    [configFile >> "RscCustomInfoAirborneMiniMap" >> "controls" >> "MiniMap" >> "Controls" >> "CA_MiniMap" >> "altitudeMapColorMid", "RscCustomInfoAirborneMiniMap_CA_MiniMap_altitudeMapColorMid", "airborne map altitude mid"],
    [configFile >> "RscCustomInfoAirborneMiniMap" >> "controls" >> "MiniMap" >> "Controls" >> "CA_MiniMap" >> "altitudeMapColorHigh", "RscCustomInfoAirborneMiniMap_CA_MiniMap_altitudeMapColorHigh", "airborne map altitude high"],
    [configFile >> "RscDisplayMultiplayerSetup" >> "colorConfirmed", "RscDisplayMultiplayerSetup_colorConfirmed", "server setup confirmed"],
    [configFile >> "RscDisplayMultiplayerSetup" >> "controls" >> "CA_ValueRoles" >> "colorAI", "RscDisplayMultiplayerSetup_CA_ValueRoles_colorAI", "server setup role AI"],
    [configFile >> "RscHorizontalCompass" >> "Controls" >> "Compass" >> "Controls" >> "DangerZone" >> "colorText", "RscHorizontalCompass_DangerZone_colorText", "compass danger zone"],
    [configFile >> "RscHorizontalCompass" >> "Controls" >> "Compass" >> "Controls" >> "Bar1" >> "Controls" >> "HQ" >> "colorText", "RscHorizontalCompass_HQ_colorText", "compass HQ"]
];

// The variable name prefix names the addon that carries the override.
private _gates = [
    ["Cursors_CuratorPlaceWaypoint", "A3ACC_colourblind_curator"],
    ["CfgMarkers_GroundSupport", "A3ACC_colourblind_heli"],
    ["CfgMarkers_Minefield", "A3ACC_colourblind_curator"],
    ["RscDisplayCurator_", "A3ACC_colourblind_curator"],
    ["RscOpticsRangeFinderMRAWS", "A3ACC_colourblind_tank"],
    ["RscOpticsRangeFinderVorona", "A3ACC_colourblind_tank"],
    ["RscHorizontalCompass_", "A3ACC_colourblind_contact"]
];

{
    _x params ["_cfg", "_varName", "_label"];
    private _gate = _gates select { _varName find (_x select 0) == 0 };
    private _problems = if (_gate isEqualTo [] || {isClass (configFile >> "CfgPatches" >> ((_gate select 0) select 1))}) then {
        [_cfg, _varName, _label] call _fnc_checkExpr
    } else {
        [_cfg, _label] call _fnc_checkShipped
    };
    {
        _fail = _fail + 1;
        diag_log text _x;
    } forEach _problems;
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

// The vanilla structured-text base must still resolve, and the addon's own text
// controls must be well formed. The addon ships no structured-text class of its
// own: each control sets its own high-contrast pair.
if (isNull (configFile >> "RscStructuredText")) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] RscStructuredText is missing";
};
{
    _x params ["_label", "_class"];
    {
        if ((count (getArray (_class >> _x))) != 4) then {
            _fail = _fail + 1;
            diag_log text format ["[A3ACC] %1 %2 is not four values", _label, _x];
        };
    } forEach ["colorText", "colorBackground"];
} forEach [
    ["help screen", configFile >> "A3ACC_RscDisplayAccessibility" >> "controls" >> "Body"],
    ["objective panel", configFile >> "RscTitles" >> "A3ACC_ObjectiveHud" >> "controls" >> "Objective"]
];

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
