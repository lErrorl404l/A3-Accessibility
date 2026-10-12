#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Force subtitles on for a player who wants them, and restore the prior state.
 * Client-local: it changes only the local player's own display.
 *
 * Arguments:
 * 0: Enabled <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_enabled", false, [false]]];

private _prior = missionNamespace getVariable ["A3ACC_captionPrior", nil];

if (_enabled) then {
    if (isNil "_prior") then {
        missionNamespace setVariable ["A3ACC_captionPrior", shownSubtitles];
    };
    showSubtitles true;
} else {
    if (!isNil "_prior") then {
        showSubtitles _prior;
        missionNamespace setVariable ["A3ACC_captionPrior", nil];
    };
};
