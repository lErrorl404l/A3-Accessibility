#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // main compiles its functions with CBA_fnc_compileFunction and writes a
        // setting with CBA_settings_fnc_set.
        requiredAddons[] = {"cba_xeh", "cba_settings"};
        authors[] = {"lErrorl404l"};
        author = "lErrorl404l";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"

class CfgMods {
    class PREFIX {
        dir = "@A3-Accessibility";
        name = "A3 Accessibility";

        author = "lErrorl404l";

        picture = "\z\a3acc\addons\main\data\logo_a3acc_ca.paa";
        hideName = "false";
        hidePicture = "false";

        action = "";
        actionName = "";
        description = "Accessibility modes for Arma 3, for colour, hearing, motion, cognitive, low vision and motor needs.";

        dlcColor[] = {0.4, 0.6, 0.8, 1};
    };
};
