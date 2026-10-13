#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // cba_xeh compiles the functions, cba_events fires the created-marker
        // event, cba_keybinding binds the key, cba_settings holds the setting.
        requiredAddons[] = {"A3ACC_main", "cba_xeh", "cba_events", "cba_keybinding", "cba_settings"};
        authors[] = {"lErrorl404l"};
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
