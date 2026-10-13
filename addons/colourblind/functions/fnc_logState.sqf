#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Log everything a client run can report about the colour state: the phase, the
 * context, the mode from both sources, and one config sample resolved the way
 * the game's own scripts resolve it.
 *
 * A converted colour is an expression whose fallback is the shipped value. If
 * the engine reads the class before this addon has written its variable, the
 * expression returns the fallback silently, and no engine log records it. This
 * function is what makes that visible from the addon's side.
 *
 * Arguments:
 * 0: Phase label <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_phase", ""]];

diag_log text format ["[A3ACC] %1: interface=%2 dedicated=%3 multiplayer=%4 world=%5 mission=%6 side=%7",
    _phase, hasInterface, isDedicated, isMultiplayer, worldName, missionName, playerSide];

diag_log text format ["[A3ACC] %1: setting=%2 saved=%3 palette=%4",
    _phase,
    missionNamespace getVariable ["A3ACC_CVDMode", "nil"],
    profileNamespace getVariable ["A3ACC_CVDModeSaved", "nil"],
    count (missionNamespace getVariable ["A3ACC_palette", []])];

private _sample = configFile >> "CfgMarkers" >> "Flag" >> "color";
diag_log text format ["[A3ACC] %1: CfgMarkers/Flag raw=%2 resolved=%3 written=%4",
    _phase,
    str (getArray _sample),
    str (_sample call BIS_fnc_colorConfigToRGBA),
    str [
        missionNamespace getVariable ["A3ACC_Surf_CfgMarkers_Flag_color_R", -1],
        missionNamespace getVariable ["A3ACC_Surf_CfgMarkers_Flag_color_G", -1],
        missionNamespace getVariable ["A3ACC_Surf_CfgMarkers_Flag_color_B", -1]
    ]];
