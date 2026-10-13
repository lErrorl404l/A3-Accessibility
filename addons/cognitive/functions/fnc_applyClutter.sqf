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
        // All three are readable, so all three are restored. groupIconsVisible
        // returns [visibleOnMap, visibleOnHUD], and sentencesEnabled returns a
        // Boolean. Both are the getters for the setters used below.
        missionNamespace setVariable ["A3ACC_clutterPrior", [
            shownHUD,
            groupIconsVisible,
            sentencesEnabled
        ]];
    };
    showHUD [true, true, true, true, true, true, true, true, false, false, true];
    setGroupIconsVisible [true, false];
    enableSentences false;
} else {
    private _prior = missionNamespace getVariable ["A3ACC_clutterPrior", nil];
    if (!isNil "_prior") then {
        _prior params ["_hud", "_icons", "_sentences"];
        showHUD _hud;
        setGroupIconsVisible _icons;
        enableSentences _sentences;
        missionNamespace setVariable ["A3ACC_clutterPrior", nil];
    };
};
