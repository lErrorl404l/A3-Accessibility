#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // cba_xeh compiles the functions, cba_common holds the per-frame
        // handler, cba_keybinding binds the key, cba_settings holds the
        // setting, cba_ui adds the pause menu entry. A3_Ui_F holds RscTitles,
        // which the objective panel merges into.
        requiredAddons[] = {"A3ACC_main", "A3_Ui_F", "cba_xeh", "cba_common", "cba_keybinding", "cba_settings", "cba_ui"};
        authors[] = {"lErrorl404l"};
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgAccessibilityHelp.hpp"
#include "CfgObjectiveHud.hpp"
