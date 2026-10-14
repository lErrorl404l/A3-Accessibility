#include "script_component.hpp"

["postInit"] call FUNC(logState);

call FUNC(watch);

// Apply the saved mode frame transform at start, so the picture is correct
// before the player opens the settings menu. applyFrame is client only, so it
// returns early on a dedicated server. The CBA setting is authoritative, and
// its callback re-applies the frame when CBA publishes the setting.
[missionNamespace getVariable ["A3ACC_CVDMode", profileNamespace getVariable ["A3ACC_CVDModeSaved", 0]]] call FUNC(applyFrame);
