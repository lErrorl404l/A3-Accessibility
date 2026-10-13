#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // Every shipped root this addon reopens, plus the CBA components it
        // calls. The base-game roots are declared as well as the DLC ones.
        requiredAddons[] = {"A3ACC_main", "A3_Ui_F", "A3_3DEN", "A3_Functions_F", "A3_Ui_F_Curator", "A3_Ui_F_Tank", "A3_Missions_F_Heli", "A3_UI_F_Contact", "cba_xeh", "cba_common", "cba_events", "cba_keybinding", "cba_settings"};
        authors[] = {"lErrorl404l"};
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgInGameUI.hpp"
#include "CfgNotifications.hpp"
#include "CfgRscInGameUI.hpp"
#include "Cfg3DEN.hpp"
#include "CfgWrapperUI.hpp"
#include "CfgCurator.hpp"
#include "CfgSideIdentity.hpp"
#include "RscSideDisplays.hpp"
#include "CfgTests.hpp"
