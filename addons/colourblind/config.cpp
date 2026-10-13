#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"A3ACC_main", "A3_Ui_F_Curator", "A3_Ui_F_Tank", "A3_Missions_F_Heli", "A3_UI_F_Contact", "cba_common", "cba_events", "cba_settings"};
        authors[] = {"lErrorl404l"};
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgStructuredText.hpp"
#include "CfgInGameUI.hpp"
#include "CfgNotifications.hpp"
#include "CfgRscInGameUI.hpp"
#include "Cfg3DEN.hpp"
#include "CfgWrapperUI.hpp"
#include "CfgCurator.hpp"
#include "CfgSideIdentity.hpp"
#include "RscSideDisplays.hpp"
#include "CfgTests.hpp"
