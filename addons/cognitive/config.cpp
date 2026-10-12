#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"A3ACC_main", "cba_common", "cba_events", "cba_settings"};
        authors[] = {"lErrorl404l"};
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgAccessibilityHelp.hpp"
#include "CfgObjectiveHud.hpp"
