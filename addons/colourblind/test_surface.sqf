#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Assert the variable writer: it records the player's values once, writes the
 * mode colour into the engine and surface variables, and restores on Off.
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _fail = 0;

private _engineVars = [
    ["Map_BLUFOR", "BLUFOR"],
    ["Map_OPFOR", "OPFOR"],
    ["Map_Independent", "Independent"],
    ["Map_Civilian", "Civilian"],
    ["Map_Unknown", "Unknown"],
    ["IGUI_ERROR_RGB", "Error"],
    ["IGUI_WARNING_RGB", "Warning"],
    ["IGUI_TACTPING_RGB", "TacticalPing"]
];

// The writer records the player's originals on the first non-zero apply.
[2] call FUNC(applyVars);
if (isNil {missionNamespace getVariable "A3ACC_vanillaVars"}) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] applyVars did not record the vanilla values";
};

{
    _x params ["_prefix", "_key"];
    private _want = ([2, _key] call FUNC(surfaceColourFor)) select [0, 3];
    private _got = [
        profileNamespace getVariable [_prefix + "_R", -1],
        profileNamespace getVariable [_prefix + "_G", -1],
        profileNamespace getVariable [_prefix + "_B", -1]
    ];
    if (_got isNotEqualTo _want) then {
        _fail = _fail + 1;
        diag_log text format ["[A3ACC] applyVars %1 = %2, want %3", _prefix, str _got, str _want];
    };
} forEach _engineVars;

// A converted surface variable follows the mode.
private _surfWant = ([2, "BLUFOR"] call FUNC(surfaceColourFor)) select [0, 3];
private _surfGot = [
    profileNamespace getVariable ["A3ACC_Surf_SideColors_colorFriendly_R", -1],
    profileNamespace getVariable ["A3ACC_Surf_SideColors_colorFriendly_G", -1],
    profileNamespace getVariable ["A3ACC_Surf_SideColors_colorFriendly_B", -1]
];
if (_surfGot isNotEqualTo _surfWant) then {
    _fail = _fail + 1;
    diag_log text format ["[A3ACC] applyVars surface = %1, want %2", str _surfGot, str _surfWant];
};

// Off restores and clears the store.
[0] call FUNC(applyVars);
if !(isNil {missionNamespace getVariable "A3ACC_vanillaVars"}) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] applyVars did not clear the vanilla store on Off";
};

(missionNamespace getVariable ["A3ACC_testResults", []]) pushBack (_fail == 0);
if (_fail == 0) then { diag_log text "[A3ACC] surface tests passed"; };
