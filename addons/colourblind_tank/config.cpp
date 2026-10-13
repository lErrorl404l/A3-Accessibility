#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // The Tank DLC optic HUD. The dependency is optional: the engine skips
        // this whole config where the DLC is absent, so the base addon still
        // loads and those two optics keep their shipped colours.
        requiredAddons[] = {"A3ACC_colourblind", "A3_Ui_F_Tank"};
        skipWhenMissingDependencies = 1;
        authors[] = {"lErrorl404l"};
        VERSION_CONFIG;
    };
};

#include "RscOpticsTank.hpp"
