#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Cycle the colour-blind mode, so the setting is reachable from the keyboard
 * without opening the settings menu.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _mode = missionNamespace getVariable ["A3ACC_CVDMode", 0];
private _next = (_mode + 1) mod 5;

["A3ACC_CVDMode", _next] call CBA_settings_fnc_set;
