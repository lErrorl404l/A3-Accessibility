#include "script_component.hpp"

["postInit"] call FUNC(logState);

call FUNC(watch);

// Apply the saved mode frame transform at start, so the picture is correct
// before the player opens the settings menu. applyFrame is client only, so it
// returns early on a dedicated server. The CBA setting is authoritative, and
// its callback re-applies the frame when CBA publishes the setting.
[missionNamespace getVariable ["A3ACC_CVDMode", profileNamespace getVariable ["A3ACC_CVDModeSaved", 0]]] call FUNC(applyFrame);

// The engine fires OnDisplayRegistered for a display whose config calls
// BIS_fnc_initDisplay with the default register flag. A display that registered
// before this handler existed is not in the event stream, so the displays that are
// open now are walked once here.
[missionNamespace, "OnDisplayRegistered", { _this call FUNC(onDisplayRegistered) }] call BIS_fnc_addScriptedEventHandler;
{
    private _class = _x getVariable ["BIS_fnc_initDisplay_configClass", ""];
    if (_class != "") then {
        [_x, _class] call FUNC(onDisplayRegistered);
    };
} forEach allDisplays;
