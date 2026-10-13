#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // The Contact DLC's interface config. The engine skips this whole config
        // when the DLC is absent, so the addon loads and works without it and the
        // compass keeps its shipped colours. Without the skip the config would
        // declare an empty RscHorizontalCompass, which the RPT reports as
        // "declared, but definition was not found".
        requiredAddons[] = {"A3ACC_colourblind", "A3_UI_F_Contact"};
        skipWhenMissingDependencies = 1;
        authors[] = {"lErrorl404l"};
        VERSION_CONFIG;
    };
};

#include "RscHorizontalCompass.hpp"
