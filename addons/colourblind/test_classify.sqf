#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Assert the pure colour classifier: every family's lower and upper boundary,
 * the band split, the shipped and derived colours this addon depends on, and
 * the colours that must carry no meaning.
 *
 * The boundary cases sit about 0.01 degrees inside a hue window, and the reject
 * cases sit two or more degrees outside it. A colour exactly on an edge is not
 * representable in a colour channel, so an exact-edge case would drift across
 * the window from one run to the next. Each pair brackets the edge, so a window
 * widened or narrowed by a whole degree fails the pair.
 *
 * The friendly green and the Independent green must both return GREEN. A hue
 * test cannot separate them, so the FENCE in todo 7 decides which of the two
 * roles a given control carries. This test fails if anyone reintroduces a
 * hue-derived role.
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _fail = 0;

// [rgba, family, band, label]. An empty family means "not a semantic colour",
// and the classifier must return an empty array.
private _cases = [
    // RED: hue 0 to 25, saturation at or above 0.35, value at or above 0.20.
    [[1, 0, 0],               "RED",   "bright", "pure red"],
    [[1, 0.4166, 0],          "RED",   "bright", "RED upper edge"],
    [[1, 0.45, 0],            "",      "",       "hue 27, above RED and below AMBER"],
    [[0.8, 0.50, 0.50],       "RED",   "bright", "RED saturation above the floor"],
    [[0.8, 0.56, 0.56],       "",      "",       "saturation 0.30, below RED and above GREY"],
    [[0.22, 0.06, 0.06],      "RED",   "dark",   "RED value above the floor"],
    [[0.19, 0.05, 0.05],      "",      "",       "RED value below the floor"],
    [[0.706, 0.0745, 0.0196], "RED",   "mid",    "shipped OPFOR red"],
    [[0.7, 0.1, 0],           "RED",   "mid",    "curator player red"],
    [[1, 0.15, 0.15],         "RED",   "bright", "derived optics red"],

    // AMBER: hue 33 to 52, saturation at or above 0.55, value at or above 0.55.
    [[1, 0.5501, 0],          "AMBER", "bright", "AMBER lower edge"],
    [[1, 0.5, 0],             "",      "",       "hue 30, below AMBER and above RED"],
    [[1, 0.8666, 0],          "AMBER", "bright", "AMBER upper edge"],
    [[1, 0.91667, 0],         "",      "",       "hue 55, above AMBER and below GREEN"],
    [[1, 0.8133, 0.44],       "AMBER", "bright", "AMBER saturation above the floor"],
    [[1, 0.82, 0.46],         "",      "",       "saturation 0.54, below AMBER"],
    [[0.56, 0.3733, 0],       "AMBER", "mid",    "AMBER value above the floor"],
    [[0.54, 0.36, 0],         "",      "",       "value 0.54, below AMBER"],
    [[0.863, 0.584, 0],       "AMBER", "bright", "shipped amber"],
    [[1, 0.8, 0.2],           "AMBER", "bright", "tactical ping amber, a status colour and not a side"],

    // GREEN: hue 70 to 160, saturation at or above 0.25, value at or above 0.30.
    [[0.8332, 1, 0],          "GREEN", "bright", "GREEN lower edge"],
    [[0.91667, 1, 0],         "",      "",       "hue 65, below GREEN and above AMBER"],
    [[0, 1, 0.6666],          "GREEN", "bright", "GREEN upper edge"],
    [[0, 1, 0.75],            "",      "",       "hue 165, above GREEN"],
    [[0.74, 1, 0.74],         "GREEN", "bright", "GREEN saturation above the floor"],
    [[0.76, 1, 0.76],         "GREY",  "bright", "saturation 0.24, so GREY and not a washed GREEN"],
    [[0, 0.32, 0],            "GREEN", "dark",   "GREEN value above the floor"],
    [[0, 0.28, 0],            "",      "",       "GREEN value below the floor"],
    [[0.709, 0.972, 0.384],   "GREEN", "bright", "shipped friendly green"],
    [[0, 0.5, 0],             "GREEN", "mid",    "Independent green, the same family as the friendly green"],
    [[0, 1, 0],               "GREEN", "bright", "pure green"],

    // GREY: saturation below 0.25, value at or above 0.40. There is no CIVILIAN
    // family, because neutral and civilian share one grey.
    [[0.606, 0.606, 0.606],   "GREY",  "mid",    "shipped grey, the neutral and civilian value"],
    [[0.8, 0.736, 0.608],     "GREY",  "bright", "GREY saturation below the ceiling"],
    [[0.8, 0.7307, 0.592],    "",      "",       "saturation 0.26, above GREY and below AMBER"],
    [[0.4, 0.4, 0.4],         "GREY",  "dark",   "GREY value on the floor"],
    [[0.39, 0.39, 0.39],      "",      "",       "GREY value below the floor"],
    [[0.3, 0.3, 0.3],         "",      "",       "dark grey shading"],

    // The band split, on one family. dark is below 0.45, mid is 0.45 to 0.75,
    // bright is above 0.75.
    [[0.44, 0, 0],            "RED",   "dark",   "band dark"],
    [[0.45, 0, 0],            "RED",   "mid",    "band mid, lower edge"],
    [[0.75, 0, 0],            "RED",   "mid",    "band mid, upper edge"],
    [[0.76, 0, 0],            "RED",   "bright", "band bright"],

    // Colours that carry no meaning for this addon.
    [[0, 0, 1],               "",      "",       "pure blue"],
    [[0, 1, 1],               "",      "",       "cyan"],
    [[1, 0, 1],               "",      "",       "magenta"],
    [[0.5, 0, 1],             "",      "",       "violet"],
    [[0.5],                   "",      "",       "one channel, too few"],
    [[],                      "",      "",       "no channel"]
];

{
    _x params ["_rgba", "_family", "_band", "_label"];
    private _got = [_rgba] call FUNC(classifyColour);
    private _ok = if (_family == "") then {
        (count _got) == 0
    } else {
        (count _got) == 2 && {(_got select 0) == _family} && {(_got select 1) == _band}
    };
    if (!_ok) then {
        _fail = _fail + 1;
        diag_log text format ["[A3ACC] classify %1 = %2, want %3 %4", _label, str _got, _family, _band];
    };
} forEach _cases;

(missionNamespace getVariable ["A3ACC_testResults", []]) pushBack (_fail == 0);
if (_fail == 0) then { diag_log text "[A3ACC] classify tests passed"; };
