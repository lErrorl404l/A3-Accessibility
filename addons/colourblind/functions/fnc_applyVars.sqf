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
    ["CfgNotifications_ScoreAdded_color", "Independent"],
    ["CfgCurator_DrawObject_2D_colorSelectionSquare", "Independent"],
    ["CfgCurator_DrawObject_2D_colorPreviewDisabled", "OPFOR"],
    ["CfgCurator_DrawObject_3D_colorSelectionSquare", "Independent"],
    ["CfgCurator_DrawObject_3D_colorPreviewDisabled", "OPFOR"],
    ["CfgCurator_DrawWaypoint_3D_colorNormal", "Independent"],
    ["CfgCurator_DrawWaypoint_3D_colorCycleNormal", "Independent"],
    ["CfgCurator_DrawPlayer_2D_color", "OPFOR"],
    ["CfgCurator_DrawPlayer_3D_color", "OPFOR"],
    ["CfgMarkers_Flag_color", "OPFOR"],
    ["CfgMarkers_Select_color", "OPFOR"],
    ["CfgMarkers_GroundSupport_CAS_EAST_color", "OPFOR"],
    ["CfgMarkers_GroundSupport_ARTY_EAST_color", "OPFOR"],
    ["CfgMarkers_Minefield_color", "OPFOR"],
    ["CfgMarkers_GroundSupport_CAS_RESISTANCE_color", "Independent"],
    ["CfgMarkers_GroundSupport_ARTY_RESISTANCE_color", "Independent"],
    ["CfgGroupIcons_Flag_color", "OPFOR"],
    ["CfgGroupIcons_Select_color", "OPFOR"],
    ["CfgORBATDefault_color", "OPFOR"],
    ["RscChatListDefault_colorGroupChannel", "BLUFOR"],
    ["RscChatListDefault_colorGroupChannelPlayerBackground", "BLUFOR"],
    ["RscCustomInfoSensors_targets_colorFriendly", "BLUFOR"],
    ["RscCustomInfoSensors_targets_colorEnemy", "OPFOR"],
    ["RscCustomInfoSensors_targets_colorAssigned", "OPFOR"],
    ["RscCustomInfoSensors_threats_colorMissile", "OPFOR"],
    ["RscDisplayMultiplayer_colorPingGood", "BLUFOR"],
    ["RscDisplayMultiplayer_colorPingBad", "OPFOR"],
    ["RscDisplayMultiplayer_colorVersionBad", "OPFOR"],
    ["RscDisplayMultiplayer_CA_ValueSessions_colorPingGood", "BLUFOR"],
    ["RscDisplayMultiplayer_CA_ValueSessions_colorPingBad", "OPFOR"],
    ["RscDisplayCurator_SideOPFOR_colorText", "OPFOR"],
    ["RscDisplayCurator_SideIndependent_colorText", "Independent"],
    ["CfgInGameUI_CommandBar_colorRedTeam", "OPFOR"],
    ["CfgInGameUI_UnitCombatMode_colorBlue", "OPFOR"],
    ["CfgInGameUI_UnitCombatMode_colorGreen", "OPFOR"],
    ["CfgInGameUI_UnitCombatMode_colorWhite", "OPFOR"],
    ["CfgInGameUI_UnitCombatMode_colorText", "OPFOR"],
    ["CfgInGameUI_DragAndDropFont_colorEnabled", "BLUFOR"],
    ["CfgInGameUI_DragAndDropFont_colorDisabled", "OPFOR"],
    ["Cursors_3DENPlaceWaypoint", "Independent"],
    ["Cursors_3DENPlaceWaypointMulti", "Independent"],
    ["Cursors_3DENPlaceWaypointAttach", "Independent"],
    ["Cursors_3DENPlaceWaypointAttachMulti", "Independent"],
    ["RscOpticsRangeFinderMRAWS_CA_Distance_colorText", "OPFOR"],
    ["RscOpticsRangeFinderVorona_CA_Distance_colorText", "OPFOR"],
    ["RscOpticsRangeFinderVorona_CA_FlirMode_colorText", "OPFOR"],
    ["RscOpticsRangeFinderVorona_CA_VisionMode_colorText", "OPFOR"],
    ["RscOpticsRangeFinderVorona_CA_FOVModeNFOV_colorText", "OPFOR"],
    ["RscOpticsRangeFinderVorona_CA_FOVModeWFOV_colorText", "OPFOR"],
    ["RscOptics_APC_Wheeled_01_gunner_CA_FOVModeNFOV_colorText", "OPFOR"],
    ["RscOptics_APC_Wheeled_01_gunner_CA_FOVModeWFOV_colorText", "OPFOR"],
    ["RscOptics_APC_Wheeled_01_gunner_CA_Distance_colorText", "OPFOR"],
    ["RscOptics_APC_Wheeled_01_gunner_CA_FlirMode_colorText", "OPFOR"],
    ["RscOptics_APC_Wheeled_01_gunner_CA_Heading_colorText", "OPFOR"],
    ["RscOptics_APC_Wheeled_01_gunner_CA_OpticsPitch_colorText", "OPFOR"],
    ["RscOptics_APC_Wheeled_01_gunner_CA_VisionMode_colorText", "OPFOR"],
    ["RscOptics_APC_Wheeled_01_gunner_FireSolutionValid_colorText", "OPFOR"],
    ["RscOptics_APC_Wheeled_01_gunner_TargetSpeedText_colorText", "OPFOR"],
    ["RscOptics_Boat_Armed_01_commander_CA_Distance_colorText", "OPFOR"],
    ["RscOptics_Boat_Armed_01_commander_CA_FlirMode_colorText", "OPFOR"],
    ["RscOptics_Boat_Armed_01_commander_CA_Heading_colorText", "OPFOR"],
    ["RscOptics_Boat_Armed_01_commander_CA_VisionMode_colorText", "OPFOR"],
    ["RscOptics_Boat_Armed_01_commander_CA_VisionMode_text_colorText", "OPFOR"],
    ["RscOptics_Boat_Armed_01_commander_CA_distance_text_colorText", "OPFOR"],
    ["RscOptics_CAS_01_TGP_CA_Laser_colorText", "OPFOR"],
    ["RscOptics_Heli_Attack_01_pilot_CA_Laser_colorText", "OPFOR"],
    ["RscOptics_Heli_Attack_02_gunner_CA_Distance_colorText", "OPFOR"],
    ["RscOptics_Heli_Attack_02_gunner_CA_VisionMode_colorText", "OPFOR"],
    ["RscOptics_Heli_Attack_02_pilot_CA_Laser_colorText", "OPFOR"],
    ["RscOptics_LaserDesignator_CA_Distance_colorText", "OPFOR"],
    ["RscOptics_LaserDesignator_CA_Elev_colorText", "OPFOR"],
    ["RscOptics_LaserDesignator_CA_Heading_colorText", "OPFOR"],
    ["RscOptics_LaserDesignator_CA_Laser_colorText", "OPFOR"],
    ["RscOptics_LaserDesignator_CA_OpticsZoom_colorText", "OPFOR"],
    ["RscOptics_LaserDesignator_CA_VisionMode_colorText", "OPFOR"],
    ["RscOptics_LaserDesignator_02_CA_Distance_colorText", "OPFOR"],
    ["RscOptics_LaserDesignator_02_CA_DistanceText_colorText", "OPFOR"],
    ["RscOptics_LaserDesignator_02_CA_DistanceTextM_colorText", "OPFOR"],
    ["RscOptics_LaserDesignator_02_CA_Elev_colorText", "OPFOR"],
    ["RscOptics_LaserDesignator_02_CA_Heading_colorText", "OPFOR"],
    ["RscOptics_LaserDesignator_02_CA_HeadingText_colorText", "OPFOR"],
    ["RscOptics_LaserDesignator_02_CA_Laser_colorText", "OPFOR"],
    ["RscOptics_LaserDesignator_02_CA_OpticsZoom_colorText", "OPFOR"],
    ["RscOptics_LaserDesignator_02_CA_OpticsZoomText_colorText", "OPFOR"],
    ["RscOptics_LaserDesignator_02_CA_VisionMode_colorText", "OPFOR"],
    ["RscOptics_LaserDesignator_02_CA_VisionModeText_colorText", "OPFOR"],
    ["RscOptics_LaserDesignator_02_TextElev_colorText", "OPFOR"],
    ["RscOptics_MBT_01_commander_CA_FOVModeNFOV_colorText", "BLUFOR"],
    ["RscOptics_MBT_01_commander_CA_FOVModeWFOV_colorText", "BLUFOR"],
    ["RscOptics_MBT_01_commander_AzimuthMark_colorText", "BLUFOR"],
    ["RscOptics_MBT_01_commander_CA_FlirMode_colorText", "BLUFOR"],
    ["RscOptics_MBT_01_commander_CA_Heading_colorText", "BLUFOR"],
    ["RscOptics_MBT_01_commander_CA_LasedRange_colorText", "BLUFOR"],
    ["RscOptics_MBT_01_commander_CA_OpticsPitch_colorText", "BLUFOR"],
    ["RscOptics_MBT_01_commander_CA_VisionMode_colorText", "BLUFOR"],
    ["RscOptics_MBT_01_commander_RCWS_CA_FOVModeNFOV_colorText", "BLUFOR"],
    ["RscOptics_MBT_01_commander_RCWS_CA_FOVModeWFOV_colorText", "BLUFOR"],
    ["RscOptics_MBT_01_commander_RCWS_AzimuthMark_colorText", "BLUFOR"],
    ["RscOptics_MBT_01_commander_RCWS_CA_FlirMode_colorText", "BLUFOR"],
    ["RscOptics_MBT_01_commander_RCWS_CA_Heading_colorText", "BLUFOR"],
    ["RscOptics_MBT_01_commander_RCWS_CA_LasedRange_colorText", "BLUFOR"],
    ["RscOptics_MBT_01_commander_RCWS_CA_MaxElevERR_colorText", "OPFOR"],
    ["RscOptics_MBT_01_commander_RCWS_CA_OpticsPitch_colorText", "BLUFOR"],
    ["RscOptics_MBT_01_commander_RCWS_CA_VisionMode_colorText", "BLUFOR"],
    ["RscOptics_MBT_01_gunner_CA_FOVModeNFOV_colorText", "BLUFOR"],
    ["RscOptics_MBT_01_gunner_CA_FOVModeWFOV_colorText", "BLUFOR"],
    ["RscOptics_MBT_01_gunner_AzimuthMark_colorText", "BLUFOR"],
    ["RscOptics_MBT_01_gunner_CA_FlirMode_colorText", "BLUFOR"],
    ["RscOptics_MBT_01_gunner_CA_Heading_colorText", "BLUFOR"],
    ["RscOptics_MBT_01_gunner_CA_LasedRange_colorText", "BLUFOR"],
    ["RscOptics_MBT_01_gunner_CA_MaxElevERR_colorText", "OPFOR"],
    ["RscOptics_MBT_01_gunner_CA_MaxLeadERR_colorText", "OPFOR"],
    ["RscOptics_MBT_01_gunner_CA_OpticsPitch_colorText", "BLUFOR"],
    ["RscOptics_MBT_01_gunner_CA_VisionMode_colorText", "BLUFOR"],
    ["RscOptics_MBT_01_gunner_TargetSpeedText_colorText", "BLUFOR"],
    ["RscOptics_Rangefinder_CA_Distance_colorText", "OPFOR"],
    ["RscOptics_Rangefinder_CA_Heading_colorText", "OPFOR"],
    ["RscOptics_Rangefinder_CA_VisionMode_colorText", "OPFOR"],
    ["RscOptics_SDV_driver_ValuePitch_colorText", "OPFOR"],
    ["RscOptics_SDV_periscope_CA_Distance_colorText", "OPFOR"],
    ["RscOptics_SDV_periscope_CA_Elev_colorText", "OPFOR"],
    ["RscOptics_SDV_periscope_CA_Laser_colorText", "OPFOR"],
    ["RscOptics_SDV_periscope_CA_OpticsZoom_colorText", "OPFOR"],
    ["RscOptics_SDV_periscope_CA_VisionMode_colorText", "OPFOR"],
    ["RscOptics_UAV_gunner_CA_Laser_colorText", "OPFOR"],
    ["RscOptics_VTOL_01_copilot_CA_Laser_colorText", "OPFOR"],
    ["RscOptics_VTOL_01_gunner_CA_MaxElevERR_colorText", "OPFOR"],
    ["RscOptics_VTOL_01_gunner_CA_MaxLeadERR_colorText", "OPFOR"],
    ["RscOptics_VTOL_02_gunner_CA_Distance_colorText", "OPFOR"],
    ["RscOptics_VTOL_02_gunner_CA_Laser_colorText", "OPFOR"],
    ["RscOptics_VTOL_02_gunner_CA_VisionMode_colorText", "OPFOR"],
    ["RscOptics_cows_CA_Distance_NFOV_colorText", "OPFOR"],
    ["RscOptics_cows_CA_Distance_WFOV_colorText", "OPFOR"],
    ["RscOptics_crows_CA_Distance_colorText", "OPFOR"],
    ["RscOptics_crows_CA_FlirMode_colorText", "OPFOR"],
    ["RscOptics_crows_CA_Heading_colorText", "OPFOR"],
    ["RscOptics_crows_CA_VisionMode_colorText", "OPFOR"],
    ["RscOptics_crows_CA_VisionMode_text_colorText", "OPFOR"],
    ["RscOptics_crows_CA_distance_text_colorText", "OPFOR"],
    ["RscOptics_punisher_A3_DEG_text_colorText", "OPFOR"],
    ["RscOptics_punisher_A3_FuseRange_colorText", "OPFOR"],
    ["RscOptics_punisher_CA_Distance_colorText", "OPFOR"],
    ["RscOptics_punisher_CA_Elev_colorText", "OPFOR"],
    ["RscOptics_punisher_CA_VisionMode_colorText", "OPFOR"],
    ["RscOptics_sos_CA_Distance_colorText", "OPFOR"],
    ["RscOptics_sos_CA_FOVModeNFOV_colorText", "OPFOR"],
    ["RscOptics_sos_CA_FOVModeWFOV_colorText", "OPFOR"],
    ["RscOptics_strider_commander_CA_Distance_colorText", "OPFOR"],
    ["RscOptics_strider_commander_CA_Elev_colorText", "OPFOR"],
    ["RscOptics_strider_commander_CA_Heading_colorText", "OPFOR"],
    ["RscOptics_strider_commander_CA_Laser_colorText", "OPFOR"],
    ["RscOptics_strider_commander_CA_OpticsZoom_colorText", "OPFOR"],
    ["RscOptics_strider_commander_CA_VisionMode_colorText", "OPFOR"],
    ["RscWeaponRangeArtillery_CA_Distance_colorText", "OPFOR"],
    ["RscWeaponRangeArtillery_CA_Elev_colorText", "OPFOR"],
    ["RscWeaponRangeArtillery_CA_Elev_Need_colorText", "OPFOR"],
    ["RscWeaponRangeArtillery_CA_Heading_colorText", "OPFOR"],
    ["RscWeaponRangeArtillery_CA_OpticsPitch_colorText", "OPFOR"],
    ["RscWeaponRangeArtillery_CA_OpticsZoom_colorText", "OPFOR"],
    ["RscWeaponRangeArtillery_CA_Time_colorText", "OPFOR"],
    ["RscWeaponRangeArtillery_CA_VisionMode_colorText", "OPFOR"],
    ["RscWeaponRangeArtillery_CA_OORange_colorText", "OPFOR"],
    ["RscWeaponRangeArtilleryAuto_CA_Auto_colorText", "OPFOR"],
    ["RscWeaponRangeArtilleryAuto_CA_Distance_colorText", "OPFOR"],
    ["RscWeaponRangeArtilleryAuto_CA_Elev_colorText", "OPFOR"],
    ["RscWeaponRangeArtilleryAuto_CA_Elev_Need_colorText", "OPFOR"],
    ["RscWeaponRangeArtilleryAuto_CA_Heading_colorText", "OPFOR"],
    ["RscWeaponRangeArtilleryAuto_CA_OpticsPitch_colorText", "OPFOR"],
    ["RscWeaponRangeArtilleryAuto_CA_OpticsZoom_colorText", "OPFOR"],
    ["RscWeaponRangeArtilleryAuto_CA_Time_colorText", "OPFOR"],
    ["RscWeaponRangeArtilleryAuto_CA_VisionMode_colorText", "OPFOR"],
    ["RscWeaponRangeArtilleryAuto_CA_OORange_colorText", "OPFOR"],
    ["RscCustomInfoAirborneMiniMap_CA_MiniMap_altitudeMapColorLow", "Independent"],
    ["RscCustomInfoAirborneMiniMap_CA_MiniMap_altitudeMapColorMid", "Unknown"],
    ["RscCustomInfoAirborneMiniMap_CA_MiniMap_altitudeMapColorHigh", "OPFOR"],
    ["RscDisplayMultiplayerSetup_colorConfirmed", "BLUFOR"],
    ["RscDisplayMultiplayerSetup_CA_ValueRoles_colorAI", "OPFOR"],
    ["RscHorizontalCompass_DangerZone_colorText", "OPFOR"],
    ["RscHorizontalCompass_HQ_colorText", "OPFOR"]
];

// MPTable's colours go to the mission namespace. The engine evaluates that class
// before the profile namespace exists, and a profile expression there terminates
// the game at startup. See CfgInGameUI.hpp.
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
    // The store is an array of [name, value] pairs, because a HashMap may not
    // serialise into the profile namespace and this must survive a mission
    // boundary. See the note above the record branch.
    private _recorded = createHashMapFromArray (profileNamespace getVariable ["A3ACC_vanillaVars", []]);
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
    profileNamespace setVariable ["A3ACC_vanillaVars", nil];
} else {
    // Record the player's own values ONCE, and hold them in the profile
    // namespace so they survive a mission boundary. In the mission namespace
    // they would be wiped at the next mission start, and the values recorded
    // then would already be this addon's, so Off would restore its own colour.
    if (isNil {profileNamespace getVariable "A3ACC_vanillaVars"}) then {
        private _recorded = [];
        {
            private _prefix = _x;
            {
                private _name = _prefix + _x;
                private _value = profileNamespace getVariable [_name, nil];
                if (!isNil "_value") then {
                    _recorded pushBack [_name, _value];
                };
            } forEach _channels;
        } forEach _prefixes;
        profileNamespace setVariable ["A3ACC_vanillaVars", _recorded];
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

// Remember the mode for the next session's preStart, which cannot read the CBA
// setting. See XEH_preStart.sqf.
profileNamespace setVariable ["A3ACC_CVDModeSaved", _mode];
