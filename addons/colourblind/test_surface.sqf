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

// One converted surface variable per root, with the namespace it lives in.
// MPTable reads missionNamespace. See CfgInGameUI.hpp for the open question.
private _surfaceSample = [
    ["SideColors_colorFriendly", "BLUFOR", profileNamespace],
    ["MPTable_colorWest", "BLUFOR", missionNamespace],
    ["Cursors_HC_move", "BLUFOR", profileNamespace],
    ["Cfg3DEN_Connections_Group", "OPFOR", profileNamespace],
    ["CfgNotifications_TaskFailed_color", "OPFOR", profileNamespace],
    ["RscOptics_crows_CA_TurretIndicator", "OPFOR", profileNamespace]
];

private _fnc_readRGB = {
    params ["_namespace", "_prefix"];
    [
        _namespace getVariable [_prefix + "_R", -1],
        _namespace getVariable [_prefix + "_G", -1],
        _namespace getVariable [_prefix + "_B", -1]
    ]
};

// Every mode writes the right value, in every root the sample covers.
{
    private _mode = _x;
    [_mode] call FUNC(applyVars);

    {
        _x params ["_prefix", "_key"];
        private _want = ([_mode, _key] call FUNC(surfaceColourFor)) select [0, 3];
        private _got = [profileNamespace, _prefix] call _fnc_readRGB;
        if (_got isNotEqualTo _want) then {
            _fail = _fail + 1;
            diag_log text format ["[A3ACC] mode %1 %2 = %3, want %4", _mode, _prefix, str _got, str _want];
        };
    } forEach _engineVars;

    {
        _x params ["_name", "_key", "_namespace"];
        private _want = ([_mode, _key] call FUNC(surfaceColourFor)) select [0, 3];
        private _got = [_namespace, format ["A3ACC_Surf_%1", _name]] call _fnc_readRGB;
        if (_got isNotEqualTo _want) then {
            _fail = _fail + 1;
            diag_log text format ["[A3ACC] mode %1 %2 = %3, want %4", _mode, _name, str _got, str _want];
        };
    } forEach _surfaceSample;
} forEach [1, 2, 3, 4];

// MPTable reads a mission variable. getArray returns the raw expression string,
// so this asserts the array names this addon's own variable, which proves the
// override is wired to the writer. Whether the engine evaluates it is a
// client-only question, recorded in docs/research/20-colour-coverage.md.
[1] call FUNC(applyVars);
private _mpGot = getArray (configFile >> "CfgInGameUI" >> "MPTable" >> "colorWest");
private _mpWired = ((_mpGot select 0) isEqualType "")
    && { ((_mpGot select 0) find "A3ACC_Surf_MPTable_colorWest_R") >= 0 };
if (!_mpWired) then {
    _fail = _fail + 1;
    diag_log text format ["[A3ACC] MPTable colorWest is not wired to the addon variable, got %1", str _mpGot];
};

// The record and restore round trip. A sentinel value must come back on Off.
// The store must live in the profile namespace, or the next mission start
// wipes it and Off restores this addon's own colour instead of the player's.
profileNamespace setVariable ["A3ACC_vanillaVars", nil];
profileNamespace setVariable ["Map_BLUFOR_R", 0.123];
[1] call FUNC(applyVars);
if ((profileNamespace getVariable ["Map_BLUFOR_R", -1]) isEqualTo 0.123) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] applyVars did not overwrite the sentinel value";
};
private _store = profileNamespace getVariable ["A3ACC_vanillaVars", nil];
if (isNil "_store") then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] applyVars did not record the store in the profile namespace";
} else {
    if !(_store isEqualType []) then {
        _fail = _fail + 1;
        diag_log text "[A3ACC] applyVars store is not an array, so it may not serialise";
    };
};
[0] call FUNC(applyVars);
private _restored = profileNamespace getVariable ["Map_BLUFOR_R", -1];
if (_restored != 0.123) then {
    _fail = _fail + 1;
    diag_log text format ["[A3ACC] applyVars did not restore the sentinel, got %1", str _restored];
};
if !(isNil {profileNamespace getVariable "A3ACC_vanillaVars"}) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] applyVars did not clear the vanilla store on Off";
};

// A store written in an earlier session must still restore. The store lives in
// the profile namespace, which survives a mission boundary, so an Off run must
// use it rather than leave this addon's colour in place.
profileNamespace setVariable ["A3ACC_vanillaVars", [["Map_BLUFOR_R", 0.321]]];
profileNamespace setVariable ["Map_BLUFOR_R", 0.999];
[0] call FUNC(applyVars);
private _earlier = profileNamespace getVariable ["Map_BLUFOR_R", -1];
if (_earlier != 0.321) then {
    _fail = _fail + 1;
    diag_log text format ["[A3ACC] applyVars did not restore a store from an earlier session, got %1", str _earlier];
};
profileNamespace setVariable ["A3ACC_vanillaVars", nil];

(missionNamespace getVariable ["A3ACC_testResults", []]) pushBack (_fail == 0);
if (_fail == 0) then { diag_log text "[A3ACC] surface tests passed"; };
