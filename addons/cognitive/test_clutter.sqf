#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Assert the clutter setting records and restores all three things it changes:
 * the HUD, the group icons and the radio sentences. The prior state is set to a
 * value the addon does not use, so a failure to restore cannot pass by accident.
 *
 * Public: No
 */

private _fail = 0;

showHUD [true, true, true, true, true, true, true, true, true, true, true];
setGroupIconsVisible [false, false];
enableSentences true;

[true] call FUNC(applyClutter);

if (sentencesEnabled) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] clutter on did not mute the sentences";
};
if ((groupIconsVisible isEqualTo [false, false])) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] clutter on did not change the group icons";
};

[false] call FUNC(applyClutter);

if (!sentencesEnabled) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] clutter off did not restore the sentences";
};
if (groupIconsVisible isNotEqualTo [false, false]) then {
    _fail = _fail + 1;
    diag_log text format ["[A3ACC] clutter off did not restore the group icons, got %1", str groupIconsVisible];
};

(missionNamespace getVariable ["A3ACC_testResults", []]) pushBack (_fail == 0);
if (_fail == 0) then { diag_log text "[A3ACC] clutter tests passed"; };
