#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // The Zeus interface config. The DLC is free but a dedicated server does
        // not install it, so the dependency is optional: the engine skips this
        // whole config where the DLC is absent, and the base addon still loads.
        requiredAddons[] = {"A3ACC_colourblind", "A3_Ui_F_Curator"};
        skipWhenMissingDependencies = 1;
        authors[] = {"lErrorl404l"};
        VERSION_CONFIG;
    };
};

#include "CfgCuratorColours.hpp"
