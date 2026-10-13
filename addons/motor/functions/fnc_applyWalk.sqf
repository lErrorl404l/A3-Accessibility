#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Force a walk on the local player, for a player who prefers to hold a walk.
 *
 * This REMOVES sprint. It does not remove the need to hold a key, and no engine
 * command can do that: `forceWalk` and `allowSprint` are the only motor
 * commands, and both are Boolean switches, so a sprint toggle is not available.
 *
 * Off by default, and the player opts in. The flag itself is client-local: it
 * never broadcasts one player's choice to another machine. The movement still
 * replicates, so other players see the walk, and a mission that depends on
 * sprint can break.
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
