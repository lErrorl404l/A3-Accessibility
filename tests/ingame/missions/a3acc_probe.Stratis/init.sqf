// Dump the vanilla parent chain and scope for every class the addon overrides.
// Runs with no addon loaded, so the parents are the shipped ones.
diag_log "[A3ACC-PROBE] VANILLA START";

private _paths = [
    "CfgMarkers/b_unknown", "CfgMarkers/o_unknown", "CfgMarkers/n_unknown",
    "CfgGroupIcons/b_unknown", "CfgGroupIcons/o_unknown", "CfgGroupIcons/n_unknown",
    "CfgLocationTypes/b_unknown", "CfgLocationTypes/o_unknown", "CfgLocationTypes/n_unknown",
    "CfgNotifications/TaskSucceeded", "CfgNotifications/TaskFailed", "CfgNotifications/TaskCanceled",
    "CfgNotifications/TaskAssignedIcon", "CfgNotifications/TaskSucceededIcon",
    "CfgNotifications/TaskFailedIcon", "CfgNotifications/TaskCanceledIcon", "CfgNotifications/ScoreAdded",
    "CfgWrapperUI/Cursors/Move", "CfgWrapperUI/Cursors/Move3D", "CfgWrapperUI/Cursors/HC_move",
    "CfgWrapperUI/Cursors/HC_overFriendly", "CfgWrapperUI/Cursors/Track", "CfgWrapperUI/Cursors/Track3D",
    "CfgWrapperUI/Cursors/CuratorPlaceWaypoint", "CfgWrapperUI/Cursors/CuratorPlaceWaypointMulti",
    "CfgWrapperUI/Cursors/CuratorPlaceWaypointCycle", "CfgWrapperUI/Cursors/CuratorPlaceWaypointGetIn",
    "CfgWrapperUI/Cursors/CuratorPlaceWaypointDestroy", "CfgWrapperUI/Cursors/CuratorPlaceWaypointDestroyMulti",
    "CfgInGameUI/SideColors", "CfgInGameUI/MPTable", "CfgInGameUI/SquadRadar", "CfgInGameUI/IslandMap",
    "Cfg3DEN/Trigger/Draw/3D", "Cfg3DEN/Trigger/Draw/2D", "Cfg3DEN/Comment/Draw/3D", "Cfg3DEN/Comment/Draw/2D",
    "Cfg3DEN/Connections/Group", "Cfg3DEN/Connections/Sync", "Cfg3DEN/Connections/WaypointActivation",
    "RscInGameUI/RscOptics_crows", "RscInGameUI/RscOptics_crows/CA_IGUI_elements_group",
    "RscInGameUI/RscOptics_crows/CA_IGUI_elements_group/controls/CA_TurretIndicator",
    "RscInGameUI/RscOptics_crows/CA_IGUI_elements_group/controls/CA_Heading",
    "RscInGameUI/RscOptics_MBT_01_commander/CA_IGUI_elements_group/controls/CA_HorizontalCompass",
    "RscInGameUI/RscOptics_Boat_Armed_01_commander/CA_IGUI_elements_group",
    "RscInGameUI/RscOptics_APC_Wheeled_01_gunner/CA_IGUI_elements_group",
    "RscInGameUI/RscOptics_MBT_01_gunner/CA_IGUI_elements_group"
];

{
    private _cfg = configFile;
    { _cfg = _cfg >> _x; } forEach (_x splitString "/");
    diag_log format ["[A3ACC-PROBE] %1 | null=%2 | inherits=%3 | scope=%4",
        _x, isNull _cfg, inheritsFrom _cfg, getNumber (_cfg >> "scope")];
} forEach _paths;

// What the key classes actually carry, so we know what an override drops.
{
    private _cfg = configFile;
    { _cfg = _cfg >> _x; } forEach (_x splitString "/");
    private _props = configProperties [_cfg, "true", false];
    diag_log format ["[A3ACC-PROBE] PROPS %1 (%2 entries)", _x, count _props];
    {
        private _e = _x;
        private _v = if (isNumber _e) then { str getNumber _e }
            else { if (isText _e) then { getText _e }
            else { if (isArray _e) then { str getArray _e } else { "(class)" } } };
        diag_log format ["[A3ACC-PROBE]   %1 = %2", configName _e, _v];
    } forEach _props;
} forEach ["CfgMarkers/b_unknown", "CfgNotifications/TaskSucceeded", "CfgWrapperUI/Cursors/CuratorPlaceWaypoint"];

diag_log "[A3ACC-PROBE] VANILLA DONE";
