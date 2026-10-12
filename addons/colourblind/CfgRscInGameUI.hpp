// Vehicle and weapon optic HUD colours. Vanilla uses the side red and the side
// green, the protan and deutan confusion pair. Same universal palette: red
// becomes amber, green becomes blue. The parents are restated so a bare reopen
// cannot clear them.

class RscUnitInfo;
class RscControlsGroup;
class RscPicture;
class RscText;

class RscInGameUI {
    class RscOptics_crows: RscUnitInfo {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_TurretIndicator: RscPicture { color[] = {1.00, 0.70, 0.00, 1}; };
                class CA_Heading: RscText { color[] = {1.00, 0.70, 0.00, 1}; };
            };
        };
    };
    class RscOptics_Boat_Armed_01_commander: RscUnitInfo {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_TurretIndicator: RscPicture { color[] = {1.00, 0.70, 0.00, 1}; };
                class CA_Heading: RscText { color[] = {1.00, 0.70, 0.00, 1}; };
            };
        };
    };
    class RscOptics_APC_Wheeled_01_gunner: RscUnitInfo {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_TurretIndicator: RscPicture { color[] = {1.00, 0.70, 0.00, 1}; };
            };
        };
    };
    class RscOptics_MBT_01_commander: RscUnitInfo {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_TurretIndicator: RscPicture { color[] = {0.00, 0.35, 0.85, 1}; };
                class CA_HorizontalCompass: RscPicture { color[] = {0.00, 0.35, 0.85, 1}; };
            };
        };
    };
    class RscOptics_MBT_01_commander_RCWS: RscUnitInfo {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_TurretIndicator: RscPicture { color[] = {0.00, 0.35, 0.85, 1}; };
                class CA_HorizontalCompass: RscPicture { color[] = {0.00, 0.35, 0.85, 1}; };
            };
        };
    };
    class RscOptics_MBT_01_gunner: RscUnitInfo {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                class CA_TurretIndicator: RscPicture { color[] = {0.00, 0.35, 0.85, 1}; };
                class CA_HorizontalCompass: RscPicture { color[] = {0.00, 0.35, 0.85, 1}; };
            };
        };
    };
};
