// Vehicle and weapon optic HUD colours, and the artillery range text.
//
// Every colorText or color literal that is exactly the side red
// 0.706,0.0745,0.0196 carries OPFOR. Every literal that is exactly the side
// green 0.709,0.972,0.384 carries BLUFOR. Each expression default is the
// shipped value, so Off matches the shipped colour exactly. Every class states
// the parent the shipped config states, and each parent is declared at the file
// root as external. The turret, compass and heading pairs keep the variable
// names they had before this pass.

class CA_LasedObjectERR;
class RscControlsGroup;
class RscControlsGroupNoScrollbars;
class RscOpticsValue;
class RscPicture;
class RscText;
class RscUnitInfo;
class Text_Grid;

class RscInGameUI {
    class RscOptics_APC_Wheeled_01_gunner: RscUnitInfo {
        class CA_APC_NFOV_mode_group: RscControlsGroupNoScrollbars {
            class controls {
                class CA_FOVModeNFOV: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_CA_FOVModeNFOV_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_CA_FOVModeNFOV_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_CA_FOVModeNFOV_colorText_B',0.0196])",1};
                };
            };
        };
        class CA_APC_WFOV_mode_group: RscControlsGroupNoScrollbars {
            class controls {
                class CA_FOVModeWFOV: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_CA_FOVModeWFOV_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_CA_FOVModeWFOV_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_CA_FOVModeWFOV_colorText_B',0.0196])",1};
                };
            };
        };
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_Distance: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_CA_Distance_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_CA_Distance_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_CA_Distance_colorText_B',0.0196])",1};
                };
                class CA_FlirMode: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_CA_FlirMode_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_CA_FlirMode_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_CA_FlirMode_colorText_B',0.0196])",1};
                };
                class CA_Heading: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_CA_Heading_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_CA_Heading_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_CA_Heading_colorText_B',0.0196])",1};
                };
                class CA_OpticsPitch: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_CA_OpticsPitch_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_CA_OpticsPitch_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_CA_OpticsPitch_colorText_B',0.0196])",1};
                };
                class CA_TurretIndicator: RscPicture {
                    color[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_CA_TurretIndicator_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_CA_TurretIndicator_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_CA_TurretIndicator_B',0.0196])",1};
                };
                class CA_VisionMode: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_CA_VisionMode_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_CA_VisionMode_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_CA_VisionMode_colorText_B',0.0196])",1};
                };
                class FireSolutionValid: RscPicture {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_FireSolutionValid_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_FireSolutionValid_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_FireSolutionValid_colorText_B',0.0196])",1};
                };
                class TargetSpeedText: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_TargetSpeedText_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_TargetSpeedText_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_TargetSpeedText_colorText_B',0.0196])",1};
                };
            };
        };
    };
    class RscOptics_Boat_Armed_01_commander: RscUnitInfo {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_Distance: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_Distance_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_Distance_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_Distance_colorText_B',0.0196])",0.6};
                };
                class CA_FlirMode: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_FlirMode_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_FlirMode_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_FlirMode_colorText_B',0.0196])",0.6};
                };
                class CA_Heading: RscText {
                    color[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_Heading_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_Heading_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_Heading_B',0.0196])",1};
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_Heading_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_Heading_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_Heading_colorText_B',0.0196])",1};
                };
                class CA_TurretIndicator: RscPicture {
                    color[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_TurretIndicator_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_TurretIndicator_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_TurretIndicator_B',0.0196])",1};
                };
                class CA_VisionMode: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_VisionMode_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_VisionMode_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_VisionMode_colorText_B',0.0196])",0.6};
                };
                class CA_VisionMode_text: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_VisionMode_text_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_VisionMode_text_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_VisionMode_text_colorText_B',0.0196])",0.6};
                };
                class CA_distance_text: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_distance_text_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_distance_text_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_distance_text_colorText_B',0.0196])",0.6};
                };
            };
        };
    };
    class RscOptics_CAS_01_TGP: RscUnitInfo {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_Laser: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_CAS_01_TGP_CA_Laser_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_CAS_01_TGP_CA_Laser_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_CAS_01_TGP_CA_Laser_colorText_B',0.0196])",1};
                };
            };
        };
    };
    class RscOptics_Heli_Attack_01_pilot: RscUnitInfo {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_Laser: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Heli_Attack_01_pilot_CA_Laser_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Heli_Attack_01_pilot_CA_Laser_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Heli_Attack_01_pilot_CA_Laser_colorText_B',0.0196])",1};
                };
            };
        };
    };
    class RscOptics_Heli_Attack_02_gunner: RscUnitInfo {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_Distance: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Heli_Attack_02_gunner_CA_Distance_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Heli_Attack_02_gunner_CA_Distance_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Heli_Attack_02_gunner_CA_Distance_colorText_B',0.0196])",1};
                };
                class CA_VisionMode: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Heli_Attack_02_gunner_CA_VisionMode_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Heli_Attack_02_gunner_CA_VisionMode_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Heli_Attack_02_gunner_CA_VisionMode_colorText_B',0.0196])",1};
                };
            };
        };
    };
    class RscOptics_Heli_Attack_02_pilot: RscUnitInfo {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_Laser: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Heli_Attack_02_pilot_CA_Laser_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Heli_Attack_02_pilot_CA_Laser_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Heli_Attack_02_pilot_CA_Laser_colorText_B',0.0196])",1};
                };
            };
        };
    };
    class RscOptics_LaserDesignator {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_Distance: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_CA_Distance_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_CA_Distance_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_CA_Distance_colorText_B',0.0196])",1};
                };
                class CA_Elev: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_CA_Elev_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_CA_Elev_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_CA_Elev_colorText_B',0.0196])",1};
                };
                class CA_Heading: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_CA_Heading_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_CA_Heading_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_CA_Heading_colorText_B',0.0196])",1};
                };
                class CA_Laser: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_CA_Laser_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_CA_Laser_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_CA_Laser_colorText_B',0.0196])",1};
                };
                class CA_OpticsZoom: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_CA_OpticsZoom_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_CA_OpticsZoom_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_CA_OpticsZoom_colorText_B',0.0196])",1};
                };
                class CA_VisionMode: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_CA_VisionMode_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_CA_VisionMode_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_CA_VisionMode_colorText_B',0.0196])",1};
                };
            };
        };
    };
    class RscOptics_LaserDesignator_02 {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_Distance: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_Distance_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_Distance_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_Distance_colorText_B',0.0196])",1};
                };
                class CA_DistanceText: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_DistanceText_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_DistanceText_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_DistanceText_colorText_B',0.0196])",1};
                };
                class CA_DistanceTextM: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_DistanceTextM_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_DistanceTextM_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_DistanceTextM_colorText_B',0.0196])",1};
                };
                class CA_Elev: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_Elev_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_Elev_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_Elev_colorText_B',0.0196])",1};
                };
                class CA_Heading: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_Heading_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_Heading_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_Heading_colorText_B',0.0196])",1};
                };
                class CA_HeadingText: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_HeadingText_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_HeadingText_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_HeadingText_colorText_B',0.0196])",1};
                };
                class CA_Laser: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_Laser_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_Laser_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_Laser_colorText_B',0.0196])",1};
                };
                class CA_OpticsZoom: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_OpticsZoom_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_OpticsZoom_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_OpticsZoom_colorText_B',0.0196])",1};
                };
                class CA_OpticsZoomText: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_OpticsZoomText_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_OpticsZoomText_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_OpticsZoomText_colorText_B',0.0196])",1};
                };
                class CA_VisionMode: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_VisionMode_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_VisionMode_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_VisionMode_colorText_B',0.0196])",1};
                };
                class CA_VisionModeText: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_VisionModeText_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_VisionModeText_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_CA_VisionModeText_colorText_B',0.0196])",1};
                };
                class TextElev: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_TextElev_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_TextElev_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_LaserDesignator_02_TextElev_colorText_B',0.0196])",1};
                };
            };
        };
    };
    class RscOptics_MBT_01_commander: RscUnitInfo {
        class CA_APC_NFOV_mode_group: RscControlsGroupNoScrollbars {
            class controls {
                class CA_FOVModeNFOV: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_FOVModeNFOV_colorText_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_FOVModeNFOV_colorText_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_FOVModeNFOV_colorText_B',0.384])",1};
                };
            };
        };
        class CA_APC_WFOV_mode_group: RscControlsGroupNoScrollbars {
            class controls {
                class CA_FOVModeWFOV: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_FOVModeWFOV_colorText_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_FOVModeWFOV_colorText_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_FOVModeWFOV_colorText_B',0.384])",1};
                };
            };
        };
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class AzimuthMark: RscPicture {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_AzimuthMark_colorText_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_AzimuthMark_colorText_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_AzimuthMark_colorText_B',0.384])",1};
                };
                class CA_FlirMode: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_FlirMode_colorText_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_FlirMode_colorText_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_FlirMode_colorText_B',0.384])",1};
                };
                class CA_Heading: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_Heading_colorText_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_Heading_colorText_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_Heading_colorText_B',0.384])",1};
                };
                class CA_HorizontalCompass: RscPicture {
                    color[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_HorizontalCompass_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_HorizontalCompass_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_HorizontalCompass_B',0.384])",1};
                };
                class CA_LasedRange: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_LasedRange_colorText_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_LasedRange_colorText_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_LasedRange_colorText_B',0.384])",1};
                };
                class CA_OpticsPitch: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_OpticsPitch_colorText_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_OpticsPitch_colorText_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_OpticsPitch_colorText_B',0.384])",1};
                };
                class CA_TurretIndicator: RscPicture {
                    color[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_TurretIndicator_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_TurretIndicator_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_TurretIndicator_B',0.384])",1};
                };
                class CA_VisionMode: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_VisionMode_colorText_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_VisionMode_colorText_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_VisionMode_colorText_B',0.384])",1};
                };
            };
        };
    };
    class RscOptics_MBT_01_commander_RCWS: RscUnitInfo {
        class CA_APC_NFOV_mode_group: RscControlsGroupNoScrollbars {
            class controls {
                class CA_FOVModeNFOV: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_FOVModeNFOV_colorText_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_FOVModeNFOV_colorText_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_FOVModeNFOV_colorText_B',0.384])",1};
                };
            };
        };
        class CA_APC_WFOV_mode_group: RscControlsGroupNoScrollbars {
            class controls {
                class CA_FOVModeWFOV: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_FOVModeWFOV_colorText_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_FOVModeWFOV_colorText_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_FOVModeWFOV_colorText_B',0.384])",1};
                };
            };
        };
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class AzimuthMark: RscPicture {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_AzimuthMark_colorText_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_AzimuthMark_colorText_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_AzimuthMark_colorText_B',0.384])",1};
                };
                class CA_FlirMode: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_FlirMode_colorText_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_FlirMode_colorText_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_FlirMode_colorText_B',0.384])",1};
                };
                class CA_Heading: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_Heading_colorText_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_Heading_colorText_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_Heading_colorText_B',0.384])",1};
                };
                class CA_HorizontalCompass: RscPicture {
                    color[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_HorizontalCompass_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_HorizontalCompass_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_HorizontalCompass_B',0.384])",1};
                };
                class CA_LasedRange: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_LasedRange_colorText_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_LasedRange_colorText_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_LasedRange_colorText_B',0.384])",1};
                };
                class CA_OpticsPitch: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_OpticsPitch_colorText_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_OpticsPitch_colorText_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_OpticsPitch_colorText_B',0.384])",1};
                };
                class CA_TurretIndicator: RscPicture {
                    color[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_TurretIndicator_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_TurretIndicator_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_TurretIndicator_B',0.384])",1};
                };
                class CA_VisionMode: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_VisionMode_colorText_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_VisionMode_colorText_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_VisionMode_colorText_B',0.384])",1};
                };
                class CA_MaxElevERR: CA_OpticsPitch {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_MaxElevERR_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_MaxElevERR_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_MaxElevERR_colorText_B',0.0196])",1};
                };
            };
        };
    };
    class RscOptics_MBT_01_gunner: RscUnitInfo {
        class CA_APC_NFOV_mode_group: RscControlsGroupNoScrollbars {
            class controls {
                class CA_FOVModeNFOV: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_FOVModeNFOV_colorText_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_FOVModeNFOV_colorText_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_FOVModeNFOV_colorText_B',0.384])",1};
                };
            };
        };
        class CA_APC_WFOV_mode_group: RscControlsGroupNoScrollbars {
            class controls {
                class CA_FOVModeWFOV: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_FOVModeWFOV_colorText_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_FOVModeWFOV_colorText_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_FOVModeWFOV_colorText_B',0.384])",1};
                };
            };
        };
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class AzimuthMark: RscPicture {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_AzimuthMark_colorText_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_AzimuthMark_colorText_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_AzimuthMark_colorText_B',0.384])",1};
                };
                class CA_FlirMode: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_FlirMode_colorText_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_FlirMode_colorText_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_FlirMode_colorText_B',0.384])",1};
                };
                class CA_Heading: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_Heading_colorText_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_Heading_colorText_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_Heading_colorText_B',0.384])",1};
                };
                class CA_HorizontalCompass: RscPicture {
                    color[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_HorizontalCompass_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_HorizontalCompass_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_HorizontalCompass_B',0.384])",1};
                };
                class CA_LasedRange: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_LasedRange_colorText_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_LasedRange_colorText_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_LasedRange_colorText_B',0.384])",1};
                };
                class CA_MaxLeadERR: CA_LasedObjectERR {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_MaxLeadERR_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_MaxLeadERR_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_MaxLeadERR_colorText_B',0.0196])",1};
                };
                class CA_OpticsPitch: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_OpticsPitch_colorText_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_OpticsPitch_colorText_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_OpticsPitch_colorText_B',0.384])",1};
                };
                class CA_TurretIndicator: RscPicture {
                    color[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_TurretIndicator_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_TurretIndicator_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_TurretIndicator_B',0.384])",1};
                };
                class CA_VisionMode: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_VisionMode_colorText_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_VisionMode_colorText_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_VisionMode_colorText_B',0.384])",1};
                };
                class TargetSpeedText: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_TargetSpeedText_colorText_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_TargetSpeedText_colorText_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_TargetSpeedText_colorText_B',0.384])",1};
                };
                class CA_MaxElevERR: CA_OpticsPitch {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_MaxElevERR_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_MaxElevERR_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_MaxElevERR_colorText_B',0.0196])",1};
                };
            };
        };
    };
    class RscOptics_Rangefinder: RscUnitInfo {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_Distance: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Rangefinder_CA_Distance_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Rangefinder_CA_Distance_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Rangefinder_CA_Distance_colorText_B',0.0196])",1};
                };
                class CA_Heading: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Rangefinder_CA_Heading_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Rangefinder_CA_Heading_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Rangefinder_CA_Heading_colorText_B',0.0196])",1};
                };
                class CA_VisionMode: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Rangefinder_CA_VisionMode_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Rangefinder_CA_VisionMode_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_Rangefinder_CA_VisionMode_colorText_B',0.0196])",1};
                };
            };
        };
    };
    class RscOptics_SDV_driver: RscUnitInfo {
        class DriverOpticsGroup: RscControlsGroup {
            class controls {
                class ValuePitch: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_SDV_driver_ValuePitch_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_SDV_driver_ValuePitch_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_SDV_driver_ValuePitch_colorText_B',0.0196])",1};
                };
            };
        };
    };
    class RscOptics_SDV_periscope {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_Distance: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_SDV_periscope_CA_Distance_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_SDV_periscope_CA_Distance_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_SDV_periscope_CA_Distance_colorText_B',0.0196])",1};
                };
                class CA_Elev: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_SDV_periscope_CA_Elev_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_SDV_periscope_CA_Elev_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_SDV_periscope_CA_Elev_colorText_B',0.0196])",1};
                };
                class CA_Laser: RscPicture {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_SDV_periscope_CA_Laser_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_SDV_periscope_CA_Laser_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_SDV_periscope_CA_Laser_colorText_B',0.0196])",1};
                };
                class CA_OpticsZoom: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_SDV_periscope_CA_OpticsZoom_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_SDV_periscope_CA_OpticsZoom_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_SDV_periscope_CA_OpticsZoom_colorText_B',0.0196])",1};
                };
                class CA_VisionMode: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_SDV_periscope_CA_VisionMode_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_SDV_periscope_CA_VisionMode_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_SDV_periscope_CA_VisionMode_colorText_B',0.0196])",1};
                };
            };
        };
    };
    class RscOptics_UAV_gunner: RscUnitInfo {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_Laser: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_UAV_gunner_CA_Laser_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_UAV_gunner_CA_Laser_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_UAV_gunner_CA_Laser_colorText_B',0.0196])",1};
                };
            };
        };
    };
    class RscOptics_VTOL_01_copilot: RscUnitInfo {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_Laser: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_VTOL_01_copilot_CA_Laser_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_VTOL_01_copilot_CA_Laser_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_VTOL_01_copilot_CA_Laser_colorText_B',0.0196])",1};
                };
            };
        };
    };
    class RscOptics_VTOL_01_gunner: RscUnitInfo {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_MaxElevERR: Text_Grid {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_VTOL_01_gunner_CA_MaxElevERR_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_VTOL_01_gunner_CA_MaxElevERR_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_VTOL_01_gunner_CA_MaxElevERR_colorText_B',0.0196])",1};
                };
                class CA_MaxLeadERR: Text_Grid {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_VTOL_01_gunner_CA_MaxLeadERR_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_VTOL_01_gunner_CA_MaxLeadERR_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_VTOL_01_gunner_CA_MaxLeadERR_colorText_B',0.0196])",1};
                };
            };
        };
    };
    class RscOptics_VTOL_02_gunner: RscUnitInfo {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_Distance: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_VTOL_02_gunner_CA_Distance_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_VTOL_02_gunner_CA_Distance_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_VTOL_02_gunner_CA_Distance_colorText_B',0.0196])",1};
                };
                class CA_Laser: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_VTOL_02_gunner_CA_Laser_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_VTOL_02_gunner_CA_Laser_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_VTOL_02_gunner_CA_Laser_colorText_B',0.0196])",1};
                };
                class CA_VisionMode: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_VTOL_02_gunner_CA_VisionMode_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_VTOL_02_gunner_CA_VisionMode_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_VTOL_02_gunner_CA_VisionMode_colorText_B',0.0196])",1};
                };
            };
        };
    };
    class RscOptics_cows: RscUnitInfo {
        class CA_NFOV_mode_group: RscControlsGroup {
            class controls {
                class CA_Distance_NFOV: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_cows_CA_Distance_NFOV_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_cows_CA_Distance_NFOV_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_cows_CA_Distance_NFOV_colorText_B',0.0196])",1};
                };
            };
        };
        class CA_WFOV_mode_group: RscControlsGroup {
            class controls {
                class CA_Distance_WFOV: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_cows_CA_Distance_WFOV_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_cows_CA_Distance_WFOV_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_cows_CA_Distance_WFOV_colorText_B',0.0196])",1};
                };
            };
        };
    };
    class RscOptics_crows: RscUnitInfo {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_Distance: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_Distance_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_Distance_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_Distance_colorText_B',0.0196])",0.6};
                };
                class CA_FlirMode: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_FlirMode_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_FlirMode_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_FlirMode_colorText_B',0.0196])",0.6};
                };
                class CA_Heading: RscText {
                    color[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_Heading_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_Heading_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_Heading_B',0.0196])",1};
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_Heading_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_Heading_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_Heading_colorText_B',0.0196])",1};
                };
                class CA_TurretIndicator: RscPicture {
                    color[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_TurretIndicator_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_TurretIndicator_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_TurretIndicator_B',0.0196])",1};
                };
                class CA_VisionMode: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_VisionMode_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_VisionMode_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_VisionMode_colorText_B',0.0196])",0.6};
                };
                class CA_VisionMode_text: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_VisionMode_text_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_VisionMode_text_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_VisionMode_text_colorText_B',0.0196])",0.6};
                };
                class CA_distance_text: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_distance_text_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_distance_text_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_distance_text_colorText_B',0.0196])",0.6};
                };
            };
        };
    };
    class RscOptics_punisher {
        class CA_IGUI_elements_group: RscControlsGroup {
            class Controls {
                class A3_DEG_text: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_punisher_A3_DEG_text_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_punisher_A3_DEG_text_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_punisher_A3_DEG_text_colorText_B',0.0196])",1};
                };
                class A3_FuseRange: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_punisher_A3_FuseRange_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_punisher_A3_FuseRange_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_punisher_A3_FuseRange_colorText_B',0.0196])",1};
                };
                class CA_Distance: RscOpticsValue {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_punisher_CA_Distance_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_punisher_CA_Distance_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_punisher_CA_Distance_colorText_B',0.0196])",1};
                };
                class CA_Elev: RscOpticsValue {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_punisher_CA_Elev_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_punisher_CA_Elev_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_punisher_CA_Elev_colorText_B',0.0196])",1};
                };
                class CA_VisionMode: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_punisher_CA_VisionMode_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_punisher_CA_VisionMode_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_punisher_CA_VisionMode_colorText_B',0.0196])",1};
                };
            };
        };
    };
    class RscOptics_sos: RscUnitInfo {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_Distance: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_sos_CA_Distance_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_sos_CA_Distance_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_sos_CA_Distance_colorText_B',0.0196])",1};
                };
            };
        };
        class CA_Sniper_NFOV_mode_group: RscControlsGroup {
            class controls {
                class CA_FOVModeNFOV: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_sos_CA_FOVModeNFOV_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_sos_CA_FOVModeNFOV_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_sos_CA_FOVModeNFOV_colorText_B',0.0196])",1};
                };
            };
        };
        class CA_Sniper_WFOV_mode_group: RscControlsGroup {
            class controls {
                class CA_FOVModeWFOV: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_sos_CA_FOVModeWFOV_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_sos_CA_FOVModeWFOV_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_sos_CA_FOVModeWFOV_colorText_B',0.0196])",1};
                };
            };
        };
    };
    class RscOptics_strider_commander {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_Distance: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_strider_commander_CA_Distance_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_strider_commander_CA_Distance_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_strider_commander_CA_Distance_colorText_B',0.0196])",1};
                };
                class CA_Elev: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_strider_commander_CA_Elev_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_strider_commander_CA_Elev_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_strider_commander_CA_Elev_colorText_B',0.0196])",1};
                };
                class CA_Heading: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_strider_commander_CA_Heading_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_strider_commander_CA_Heading_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_strider_commander_CA_Heading_colorText_B',0.0196])",1};
                };
                class CA_Laser: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_strider_commander_CA_Laser_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_strider_commander_CA_Laser_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_strider_commander_CA_Laser_colorText_B',0.0196])",1};
                };
                class CA_OpticsZoom: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_strider_commander_CA_OpticsZoom_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_strider_commander_CA_OpticsZoom_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_strider_commander_CA_OpticsZoom_colorText_B',0.0196])",1};
                };
                class CA_VisionMode: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscOptics_strider_commander_CA_VisionMode_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_strider_commander_CA_VisionMode_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscOptics_strider_commander_CA_VisionMode_colorText_B',0.0196])",1};
                };
            };
        };
    };
    class RscWeaponRangeArtillery {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_Distance: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtillery_CA_Distance_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtillery_CA_Distance_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtillery_CA_Distance_colorText_B',0.0196])",1};
                };
                class CA_Elev: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtillery_CA_Elev_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtillery_CA_Elev_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtillery_CA_Elev_colorText_B',0.0196])",1};
                };
                class CA_Elev_Need: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtillery_CA_Elev_Need_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtillery_CA_Elev_Need_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtillery_CA_Elev_Need_colorText_B',0.0196])",1};
                };
                class CA_Heading: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtillery_CA_Heading_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtillery_CA_Heading_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtillery_CA_Heading_colorText_B',0.0196])",1};
                };
                class CA_OpticsPitch: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtillery_CA_OpticsPitch_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtillery_CA_OpticsPitch_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtillery_CA_OpticsPitch_colorText_B',0.0196])",1};
                };
                class CA_OpticsZoom: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtillery_CA_OpticsZoom_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtillery_CA_OpticsZoom_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtillery_CA_OpticsZoom_colorText_B',0.0196])",1};
                };
                class CA_Time: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtillery_CA_Time_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtillery_CA_Time_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtillery_CA_Time_colorText_B',0.0196])",1};
                };
                class CA_VisionMode: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtillery_CA_VisionMode_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtillery_CA_VisionMode_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtillery_CA_VisionMode_colorText_B',0.0196])",1};
                };
            };
        };
        class CA_RangeElements_group: RscControlsGroup {
            class controls {
                class CA_OORange: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtillery_CA_OORange_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtillery_CA_OORange_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtillery_CA_OORange_colorText_B',0.0196])",1};
                };
            };
        };
    };
    class RscWeaponRangeArtilleryAuto {
        class CA_AutoElements_group: RscControlsGroup {
            class controls {
                class CA_Auto: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_Auto_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_Auto_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_Auto_colorText_B',0.0196])",1};
                };
            };
        };
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_Distance: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_Distance_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_Distance_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_Distance_colorText_B',0.0196])",1};
                };
                class CA_Elev: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_Elev_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_Elev_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_Elev_colorText_B',0.0196])",1};
                };
                class CA_Elev_Need: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_Elev_Need_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_Elev_Need_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_Elev_Need_colorText_B',0.0196])",1};
                };
                class CA_Heading: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_Heading_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_Heading_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_Heading_colorText_B',0.0196])",1};
                };
                class CA_OpticsPitch: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_OpticsPitch_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_OpticsPitch_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_OpticsPitch_colorText_B',0.0196])",1};
                };
                class CA_OpticsZoom: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_OpticsZoom_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_OpticsZoom_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_OpticsZoom_colorText_B',0.0196])",1};
                };
                class CA_Time: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_Time_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_Time_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_Time_colorText_B',0.0196])",1};
                };
                class CA_VisionMode: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_VisionMode_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_VisionMode_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_VisionMode_colorText_B',0.0196])",1};
                };
            };
        };
        class CA_RangeElements_group: RscControlsGroup {
            class controls {
                class CA_OORange: RscText {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_OORange_colorText_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_OORange_colorText_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_RscWeaponRangeArtilleryAuto_CA_OORange_colorText_B',0.0196])",1};
                };
            };
        };
    };
};
