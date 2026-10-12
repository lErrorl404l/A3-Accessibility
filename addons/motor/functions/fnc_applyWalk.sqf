#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Force a walk, so the player does not have to hold a key to change speed.
 * Client-local. Off by default: it changes movement, which other players see.
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

if (isNull player) exitWith {};

player forceWalk _enabled;
