#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {};
        authors[] = {"UKSF Taskforce Alpha Team"};
        author = "UKSF Taskforce Alpha Team";
        VERSION_CONFIG;
    };
};

class CfgMods {
    class PREFIX {
        dir = "@A3-Accessibility";
        name = "A3 Accessibility";

        author = "UKSF Taskforce Alpha Team";

        picture = "";
        hideName = "false";
        hidePicture = "false";

        action = "";
        actionName = "";
        description = "Colour-blind accessibility modes for Arma 3.";

        dlcColor[] = {0.4, 0.6, 0.8, 1};
    };
};
