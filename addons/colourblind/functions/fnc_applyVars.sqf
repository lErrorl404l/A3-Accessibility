#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Write the profile variables the engine reads for one mode.
 *
 * Arguments:
 * 0: Mode index <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_mode", 0, [0]]];

_mode = _mode max 0 min 4;

private _engineVars = [
    ["Map_BLUFOR", "BLUFOR"],
    ["Map_OPFOR", "OPFOR"],
    ["Map_Independent", "Independent"],
    ["Map_Civilian", "Civilian"],
    ["Map_Unknown", "Unknown"],
    ["IGUI_ERROR_RGB", "Error"],
    ["IGUI_WARNING_RGB", "Warning"],
    ["IGUI_TACTPING_RGB", "TacticalPing"]
];

private _surfaceVars = [


    ["SideColors_colorFriendly", "BLUFOR"],
    ["SideColors_colorEnemy", "OPFOR"],
    ["SideColors_colorNeutral", "Independent"],
    ["SideColors_colorCivilian", "Civilian"],
    ["SideColors_colorUnknown", "Unknown"],
    ["Cursors_HC_move", "BLUFOR"],
    ["Cursors_HC_overFriendly", "BLUFOR"],
    ["Cursors_CuratorPlaceWaypoint", "BLUFOR"],
    ["Cursors_CuratorPlaceWaypointMulti", "BLUFOR"],
    ["Cursors_CuratorPlaceWaypointCycle", "BLUFOR"],
    ["Cursors_CuratorPlaceWaypointGetIn", "BLUFOR"],
    ["Cursors_CuratorPlaceWaypointDestroy", "OPFOR"],
    ["Cursors_CuratorPlaceWaypointDestroyMulti", "OPFOR"],
    ["RscOptics_crows_CA_TurretIndicator", "OPFOR"],
    ["RscOptics_crows_CA_Heading", "OPFOR"],
    ["RscOptics_Boat_Armed_01_commander_CA_TurretIndicator", "OPFOR"],
    ["RscOptics_Boat_Armed_01_commander_CA_Heading", "OPFOR"],
    ["RscOptics_APC_Wheeled_01_gunner_CA_TurretIndicator", "OPFOR"],
    ["RscOptics_MBT_01_commander_CA_TurretIndicator", "BLUFOR"],
    ["RscOptics_MBT_01_commander_CA_HorizontalCompass", "BLUFOR"],
    ["RscOptics_MBT_01_commander_RCWS_CA_TurretIndicator", "BLUFOR"],
    ["RscOptics_MBT_01_commander_RCWS_CA_HorizontalCompass", "BLUFOR"],
    ["RscOptics_MBT_01_gunner_CA_TurretIndicator", "BLUFOR"],
    ["RscOptics_MBT_01_gunner_CA_HorizontalCompass", "BLUFOR"],
    ["Cfg3DEN_Trigger_Draw_3D", "Independent"],
    ["Cfg3DEN_Trigger_Draw_2D", "Independent"],
    ["Cfg3DEN_Comment_Draw_3D", "BLUFOR"],
    ["Cfg3DEN_Comment_Draw_2D", "BLUFOR"],
    ["Cfg3DEN_Connections_Group", "OPFOR"],
    ["Cfg3DEN_Connections_Sync", "OPFOR"],
    ["Cfg3DEN_Connections_WaypointActivation", "OPFOR"],
    ["CfgNotifications_TaskSucceeded_color", "Independent"],
    ["CfgNotifications_TaskFailed_color", "OPFOR"],
    ["CfgNotifications_TaskCanceled_color", "Unknown"],
    ["CfgNotifications_TaskAssignedIcon_colorIconPicture", "OPFOR"],
    ["CfgNotifications_TaskSucceededIcon_color", "Independent"],
    ["CfgNotifications_TaskSucceededIcon_colorIconPicture", "Independent"],
    ["CfgNotifications_TaskFailedIcon_color", "OPFOR"],
    ["CfgNotifications_TaskFailedIcon_colorIconPicture", "OPFOR"],
    ["CfgNotifications_TaskCanceledIcon_color", "Unknown"],
    ["CfgNotifications_TaskCanceledIcon_colorIconPicture", "Unknown"],
    ["CfgNotifications_ScoreAdded_color", "Independent"]
];

private _missionVars = [
    ["MPTable_colorWest", "BLUFOR"],
    ["MPTable_colorEast", "OPFOR"],
    ["MPTable_colorCiv", "Civilian"],
    ["MPTable_colorRes", "Independent"]
];

private _channels = ["_R", "_G", "_B"];
private _prefixes = (_engineVars apply { _x select 0 }) + (_surfaceVars apply { format ["A3ACC_Surf_%1", (_x select 0)] });

private _fnc_writeRGB = {
    params ["_ns", "_prefix", "_rgba"];
    _ns setVariable [_prefix + "_R", _rgba select 0];
    _ns setVariable [_prefix + "_G", _rgba select 1];
    _ns setVariable [_prefix + "_B", _rgba select 2];
};

if (_mode == 0) then {
    private _recorded = missionNamespace getVariable ["A3ACC_vanillaVars", createHashMap];
    if (count _recorded > 0) then {
        {
            private _prefix = _x;
            {
                profileNamespace setVariable [_prefix + _x, _recorded getOrDefault [_prefix + _x, nil]];
            } forEach _channels;
        } forEach _prefixes;
    };
    {
        private _prefix = format ["A3ACC_Surf_%1", (_x select 0)];
        {
            missionNamespace setVariable [_prefix + _x, nil];
        } forEach _channels;
    } forEach _missionVars;
    missionNamespace setVariable ["A3ACC_vanillaVars", nil];
} else {
    if (isNil {missionNamespace getVariable "A3ACC_vanillaVars"}) then {
        private _recorded = createHashMap;
        {
            private _prefix = _x;
            {
                _recorded set [_prefix + _x, profileNamespace getVariable [_prefix + _x, nil]];
            } forEach _channels;
        } forEach _prefixes;
        missionNamespace setVariable ["A3ACC_vanillaVars", _recorded];
    };

    {
        _x params ["_prefix", "_key"];
        [profileNamespace, _prefix, [_mode, _key] call FUNC(surfaceColourFor)] call _fnc_writeRGB;
    } forEach _engineVars;

    {
        _x params ["_name", "_key"];
        [profileNamespace, format ["A3ACC_Surf_%1", _name], [_mode, _key] call FUNC(surfaceColourFor)] call _fnc_writeRGB;
    } forEach _surfaceVars;

    {
        _x params ["_name", "_key"];
        [missionNamespace, format ["A3ACC_Surf_%1", _name], [_mode, _key] call FUNC(surfaceColourFor)] call _fnc_writeRGB;
    } forEach _missionVars;
};
