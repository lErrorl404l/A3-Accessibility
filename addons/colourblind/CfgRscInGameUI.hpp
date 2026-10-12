// Vehicle and weapon optic HUD colours. The shipped optic controls carry
// no colour, so this addon adds the property. Every reopened class restates
// its parent.

class RscUnitInfo;
class RscControlsGroup;
class RscPicture;
class RscText;

class RscInGameUI {
    class RscOptics_crows: RscUnitInfo {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_TurretIndicator: RscPicture { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_TurretIndicator_R',1])","(profilenamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_TurretIndicator_G',1])","(profilenamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_TurretIndicator_B',1])",1}; };
                class CA_Heading: RscText { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_Heading_R',1])","(profilenamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_Heading_G',1])","(profilenamespace getvariable ['A3ACC_Surf_RscOptics_crows_CA_Heading_B',1])",1}; };
            };
        };
    };
    class RscOptics_Boat_Armed_01_commander: RscUnitInfo {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_TurretIndicator: RscPicture { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_TurretIndicator_R',1])","(profilenamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_TurretIndicator_G',1])","(profilenamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_TurretIndicator_B',1])",1}; };
                class CA_Heading: RscText { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_Heading_R',1])","(profilenamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_Heading_G',1])","(profilenamespace getvariable ['A3ACC_Surf_RscOptics_Boat_Armed_01_commander_CA_Heading_B',1])",1}; };
            };
        };
    };
    class RscOptics_APC_Wheeled_01_gunner: RscUnitInfo {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_TurretIndicator: RscPicture { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_CA_TurretIndicator_R',1])","(profilenamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_CA_TurretIndicator_G',1])","(profilenamespace getvariable ['A3ACC_Surf_RscOptics_APC_Wheeled_01_gunner_CA_TurretIndicator_B',1])",1}; };
            };
        };
    };
    class RscOptics_MBT_01_commander: RscUnitInfo {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_TurretIndicator: RscPicture { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_TurretIndicator_R',1])","(profilenamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_TurretIndicator_G',1])","(profilenamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_TurretIndicator_B',1])",1}; };
                class CA_HorizontalCompass: RscPicture { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_HorizontalCompass_R',1])","(profilenamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_HorizontalCompass_G',1])","(profilenamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_CA_HorizontalCompass_B',1])",1}; };
            };
        };
    };
    class RscOptics_MBT_01_commander_RCWS: RscUnitInfo {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_TurretIndicator: RscPicture { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_TurretIndicator_R',1])","(profilenamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_TurretIndicator_G',1])","(profilenamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_TurretIndicator_B',1])",1}; };
                class CA_HorizontalCompass: RscPicture { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_HorizontalCompass_R',1])","(profilenamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_HorizontalCompass_G',1])","(profilenamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_commander_RCWS_CA_HorizontalCompass_B',1])",1}; };
            };
        };
    };
    class RscOptics_MBT_01_gunner: RscUnitInfo {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_TurretIndicator: RscPicture { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_TurretIndicator_R',1])","(profilenamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_TurretIndicator_G',1])","(profilenamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_TurretIndicator_B',1])",1}; };
                class CA_HorizontalCompass: RscPicture { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_HorizontalCompass_R',1])","(profilenamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_HorizontalCompass_G',1])","(profilenamespace getvariable ['A3ACC_Surf_RscOptics_MBT_01_gunner_CA_HorizontalCompass_B',1])",1}; };
            };
        };
    };
};
