// Test instrument. DEV ONLY. The preInit proves the addon loaded, so a server
// smoke test can reach it without a renderer. The postInit starts the probe on a
// client, once a mission is running with a player.
class Extended_PreInit_EventHandlers {
    class a3acc_probe {
        init = "call compile preprocessFileLineNumbers '\z\a3acc_probe\addons\a3acc_probe\XEH_preInit.sqf'";
    };
};

class Extended_PostInit_EventHandlers {
    class a3acc_probe {
        init = "call compile preprocessFileLineNumbers '\z\a3acc_probe\addons\a3acc_probe\XEH_postInit.sqf'";
    };
};
