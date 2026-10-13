// The Tank DLC optics the addon converts: the MRAWS and Vorona range finders.
// Every distance, thermal mode and field-of-view readout carries the side red
// 0.706,0.0745,0.0196, so each maps to OPFOR. The parents are declared at the
// file root as external.

class RscControlsGroup;
class RscText;
class RscUnitInfo;

class RscInGameUI {
    class RscOpticsRangeFinderMRAWS: RscUnitInfo {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_Distance: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOpticsRangeFinderMRAWS_CA_Distance_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOpticsRangeFinderMRAWS_CA_Distance_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOpticsRangeFinderMRAWS_CA_Distance_colorText_B',0.0196])",1};
                };
            };
        };
    };
    class RscOpticsRangeFinderVorona: RscUnitInfo {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_Distance: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOpticsRangeFinderVorona_CA_Distance_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOpticsRangeFinderVorona_CA_Distance_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOpticsRangeFinderVorona_CA_Distance_colorText_B',0.0196])",1};
                };
                class CA_FlirMode: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOpticsRangeFinderVorona_CA_FlirMode_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOpticsRangeFinderVorona_CA_FlirMode_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOpticsRangeFinderVorona_CA_FlirMode_colorText_B',0.0196])",1};
                };
                class CA_VisionMode: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOpticsRangeFinderVorona_CA_VisionMode_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOpticsRangeFinderVorona_CA_VisionMode_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOpticsRangeFinderVorona_CA_VisionMode_colorText_B',0.0196])",1};
                };
            };
        };
        class CA_NFOV_mode_group: RscControlsGroup {
            class controls {
                class CA_FOVModeNFOV: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOpticsRangeFinderVorona_CA_FOVModeNFOV_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOpticsRangeFinderVorona_CA_FOVModeNFOV_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOpticsRangeFinderVorona_CA_FOVModeNFOV_colorText_B',0.0196])",1};
                };
            };
        };
        class CA_WFOV_mode_group: RscControlsGroup {
            class controls {
                class CA_FOVModeWFOV: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOpticsRangeFinderVorona_CA_FOVModeWFOV_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOpticsRangeFinderVorona_CA_FOVModeWFOV_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOpticsRangeFinderVorona_CA_FOVModeWFOV_colorText_B',0.0196])",1};
                };
            };
        };
    };
};
