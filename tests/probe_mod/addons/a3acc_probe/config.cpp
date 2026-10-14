// Test instrument. DEV ONLY. This addon is never shipped and is loaded only by
// tests/run_client_probe.sh. It depends on the addon it measures, so it loads
// after it, and on CBA for the settings and the extended event handlers.
class CfgPatches {
    class a3acc_probe {
        name = "A3ACC Client Probe (test instrument)";
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.14;
        requiredAddons[] = {"A3ACC_main", "cba_xeh", "cba_common", "cba_settings", "cba_events"};
        authors[] = {"lErrorl404l"};
    };
};

#include "CfgEventHandlers.hpp"
