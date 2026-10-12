#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Toggle a boolean CBA setting, so an addon feature is reachable from a keybind
 * without opening the settings menu. XAG 112, WCAG 2.1.1.
 *
 * Arguments:
 * 0: Setting name <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_setting", "", [""]]];

private _current = missionNamespace getVariable [_setting, false];

[_setting, !_current] call CBA_settings_fnc_set;
