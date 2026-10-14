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
 * The scripting API also accepts a SEVEN-element form. Its seventh array is the
 * documented Arma 3 radial ellipse: major axis radius, minor axis radius,
 * rotation in degrees, centre X, centre Y, inner radius coefficient and
 * interpolation coefficient. This addon uses the six-element form, because a
 * radial ellipse leaves the frame centre ungraded and a mode must reach every
 * pixel. Todo 15's probe passes a seven-element array once and records the
 * result. No seventh element appears in the table below.
 *
 * What the six parameters can express, and what they cannot:
 * - They express a whole-frame grade with one setting for every pixel. The grade
 *   shifts brightness, contrast and offset, blends the frame toward one colour,
 *   and desaturates it toward a tinted grey.
 * - The colorize array carries the desaturation. Its alpha runs from 0, which
 *   replaces the frame with the grey the weights give, times the colorize
 *   colour, to 1, which leaves the frame unchanged. The wiki's parameter table
 *   states the reverse. Every worked example in that wiki and every shipped
 *   template state this direction: the wiki's black-and-white example uses an
 *   alpha of 0, the wiki's fade-out line calls an alpha of 1 the default values,
 *   and the shipped CfgPostProcessTemplates/BlackAndWhite uses an alpha of 0
 *   against a Default that uses an alpha of 1. A full desaturation is therefore
 *   expressible, and an alpha of 1 is not a desaturation at all.
 * - They CANNOT express a hue-selective correction. The grade treats every pixel
 *   the same, so it cannot move the OPFOR red while it leaves the BLUFOR green
 *   untouched. That work is done by the side and status rule.
 * - They CANNOT express a colour matrix, because the API has no matrix argument.
 *   A daltonization matrix is therefore out of reach.
 *
 * Mode targets, and the value each parameter carries:
 * 0 Off: the identity, so the frame is unchanged. The set is the one the wiki
 *   calls the default values.
 * 1 Protan, 2 Deutan: move the red-green axis off the confusion pair. A
 *   desaturation turns a red-green hue difference into a luminance difference,
 *   which is the difference a protan or deutan viewer keeps, and the blend
 *   pushes the frame toward the warm role colour while the colorize tint is the
 *   cool role colour. Expressible: brightness near 1, contrast above 1, offset
 *   0, the blend array the warm role colour, the colorize array the cool role
 *   colour, and the weights at the Rec.601 default. Not expressible: a per-hue
 *   remap.
 * 3 Tritan: move off the blue-yellow axis, with the same grade the other way
 *   round: the blend is the red role colour and the colorize tint is green. Not
 *   expressible: the same per-hue limit.
 * 4 Achromatopsia: hue-free luminance. The set is the shipped
 *   CfgPostProcessTemplates/BlackAndWhite set, with the addon's Rec.601 weights
 *   in place of that template's own weights, so the frame becomes grey and
 *   nothing else moves.
 *
 * The exact values are the probe's starting point. Todo 15 settles them at a
 * client. The owner's first client reading is why the desaturation moved: the
 * first draft's colorize alpha of 0.1 is, under the documented direction, a 90
 * percent desaturation, and the owner reported the effect as strong.
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
    // Off: the identity, the wiki's default-values set.
    [1, 1, 0, [0, 0, 0, 0], [1, 1, 1, 1], [0.299, 0.587, 0.114, 0]],
    // Protan: 60 percent desaturation toward a cool grey, 10 percent blend to warm.
    [0.95, 1.15, 0, [1, 0.7, 0, 0.1], [0, 0.35, 0.85, 0.4], [0.299, 0.587, 0.114, 0]],
    // Deutan: the same values as Protan, as fnc_paletteForMode shares them.
    [0.95, 1.15, 0, [1, 0.7, 0, 0.1], [0, 0.35, 0.85, 0.4], [0.299, 0.587, 0.114, 0]],
    // Tritan: 60 percent desaturation toward a green grey, 10 percent blend to red.
    [0.95, 1.15, 0, [0.7, 0, 0, 0.1], [0.3, 0.9, 0.3, 0.4], [0.299, 0.587, 0.114, 0]],
    // Achromatopsia: the shipped BlackAndWhite set, so the colorize alpha of 0
    // replaces the frame with the Rec.601 grey.
    [1, 1, 0, [0, 0, 0, 0], [1, 1, 1, 0], [0.299, 0.587, 0.114, 0]]
];

_table select _mode
