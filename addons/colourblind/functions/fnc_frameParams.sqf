#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Return the six documented colour-correction parameters one mode applies to the
 * whole rendered frame.
 * Pure function: it reads only its argument, so SQF-VM can run it.
 *
 * The six parameters are the documented colorCorrections set, in the documented
 * order: brightness, contrast, offset, the blend array, the colorize array and
 * the luminance weights. The scripting API has NO colour-matrix argument, so a
 * per-channel mixing matrix is outside this set. Element six is the luminance
 * weights at the documented default 0.299, 0.587, 0.114, 0.
 *
 * The scripting API also accepts a SEVEN-element form. Its seventh array is an
 * optional radial ellipse for Arma 3. This addon deliberately uses the
 * six-element form, because the seventh element's semantics are undocumented and
 * are probed in todo 15. No seventh element appears in the table below.
 *
 * What the six parameters can express, and what they cannot:
 * - They express a whole-frame grade with one setting for every pixel. The grade
 *   shifts brightness, contrast and offset, blends the frame toward one colour,
 *   and colorizes it with a second. For the colorize array the alpha is the
 *   saturation. An alpha of 1 replaces the frame with the grey the weights give,
 *   times the colorize colour. A full desaturation is therefore expressible. The
 *   wiki's black-and-white example reaches a desaturation with these six values.
 * - They CANNOT express a hue-selective correction. The grade treats every pixel
 *   the same, so it cannot move the OPFOR red while it leaves the BLUFOR green
 *   untouched. That work is done by the side and status rule.
 * - They CANNOT express a colour matrix, because the API has no matrix argument.
 *   A daltonization matrix is therefore out of reach.
 *
 * Mode targets:
 * 0 Off: the identity, so the frame is unchanged. Every parameter sits at its
 *   documented default.
 * 1 Protan, 2 Deutan: move the red-green axis off the confusion pair, keeping
 *   the friend on blue and the foe on amber. Expressible: brightness near 1,
 *   contrast above 1, offset 0, the blend array the warm role colour, the
 *   colorize array the cool role colour, and the weights at the Rec.601 default.
 *   Not expressible: a per-hue remap.
 * 3 Tritan: move off the blue-yellow axis, keeping the friend on red and the foe
 *   on green. Expressible with the same six. Not expressible: the same per-hue
 *   limit.
 * 4 Achromatopsia: hue-free luminance. A desaturation is expressible, because the
 *   colorize alpha reaches 1 and the weights give the luminance. The exact
 *   setting is OPEN and is settled by the client probe in todo 15, so the values
 *   below are a starting set and not a measured result.
 *
 * Arguments:
 * 0: Mode index: 0 Off, 1 Protan, 2 Deutan, 3 Tritan, 4 Achromatopsia <NUMBER>
 *
 * Return Value:
 * Six colour-correction parameter values, in the documented order <ARRAY>
 *
 * Example:
 * [1] call A3ACC_colourblind_fnc_frameParams
 *
 * Public: No
 */

params [["_mode", 0, [0]]];

// A mode outside the five clamps to its nearest end. The function then always
// returns six elements and a caller can pass the result to the effect.
_mode = _mode max 0 min 4;

private _table = [
    // Off: the identity.
    [1, 1, 0, [0, 0, 0, 0], [1, 1, 1, 1], [0.299, 0.587, 0.114, 0]],
    // Protan: red-green axis off the confusion pair, warm blend against cool colorize.
    [0.95, 1.25, 0, [1, 0.7, 0, 0.15], [0, 0.35, 0.85, 0.1], [0.299, 0.587, 0.114, 0]],
    // Deutan: the same values as Protan, as fnc_paletteForMode shares them.
    [0.95, 1.25, 0, [1, 0.7, 0, 0.15], [0, 0.35, 0.85, 0.1], [0.299, 0.587, 0.114, 0]],
    // Tritan: blue-yellow axis off the confusion pair, red blend against green colorize.
    [0.95, 1.25, 0, [0.7, 0, 0, 0.15], [0.3, 0.9, 0.3, 0.1], [0.299, 0.587, 0.114, 0]],
    // Achromatopsia: hue-free luminance. The colorize alpha of 1 gives the grey.
    [1, 0.4, 0, [0, 0, 0, 0], [1, 1, 1, 1], [0.299, 0.587, 0.114, 0]]
];

_table select _mode
