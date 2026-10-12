#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Reduce HUD clutter: hide the kill feed and the panel groups, hide the group
 * icons on the HUD, and mute the radio chatter sentences.
 * Client-local.
 *
 * Arguments:
 * 0: Reduced <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_enabled", false, [false]]];

if (_enabled) then {
    if (isNil {missionNamespace getVariable "A3ACC_clutterPrior"}) then {
        missionNamespace setVariable ["A3ACC_clutterPrior", shownHUD];
    };
    showHUD [true, true, true, true, true, true, true, true, false, false, true];
    setGroupIconsVisible [true, false];
    enableSentences false;
} else {
    private _hud = missionNamespace getVariable ["A3ACC_clutterPrior", nil];
    if (!isNil "_hud") then {
        showHUD _hud;
        missionNamespace setVariable ["A3ACC_clutterPrior", nil];
    };
    setGroupIconsVisible [true, true];
    enableSentences true;
};
