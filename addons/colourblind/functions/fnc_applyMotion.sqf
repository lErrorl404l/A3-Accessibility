#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Reduce or restore camera shake, for motion sensitivity.
 * Client-local: camera shake is a client effect.
 *
 * Arguments:
 * 0: Reduced <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_reduced", false, [false]]];

if (_reduced) then {
    enableCamShake false;
} else {
    enableCamShake true;
    resetCamShake;
};
