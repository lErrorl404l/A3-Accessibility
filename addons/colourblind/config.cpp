#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // The shipped roots this addon reopens, plus the CBA components it
        // calls. No DLC is listed: the addon loads and works with no paid DLC,
        // and each DLC's own overrides live in a separate addon whose whole
        // config the engine skips when that DLC is absent.
        requiredAddons[] = {"A3ACC_main", "A3_Ui_F", "A3_3DEN", "A3_Functions_F", "cba_xeh", "cba_common", "cba_events", "cba_keybinding", "cba_settings"};
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
