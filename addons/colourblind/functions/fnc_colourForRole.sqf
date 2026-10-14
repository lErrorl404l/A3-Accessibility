#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Return the RGBA colour a fence role shows in a mode.
 * Pure function: it reads only its arguments, so SQF-VM can run it.
 *
 * The mode values come from fnc_paletteForMode.
 *
 * THE MAPPER TAKES NO BRIGHTNESS BAND. One role yields one mode colour at any
 * observed brightness, so two friendly markers never render in two colours. The
 * palette's own luminance tiers carry the brightness separation. That is what the
 * README means when it says the modes separate colours by brightness as well as
 * by hue.
 *
 * The domain is the FOUR roles the fence can declare. The role `civilian` is
 * reached by the kept config paths `SideColors_colorCivilian` and
 * `MPTable_colorCiv`, and the role `objective` has no producer on any path. So
 * neither is a role here. A call with `civilian`, `objective` or any other
 * unknown role returns an empty array.
 *
 * THE ROLE TABLE BELOW IS MACHINE-READ. A gate parses it instead of restating the
 * entries by hand, so keep the format and keep it in step with the body.
 * ROLE_TABLE_BEGIN
 * ROLE enemy    CLASS enemy
 * ROLE friendly CLASS friendly
 * ROLE neutral  CLASS neutral
 * ROLE unknown  CLASS unknown
 * ROLE_TABLE_END
 *
 * Arguments:
 * 0: Mode index: 0 Off, 1 Protan, 2 Deutan, 3 Tritan, 4 Achromatopsia <NUMBER>
 * 1: Fence role: enemy, friendly, neutral or unknown <STRING>
 *
 * Return Value:
 * RGBA array in the range 0 to 1, or an empty array <ARRAY>
 *
 * Example:
 * [1, "friendly"] call A3ACC_colourblind_fnc_colourForRole
 *
 * Public: No
 */

params [["_mode", 0, [0]], ["_role", "friendly", [""]]];

private _roleToClass = createHashMapFromArray [
    ["enemy", "enemy"],
    ["friendly", "friendly"],
    ["neutral", "neutral"],
    ["unknown", "unknown"]
];

if !(_role in _roleToClass) exitWith { [] };

[_mode, _roleToClass get _role] call FUNC(paletteForMode)
