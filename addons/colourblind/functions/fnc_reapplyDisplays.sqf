#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Re-walk every tracked display after a mode change.
 *
 * Each tracked idd is re-resolved with findDisplay, because a display handle dies
 * when the display closes. An idd that resolves to displayNull is skipped.
 *
 * Off does not skip. The same list is walked, and the walk restores each stored
 * original with the matching setter, so a mode change applies live and Off
 * restores the shipped colours.
 *
 * Arguments:
 * 0: Mode index <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_mode", 0, [0]]];
_mode = _mode max 0 min 4;

private _displays = missionNamespace getVariable ["A3ACC_cvdDisplays", []];
{
    private _display = findDisplay _x;
    if (!isNull _display) then {
        private _class = _display getVariable ["BIS_fnc_initDisplay_configClass", ""];
        if (_class != "") then {
            [_display, _class, _mode] call FUNC(recolourControls);
        };
    };
} forEach _displays;
