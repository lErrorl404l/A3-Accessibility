// Sensor, server browser, Zeus, airborne map, setup screen and compass side and
// status colours.
//
//   RscCustomInfoSensors/targets/colorFriendly       green   BLUFOR
//   RscCustomInfoSensors/targets/colorEnemy          red     OPFOR
//   RscCustomInfoSensors/targets/colorAssigned       red     OPFOR
//   RscCustomInfoSensors/threats/colorMissile        red     OPFOR
//   RscDisplayMultiplayer/colorPingGood              green   BLUFOR
//   RscDisplayMultiplayer/colorPingBad               red     OPFOR
//   RscDisplayMultiplayer/colorVersionBad            red     OPFOR
//   RscDisplayMultiplayer/CA_ValueSessions/pingGood  green   BLUFOR
//   RscDisplayMultiplayer/CA_ValueSessions/pingBad   red     OPFOR
//   RscCustomInfoAirborneMiniMap/altitudeMapColorLow    green   Independent
//   RscCustomInfoAirborneMiniMap/altitudeMapColorMid    yellow  Unknown
//   RscCustomInfoAirborneMiniMap/altitudeMapColorHigh   red     OPFOR
//   RscDisplayMultiplayerSetup/colorConfirmed        green   BLUFOR
//   RscDisplayMultiplayerSetup/CA_ValueRoles/colorAI red     OPFOR
//
// The Contact compass is in the colourblind_contact addon, and the Zeus side
// list in colourblind_curator. The engine skips each of those whole configs when
// its DLC is absent.
// The airborne map is an altitude gradient, so its three stops map by
// luminance and not by side. Low takes Independent, Mid takes Unknown and High
// takes OPFOR. Those three are far apart in hue and in brightness.
//
// controls/CA_ValueSessions states no colorVersionBad, so the addon does not
// add one. Each parent is declared at the file root as external.

class CA_MiniMap;
class Controls;
class MiniMap;
class RscCustomInfoMiniMap;
class RscListBox;
class RscStandardDisplay;

class RscCustomInfoSensors {
    class targets {
        colorFriendly[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscCustomInfoSensors_targets_colorFriendly_R',0.0])","(missionnamespace getvariable ['A3ACC_Surf_RscCustomInfoSensors_targets_colorFriendly_G',1.0])","(missionnamespace getvariable ['A3ACC_Surf_RscCustomInfoSensors_targets_colorFriendly_B',0.0])",1.0};
        colorEnemy[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscCustomInfoSensors_targets_colorEnemy_R',1.0])","(missionnamespace getvariable ['A3ACC_Surf_RscCustomInfoSensors_targets_colorEnemy_G',0.0])","(missionnamespace getvariable ['A3ACC_Surf_RscCustomInfoSensors_targets_colorEnemy_B',0.0])",1.0};
        colorAssigned[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscCustomInfoSensors_targets_colorAssigned_R',1.0])","(missionnamespace getvariable ['A3ACC_Surf_RscCustomInfoSensors_targets_colorAssigned_G',0.0])","(missionnamespace getvariable ['A3ACC_Surf_RscCustomInfoSensors_targets_colorAssigned_B',0.0])",1.0};
    };
    class threats {
        colorMissile[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscCustomInfoSensors_threats_colorMissile_R',1.0])","(missionnamespace getvariable ['A3ACC_Surf_RscCustomInfoSensors_threats_colorMissile_G',0.0])","(missionnamespace getvariable ['A3ACC_Surf_RscCustomInfoSensors_threats_colorMissile_B',0.0])",1.0};
    };
};

class RscDisplayMultiplayer: RscStandardDisplay {
    colorPingGood[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_colorPingGood_R',0])","(missionnamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_colorPingGood_G',1])","(missionnamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_colorPingGood_B',0])",1};
    colorPingBad[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_colorPingBad_R',1])","(missionnamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_colorPingBad_G',0])","(missionnamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_colorPingBad_B',0])",1};
    colorVersionBad[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_colorVersionBad_R',1])","(missionnamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_colorVersionBad_G',0])","(missionnamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_colorVersionBad_B',0])",1};
    class controls {
        class CA_ValueSessions: RscListBox {
            colorPingGood[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_CA_ValueSessions_colorPingGood_R',0])","(missionnamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_CA_ValueSessions_colorPingGood_G',1])","(missionnamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_CA_ValueSessions_colorPingGood_B',0])",1};
            colorPingBad[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_CA_ValueSessions_colorPingBad_R',1])","(missionnamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_CA_ValueSessions_colorPingBad_G',0])","(missionnamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_CA_ValueSessions_colorPingBad_B',0])",1};
        };
    };
};

class RscCustomInfoAirborneMiniMap: RscCustomInfoMiniMap {
    class controls: controls {
        class MiniMap: MiniMap {
            class Controls: Controls {
                class CA_MiniMap: CA_MiniMap {
                    altitudeMapColorLow[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscCustomInfoAirborneMiniMap_CA_MiniMap_altitudeMapColorLow_R',0])","(missionnamespace getvariable ['A3ACC_Surf_RscCustomInfoAirborneMiniMap_CA_MiniMap_altitudeMapColorLow_G',1])","(missionnamespace getvariable ['A3ACC_Surf_RscCustomInfoAirborneMiniMap_CA_MiniMap_altitudeMapColorLow_B',0])",0.15};
                    altitudeMapColorMid[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscCustomInfoAirborneMiniMap_CA_MiniMap_altitudeMapColorMid_R',1])","(missionnamespace getvariable ['A3ACC_Surf_RscCustomInfoAirborneMiniMap_CA_MiniMap_altitudeMapColorMid_G',1])","(missionnamespace getvariable ['A3ACC_Surf_RscCustomInfoAirborneMiniMap_CA_MiniMap_altitudeMapColorMid_B',0])",0.15};
                    altitudeMapColorHigh[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscCustomInfoAirborneMiniMap_CA_MiniMap_altitudeMapColorHigh_R',1])","(missionnamespace getvariable ['A3ACC_Surf_RscCustomInfoAirborneMiniMap_CA_MiniMap_altitudeMapColorHigh_G',0])","(missionnamespace getvariable ['A3ACC_Surf_RscCustomInfoAirborneMiniMap_CA_MiniMap_altitudeMapColorHigh_B',0])",0.15};
                };
            };
        };
    };
};

class RscDisplayMultiplayerSetup: RscStandardDisplay {
    colorConfirmed[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayerSetup_colorConfirmed_R',0])","(missionnamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayerSetup_colorConfirmed_G',1])","(missionnamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayerSetup_colorConfirmed_B',0])",1};
    class controls {
        class CA_ValueRoles: RscListBox {
            colorAI[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayerSetup_CA_ValueRoles_colorAI_R',1])","(missionnamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayerSetup_CA_ValueRoles_colorAI_G',0])","(missionnamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayerSetup_CA_ValueRoles_colorAI_B',0])",1};
        };
    };
};
