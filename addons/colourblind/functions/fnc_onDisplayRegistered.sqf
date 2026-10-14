#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Recolour one display when the engine registers it.
 *
 * THE REACH BOUND. The handler fires only for a display whose config calls
 * BIS_fnc_initDisplay from its onLoad with the default register flag. That is 310
 * call sites in ui_f/config.cpp alone, not every display in every mod. A display a
 * mod creates without that call is not visited by this walk. The frame transform
 * reaches such a display as rendered pixels instead.
 *
 * The display class comes from the event, _this select 1. The control class comes
 * from ctrlClassName, which returns the LEAF name only, for example SideOPFOR and
 * not RscDisplayCurator/Controls/Add/controls/SideOPFOR. The fence keys on the
 * leaf, because the leaf is what the engine reports.
 *
 * The display is tracked by its idd, never by its handle. A handle dies when the
 * display closes, and a held list of handles would accumulate dead entries. The
 * idd comes from the config, so a game update that changes it does not break the
 * walk. Tracking happens even at mode Off, so a later mode change reaches a
 * display that opened while the mode was Off.
 *
 * Arguments:
 * 0: Display the engine registered <DISPLAY>
 * 1: Display class the engine reported <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_display", displayNull, [displayNull]], ["_class", "", [""]]];

if (!isNull _display && _class != "") then {
    private _idd = -1;
    if (isClass (configFile >> _class)) then {
        _idd = getNumber (configFile >> _class >> "idd");
    };
    if (_idd >= 0) then {
        private _displays = missionNamespace getVariable ["A3ACC_cvdDisplays", []];
        _displays pushBackUnique _idd;
        missionNamespace setVariable ["A3ACC_cvdDisplays", _displays];
    };
};

private _mode = missionNamespace getVariable ["A3ACC_CVDMode", 0];
if (_mode == 0) exitWith {};

// A re-entrant walk is refused with a flag on the display. A null display has no
// flag, so the walk still runs and returns at its own null check.
if (!isNull _display) then {
    if (_display getVariable ["A3ACC_cvdWalking", false]) exitWith {};
    _display setVariable ["A3ACC_cvdWalking", true];
};

[_display, _class, _mode] call FUNC(recolourControls);

if (!isNull _display) then {
    _display setVariable ["A3ACC_cvdWalking", false];
};
