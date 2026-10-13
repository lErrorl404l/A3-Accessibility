// Sensor, server browser and Zeus side and status colours.
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
//   RscDisplayCurator/SideOPFOR/colorText            dark red    OPFOR
//   RscDisplayCurator/SideIndependent/colorText      dark green  Independent
//
// controls/CA_ValueSessions states no colorVersionBad, so the addon does not
// add one. Each parent is declared at the file root as external.

class RscListBox;
class RscStandardDisplay;
class SideBLUFOR;

class RscCustomInfoSensors {
    class targets {
        colorFriendly[] = {"(profilenamespace getvariable ['A3ACC_Surf_RscCustomInfoSensors_targets_colorFriendly_R',0.0])","(profilenamespace getvariable ['A3ACC_Surf_RscCustomInfoSensors_targets_colorFriendly_G',1.0])","(profilenamespace getvariable ['A3ACC_Surf_RscCustomInfoSensors_targets_colorFriendly_B',0.0])",1.0};
        colorEnemy[] = {"(profilenamespace getvariable ['A3ACC_Surf_RscCustomInfoSensors_targets_colorEnemy_R',1.0])","(profilenamespace getvariable ['A3ACC_Surf_RscCustomInfoSensors_targets_colorEnemy_G',0.0])","(profilenamespace getvariable ['A3ACC_Surf_RscCustomInfoSensors_targets_colorEnemy_B',0.0])",1.0};
        colorAssigned[] = {"(profilenamespace getvariable ['A3ACC_Surf_RscCustomInfoSensors_targets_colorAssigned_R',1.0])","(profilenamespace getvariable ['A3ACC_Surf_RscCustomInfoSensors_targets_colorAssigned_G',0.0])","(profilenamespace getvariable ['A3ACC_Surf_RscCustomInfoSensors_targets_colorAssigned_B',0.0])",1.0};
    };
    class threats {
        colorMissile[] = {"(profilenamespace getvariable ['A3ACC_Surf_RscCustomInfoSensors_threats_colorMissile_R',1.0])","(profilenamespace getvariable ['A3ACC_Surf_RscCustomInfoSensors_threats_colorMissile_G',0.0])","(profilenamespace getvariable ['A3ACC_Surf_RscCustomInfoSensors_threats_colorMissile_B',0.0])",1.0};
    };
};

class RscDisplayMultiplayer: RscStandardDisplay {
    colorPingGood[] = {"(profilenamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_colorPingGood_R',0])","(profilenamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_colorPingGood_G',1])","(profilenamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_colorPingGood_B',0])",1};
    colorPingBad[] = {"(profilenamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_colorPingBad_R',1])","(profilenamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_colorPingBad_G',0])","(profilenamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_colorPingBad_B',0])",1};
    colorVersionBad[] = {"(profilenamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_colorVersionBad_R',1])","(profilenamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_colorVersionBad_G',0])","(profilenamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_colorVersionBad_B',0])",1};
    class controls {
        class CA_ValueSessions: RscListBox {
            colorPingGood[] = {"(profilenamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_CA_ValueSessions_colorPingGood_R',0])","(profilenamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_CA_ValueSessions_colorPingGood_G',1])","(profilenamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_CA_ValueSessions_colorPingGood_B',0])",1};
            colorPingBad[] = {"(profilenamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_CA_ValueSessions_colorPingBad_R',1])","(profilenamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_CA_ValueSessions_colorPingBad_G',0])","(profilenamespace getvariable ['A3ACC_Surf_RscDisplayMultiplayer_CA_ValueSessions_colorPingBad_B',0])",1};
        };
    };
};

class RscDisplayCurator {
    class Controls {
        class Add: RscControlsGroupNoScrollbars {
            class controls {
                class SideOPFOR: SideBLUFOR {
                    colorText[] = {"(profilenamespace getvariable ['A3ACC_Surf_RscDisplayCurator_SideOPFOR_colorText_R',0.5])","(profilenamespace getvariable ['A3ACC_Surf_RscDisplayCurator_SideOPFOR_colorText_G',0])","(profilenamespace getvariable ['A3ACC_Surf_RscDisplayCurator_SideOPFOR_colorText_B',0])",1};
                };
                class SideIndependent: SideBLUFOR {
                    colorText[] = {"(profilenamespace getvariable ['A3ACC_Surf_RscDisplayCurator_SideIndependent_colorText_R',0])","(profilenamespace getvariable ['A3ACC_Surf_RscDisplayCurator_SideIndependent_colorText_G',0.5])","(profilenamespace getvariable ['A3ACC_Surf_RscDisplayCurator_SideIndependent_colorText_B',0])",1};
                };
            };
        };
    };
};
