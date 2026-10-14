#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Cycle every registered CBA setting through every value it admits, and assert
 * the intended effect of every value.
 *
 * The subject is one: the setting chain of this mod, from the registered name to
 * the intended effect. CBA_settings_fnc_set is the path the addon's own keybind
 * already uses, and the only path that exercises the registration, the setting
 * store and the callback in that order.
 *
 * This test is cross-addon, and it lives in main, which owns no setting, so it
 * cannot be accused of asserting its own component. main is always loaded, and
 * the registry already lists two out-of-addon test files by path, so the pattern
 * needs no new mechanism. The runner enumerates the registry class, so no runner
 * edit is needed.
 *
 * A dedicated server has no renderer and no player. Four settings have no effect
 * this tier can observe. This test records that as a finding and routes each one
 * to the client record in docs/QA-accessibility.md, because an assertion that
 * cannot fail is worse than no assertion.
 *
 * The frame transform is client-only: fnc_applyFrame returns without an
 * interface. This test calls it nowhere and asserts no frame handle, so it passes
 * on a server with no renderer.
 *
 * Return Value:
 * None
 *
 * Public: No
 */

// ============================================================================
// MACHINE-READ SETTINGS CYCLE TABLE.
//
// tests/verify_settings.py reads the block between the two delimiter lines and
// asserts it is a bijection with the CBA_fnc_addSetting registrations in
// addons/*/initSettings.inc.sqf, in both directions. A setting with no row fails
// the gate, and a row naming an unregistered setting fails it too.
//
// One row per setting. Fields, in order: name | type | admitted values | default
// | observable getter or unobservable reason. A row declares either an
// observable getter or a reason it is unobservable, never neither.
// ============================================================================
// A3ACC_SETTINGS_CYCLE_TABLE_BEGIN
// A3ACC_ReduceClutter|CHECKBOX|false,true|false|observable=shownHUD
// A3ACC_ObjectiveHud|CHECKBOX|false,true|false|unobservable=fnc_objectiveHud exits on isNull player
// A3ACC_CVDMode|LIST|0,1,2,3,4|0|observable=A3ACC_palette
// A3ACC_ForceCaptions|CHECKBOX|false,true|false|observable=shownSubtitles
// A3ACC_SoundCues|CHECKBOX|false,true|false|unobservable=fnc_soundCue exits on isNull player
// A3ACC_MapLegibility|CHECKBOX|false,true|false|observable=markerSize
// A3ACC_ReduceMotion|CHECKBOX|false,true|false|unobservable=no cam-shake getter exists
// A3ACC_ForceWalk|CHECKBOX|false,true|false|unobservable=fnc_applyWalk exits on isNull player
// A3ACC_SETTINGS_CYCLE_TABLE_END
// ============================================================================

private _fail = 0;

// Return 1 and log one line when an assertion does not hold, else 0. The caller
// adds the count to _fail. The word "failed" in the line is deliberate: it makes
// tests/ingame/verify.py fail the whole run on any single missed assertion.
private _fnc_failed = {
    params ["_ok", "_message"];
    if (_ok) exitWith { 0 };
    diag_log text format ["[A3ACC] settings cycle failed: %1", _message];
    1
};

// The functions this cross-addon test calls live in the colourblind addon, so
// resolve them by name rather than through this addon's FUNC macro.
private _fncNames = [
    "A3ACC_colourblind_fnc_paletteForMode",
    "A3ACC_colourblind_fnc_surfaceColourFor",
    "A3ACC_colourblind_fnc_applyVars",
    "A3ACC_colourblind_fnc_cycleMode"
];
{
    if (isNil {missionNamespace getVariable [_x, nil]}) then {
        _fail = _fail + 1;
        diag_log text format ["[A3ACC] settings cycle failed: function not found: %1", _x];
    };
} forEach _fncNames;
private _paletteForMode = missionNamespace getVariable ["A3ACC_colourblind_fnc_paletteForMode", {}];
private _surfaceColourFor = missionNamespace getVariable ["A3ACC_colourblind_fnc_surfaceColourFor", {}];
private _applyVars = missionNamespace getVariable ["A3ACC_colourblind_fnc_applyVars", {}];
private _cycleMode = missionNamespace getVariable ["A3ACC_colourblind_fnc_cycleMode", {}];
private _classes = ["friendly", "enemy", "neutral", "unknown", "civilian", "objective"];

// The registered default for the mode must be Off, so a fresh player starts on
// the shipped colours.
private _defaults = missionNamespace getVariable ["CBA_settings_default", nil];
if (isNil "_defaults") then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] settings cycle failed: CBA_settings_default is missing";
} else {
    private _entry = _defaults getVariable ["A3ACC_CVDMode", []];
    _fail = _fail + ([
        (_entry isEqualType []) && {(_entry param [0, -1]) == 0},
        format ["the registered default for A3ACC_CVDMode is %1, want 0", str (_entry param [0, nil])]
    ] call _fnc_failed);
};

// The eight profile engine variables the writer owns. Seed them with a known
// value before the cycle, because the writer records only the values it finds,
// and a nil value leaves nothing to restore. The pristine values are held so the
// end of the test can put them back.
private _engineVars = ["Map_BLUFOR", "Map_OPFOR", "Map_Independent", "Map_Civilian", "Map_Unknown", "IGUI_ERROR_RGB", "IGUI_WARNING_RGB", "IGUI_TACTPING_RGB"];
private _enginePristine = [];
{
    private _prefix = _x;
    _enginePristine pushBack [
        profileNamespace getVariable [_prefix + "_R", nil],
        profileNamespace getVariable [_prefix + "_G", nil],
        profileNamespace getVariable [_prefix + "_B", nil]
    ];
    profileNamespace setVariable [_prefix + "_R", 0.5];
    profileNamespace setVariable [_prefix + "_G", 0.5];
    profileNamespace setVariable [_prefix + "_B", 0.5];
} forEach _engineVars;

// A marker whose engine colour name is known, so the mode recolour and the Off
// restore are both observable on this tier.
private _marker = "a3acc_settings_marker";
createMarker [_marker, [0, 0, 0]];
_marker setMarkerColorLocal "ColorWEST";

// Assert the intended effect of one mode value: the mode variable, the palette
// contents, the saved mode and the marker path. Return the failure count. The
// per-variable writer equality belongs to test_surface.sqf and is not repeated.
private _fnc_assertMode = {
    params ["_mode"];
    private _f = 0;

    _f = _f + ([
        (missionNamespace getVariable ["A3ACC_CVDMode", -1]) == _mode,
        format ["mode variable is %1, want %2", str (missionNamespace getVariable ["A3ACC_CVDMode", nil]), str _mode]
    ] call _fnc_failed);

    private _palette = missionNamespace getVariable ["A3ACC_palette", []];
    if (_mode == 0) then {
        _f = _f + ([
            _palette isEqualTo [],
            format ["palette holds %1 entries at Off, want 0", count _palette]
        ] call _fnc_failed);
    } else {
        _f = _f + ([
            (count _palette) == 6,
            format ["palette holds %1 entries at mode %2, want 6", count _palette, _mode]
        ] call _fnc_failed);
        if ((count _palette) == 6) then {
            {
                private _want = [_mode, _x] call _paletteForMode;
                _f = _f + ([
                    (_palette select _forEachIndex) isEqualTo _want,
                    format ["mode %1 palette %2 is %3, want %4", _mode, _x, str (_palette select _forEachIndex), str _want]
                ] call _fnc_failed);
            } forEach _classes;
        };
    };

    _f = _f + ([
        (profileNamespace getVariable ["A3ACC_CVDModeSaved", -1]) == _mode,
        format ["saved mode is %1, want %2", str (profileNamespace getVariable ["A3ACC_CVDModeSaved", nil]), str _mode]
    ] call _fnc_failed);

    private _current = getMarkerColor _marker;
    if (_mode == 0) then {
        _f = _f + ([
            _current == "ColorWEST",
            format ["marker colour is %1 at Off, want ColorWEST", _current]
        ] call _fnc_failed);
    } else {
        private _rgba = [_mode, "BLUFOR"] call _surfaceColourFor;
        private _want = format ["#(%1,%2,%3,1)", _rgba select 0, _rgba select 1, _rgba select 2];
        _f = _f + ([
            _current == _want,
            format ["marker colour is %1 at mode %2, want %3", _current, _mode, _want]
        ] call _fnc_failed);
    };

    _f
};

// True once the palette holds the mode's six colours. It is the mode row's
// second completion signal, so a broken saved-mode effect fails the assertion
// instead of waiting out the deadline on every step.
private _fnc_paletteApplied = {
    params ["_mode"];
    private _palette = missionNamespace getVariable ["A3ACC_palette", []];
    if (_mode == 0) exitWith { _palette isEqualTo [] };
    if ((count _palette) != 6) exitWith { false };
    private _applied = true;
    {
        if ((_palette select _forEachIndex) isNotEqualTo ([_mode, _x] call _paletteForMode)) then {
            _applied = false;
        };
    } forEach _classes;
    _applied
};

// The cycle begins at the shipped default.
_fail = _fail + ([
    (missionNamespace getVariable ["A3ACC_CVDMode", -1]) == 0,
    format ["the mode is %1 before the cycle, want the default 0", str (missionNamespace getVariable ["A3ACC_CVDMode", nil])]
] call _fnc_failed);

// --- A3ACC_CVDMode: both directions of the wrap ------------------------------
// UP with the wrap, driven by the keybind path, because cycleMode steps +1 and
// wraps 4 back to 0. DOWN, driven by CBA_settings_fnc_set directly, because
// cycleMode cannot step down. The wrap is the boundary a hidden bug breaks.
{
    call _cycleMode;
    private _deadline = diag_tickTime + 5;
    waitUntil { (profileNamespace getVariable ["A3ACC_CVDModeSaved", -1]) == _x || {[_x] call _fnc_paletteApplied} || {diag_tickTime > _deadline} };
    _fail = _fail + ([_x] call _fnc_assertMode);
} forEach [1, 2, 3, 4, 0];

{
    ["A3ACC_CVDMode", _x] call CBA_settings_fnc_set;
    private _deadline = diag_tickTime + 5;
    waitUntil { (profileNamespace getVariable ["A3ACC_CVDModeSaved", -1]) == _x || {[_x] call _fnc_paletteApplied} || {diag_tickTime > _deadline} };
    _fail = _fail + ([_x] call _fnc_assertMode);
} forEach [4, 3, 2, 1, 0];

// The Off restore, at the mode level: every surface variable is gone and the
// eight engine variables are back to the recorded value. The mode-level effect,
// not the per-variable writer equality, which test_surface.sqf already asserts.
private _surf = (allVariables missionNamespace) select { (_x find "A3ACC_Surf_") == 0 };
_fail = _fail + ([
    _surf isEqualTo [],
    format ["%1 A3ACC_Surf_* variables remain at Off, first %2", count _surf, str (_surf param [0, nil])]
] call _fnc_failed);
{
    private _prefix = _x;
    private _got = [
        profileNamespace getVariable [_prefix + "_R", nil],
        profileNamespace getVariable [_prefix + "_G", nil],
        profileNamespace getVariable [_prefix + "_B", nil]
    ];
    _fail = _fail + ([
        _got isEqualTo [0.5, 0.5, 0.5],
        format ["engine variable %1 is %2 at Off, want the recorded [0.5,0.5,0.5]", _prefix, str _got]
    ] call _fnc_failed);
} forEach _engineVars;
diag_log text "[A3ACC] settings cycle A3ACC_CVDMode: ok";

// --- persistence -------------------------------------------------------------
// The next start reads profileNamespace A3ACC_CVDModeSaved, because the CBA
// setting is nil at preStart. Assert the round trip: the saved mode drives the
// writer, and the writer reproduces that mode's colours. The sample variable is
// one the runtime path keeps; the two RscDisplayCurator side rows retire later.
["A3ACC_CVDMode", 4] call CBA_settings_fnc_set;
private _deadline = diag_tickTime + 5;
waitUntil { (profileNamespace getVariable ["A3ACC_CVDModeSaved", -1]) == 4 || {diag_tickTime > _deadline} };
_fail = _fail + ([
    (profileNamespace getVariable ["A3ACC_CVDModeSaved", -1]) == 4,
    format ["saved mode is %1 after mode 4, want 4", str (profileNamespace getVariable ["A3ACC_CVDModeSaved", nil])]
] call _fnc_failed);

// The call the next start makes.
[profileNamespace getVariable ["A3ACC_CVDModeSaved", 0]] call _applyVars;
private _wantSurface = ([4, "BLUFOR"] call _surfaceColourFor) select [0, 3];
private _gotSurface = [
    missionNamespace getVariable ["A3ACC_Surf_SideColors_colorFriendly_R", -1],
    missionNamespace getVariable ["A3ACC_Surf_SideColors_colorFriendly_G", -1],
    missionNamespace getVariable ["A3ACC_Surf_SideColors_colorFriendly_B", -1]
];
_fail = _fail + ([
    _gotSurface isEqualTo _wantSurface,
    format ["the saved mode wrote surface %1, want mode 4's %2", str _gotSurface, str _wantSurface]
] call _fnc_failed);
private _gotEngine = [
    profileNamespace getVariable ["Map_BLUFOR_R", -1],
    profileNamespace getVariable ["Map_BLUFOR_G", -1],
    profileNamespace getVariable ["Map_BLUFOR_B", -1]
];
_fail = _fail + ([
    _gotEngine isEqualTo _wantSurface,
    format ["the saved mode wrote engine %1, want mode 4's %2", str _gotEngine, str _wantSurface]
] call _fnc_failed);

["A3ACC_CVDMode", 0] call CBA_settings_fnc_set;
_deadline = diag_tickTime + 5;
waitUntil { (profileNamespace getVariable ["A3ACC_CVDModeSaved", -1]) == 0 || {diag_tickTime > _deadline} };
_fail = _fail + ([
    (profileNamespace getVariable ["A3ACC_CVDModeSaved", -1]) == 0,
    format ["saved mode is %1 after Off, want 0", str (profileNamespace getVariable ["A3ACC_CVDModeSaved", nil])]
] call _fnc_failed);
diag_log text "[A3ACC] settings cycle A3ACC_CVDMode persistence: ok";

// --- A3ACC_ReduceClutter -----------------------------------------------------
private _clutterPriorHud = shownHUD;
private _clutterPriorIcons = groupIconsVisible;
private _clutterPriorSentences = sentencesEnabled;

["A3ACC_ReduceClutter", false] call CBA_settings_fnc_set;
_deadline = diag_tickTime + 5;
waitUntil { (missionNamespace getVariable ["A3ACC_ReduceClutter", nil]) isEqualTo false || {diag_tickTime > _deadline} };
_fail = _fail + ([
    (isNil {missionNamespace getVariable "A3ACC_clutterPrior"})
    && {shownHUD isEqualTo _clutterPriorHud}
    && {groupIconsVisible isEqualTo _clutterPriorIcons}
    && {sentencesEnabled == _clutterPriorSentences},
    format ["ReduceClutter false left HUD=%1 icons=%2 sentences=%3 prior=%4", str shownHUD, str groupIconsVisible, str sentencesEnabled, str (missionNamespace getVariable ["A3ACC_clutterPrior", nil])]
] call _fnc_failed);

["A3ACC_ReduceClutter", true] call CBA_settings_fnc_set;
_deadline = diag_tickTime + 5;
waitUntil { !(isNil {missionNamespace getVariable "A3ACC_clutterPrior"}) || {diag_tickTime > _deadline} };
private _reducedHud = shownHUD;
_fail = _fail + ([
    !(_reducedHud select 8)
    && {!(_reducedHud select 9)}
    && {groupIconsVisible isEqualTo [true, false]}
    && {sentencesEnabled == false}
    && {!(isNil {missionNamespace getVariable "A3ACC_clutterPrior"})},
    format ["ReduceClutter true gave HUD8=%1 HUD9=%2 icons=%3 sentences=%4", str (_reducedHud select 8), str (_reducedHud select 9), str groupIconsVisible, str sentencesEnabled]
] call _fnc_failed);

["A3ACC_ReduceClutter", false] call CBA_settings_fnc_set;
_deadline = diag_tickTime + 5;
waitUntil { (isNil {missionNamespace getVariable "A3ACC_clutterPrior"}) || {diag_tickTime > _deadline} };
_fail = _fail + ([
    (isNil {missionNamespace getVariable "A3ACC_clutterPrior"})
    && {shownHUD isEqualTo _clutterPriorHud}
    && {groupIconsVisible isEqualTo _clutterPriorIcons}
    && {sentencesEnabled == _clutterPriorSentences},
    format ["ReduceClutter false did not restore HUD=%1 icons=%2 sentences=%3 prior=%4", str shownHUD, str groupIconsVisible, str sentencesEnabled, str (missionNamespace getVariable ["A3ACC_clutterPrior", nil])]
] call _fnc_failed);
diag_log text "[A3ACC] settings cycle A3ACC_ReduceClutter: ok";

// --- A3ACC_ForceCaptions -----------------------------------------------------
private _captionsPrior = shownSubtitles;

["A3ACC_ForceCaptions", false] call CBA_settings_fnc_set;
_deadline = diag_tickTime + 5;
waitUntil { (missionNamespace getVariable ["A3ACC_ForceCaptions", nil]) isEqualTo false || {diag_tickTime > _deadline} };
_fail = _fail + ([
    (shownSubtitles == _captionsPrior) && {isNil {missionNamespace getVariable "A3ACC_captionPrior"}},
    format ["ForceCaptions false left subtitles=%1 prior=%2", str shownSubtitles, str (missionNamespace getVariable ["A3ACC_captionPrior", nil])]
] call _fnc_failed);

["A3ACC_ForceCaptions", true] call CBA_settings_fnc_set;
_deadline = diag_tickTime + 5;
waitUntil { !(isNil {missionNamespace getVariable "A3ACC_captionPrior"}) || {diag_tickTime > _deadline} };
_fail = _fail + ([
    shownSubtitles && {!(isNil {missionNamespace getVariable "A3ACC_captionPrior"})},
    format ["ForceCaptions true gave subtitles=%1 prior=%2", str shownSubtitles, str (missionNamespace getVariable ["A3ACC_captionPrior", nil])]
] call _fnc_failed);

["A3ACC_ForceCaptions", false] call CBA_settings_fnc_set;
_deadline = diag_tickTime + 5;
waitUntil { (isNil {missionNamespace getVariable "A3ACC_captionPrior"}) || {diag_tickTime > _deadline} };
_fail = _fail + ([
    (shownSubtitles == _captionsPrior) && {isNil {missionNamespace getVariable "A3ACC_captionPrior"}},
    format ["ForceCaptions false did not restore subtitles=%1 want %2 prior=%3", str shownSubtitles, str _captionsPrior, str (missionNamespace getVariable ["A3ACC_captionPrior", nil])]
] call _fnc_failed);
diag_log text "[A3ACC] settings cycle A3ACC_ForceCaptions: ok";

// --- A3ACC_MapLegibility -----------------------------------------------------
private _legMarker = "a3acc_settings_leg_marker";
createMarker [_legMarker, [0, 0, 0]];
_legMarker setMarkerSizeLocal [1, 1];
_legMarker setMarkerAlphaLocal 0.5;

["A3ACC_MapLegibility", false] call CBA_settings_fnc_set;
_deadline = diag_tickTime + 5;
waitUntil { (missionNamespace getVariable ["A3ACC_MapLegibility", nil]) isEqualTo false || {diag_tickTime > _deadline} };
private _legCache = missionNamespace getVariable ["A3ACC_markerLegibilityPrior", createHashMap];
_fail = _fail + ([
    (markerSize _legMarker isEqualTo [1, 1]) && {markerAlpha _legMarker == 0.5} && {(keys _legCache) isEqualTo []},
    format ["MapLegibility false left size=%1 alpha=%2 cache=%3", str (markerSize _legMarker), str (markerAlpha _legMarker), count (keys _legCache)]
] call _fnc_failed);

["A3ACC_MapLegibility", true] call CBA_settings_fnc_set;
_deadline = diag_tickTime + 5;
waitUntil { (markerSize _legMarker isEqualTo [1.2, 1.2]) || {diag_tickTime > _deadline} };
_legCache = missionNamespace getVariable ["A3ACC_markerLegibilityPrior", createHashMap];
_fail = _fail + ([
    (markerSize _legMarker isEqualTo [1.2, 1.2]) && {markerAlpha _legMarker == 1} && {(keys _legCache) isNotEqualTo []},
    format ["MapLegibility true gave size=%1 alpha=%2 cache=%3", str (markerSize _legMarker), str (markerAlpha _legMarker), count (keys _legCache)]
] call _fnc_failed);

["A3ACC_MapLegibility", false] call CBA_settings_fnc_set;
_deadline = diag_tickTime + 5;
waitUntil { (markerSize _legMarker isEqualTo [1, 1]) || {diag_tickTime > _deadline} };
_legCache = missionNamespace getVariable ["A3ACC_markerLegibilityPrior", createHashMap];
_fail = _fail + ([
    (markerSize _legMarker isEqualTo [1, 1]) && {markerAlpha _legMarker == 0.5} && {(keys _legCache) isEqualTo []},
    format ["MapLegibility false did not restore size=%1 alpha=%2 cache=%3", str (markerSize _legMarker), str (markerAlpha _legMarker), count (keys _legCache)]
] call _fnc_failed);
diag_log text "[A3ACC] settings cycle A3ACC_MapLegibility: ok";

// --- settings with no server-observable effect -------------------------------
// Four settings have no effect this tier can observe. The assertion that would
// fail is named in the plan and routed to the client record. This test cycles
// each one, so a call that raises no error is exercised, and records the finding
// rather than writing an assertion that cannot fail.
{
    private _name = _x select 0;
    private _reason = _x select 1;
    {
        [_name, _x] call CBA_settings_fnc_set;
        private _deadline = diag_tickTime + 5;
        waitUntil { (missionNamespace getVariable [_name, nil]) isEqualTo _x || {diag_tickTime > _deadline} };
    } forEach [false, true, false];
    diag_log text format ["[A3ACC] settings cycle %1: no server-observable effect (%2), routed to the client record", _name, _reason];
} forEach [
    ["A3ACC_ObjectiveHud", "fnc_objectiveHud exits on isNull player"],
    ["A3ACC_SoundCues", "fnc_soundCue exits on isNull player"],
    ["A3ACC_ReduceMotion", "no cam-shake getter exists"],
    ["A3ACC_ForceWalk", "fnc_applyWalk exits on isNull player"]
];

// Leave the tree on the shipped default: the markers gone, and the seeded engine
// variables back to the values the player held before the cycle.
deleteMarker _marker;
deleteMarker _legMarker;
{
    private _index = _forEachIndex;
    private _prefix = _engineVars select _index;
    private _triple = _enginePristine select _index;
    profileNamespace setVariable [_prefix + "_R", _triple select 0];
    profileNamespace setVariable [_prefix + "_G", _triple select 1];
    profileNamespace setVariable [_prefix + "_B", _triple select 2];
} forEach _engineVars;

if (_fail == 0) then {
    diag_log text "[A3ACC] settings cycle passed";
} else {
    diag_log text format ["[A3ACC] settings cycle failed with %1 assertion(s)", _fail];
};

(missionNamespace getVariable ["A3ACC_testResults", []]) pushBack (_fail == 0);
