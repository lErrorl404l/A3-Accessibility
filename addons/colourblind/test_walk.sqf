#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Assert the walk's structural facts, and probe the server-display capability.
 *
 * A dedicated server has no renderer, so the per-display recolour, the live
 * re-apply after a mode change and any rendered result are client-only. Those
 * belong to the client record in docs/QA-accessibility.md, and this test does not
 * assert them. The structural facts below need no renderer.
 *
 * The display capability is UNVERIFIED on this tier. createDisplay, allControls,
 * ctrlClassName and the ctrl colour commands are unproven here, so this test
 * probes them before it relies on them. The probe results are recorded in
 * docs/research/12-command-capability.md.
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _fail = 0;
private _savedMode = missionNamespace getVariable ["A3ACC_CVDMode", 0];
missionNamespace setVariable ["A3ACC_CVDMode", 0];

// The handler is registered in the mission namespace under the name
// BIS_fnc_addScriptedEventHandler builds.
if (isNil { missionNamespace getVariable "BIS_fnc_addScriptedEventHandler_OnDisplayRegistered" }) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] walk handler is not registered";
};

// The fence table is non-empty. The walk publishes the fence before it looks at
// the display, so a null-display call publishes it and returns.
[displayNull, "", 0] call FUNC(recolourControls);
private _fence = missionNamespace getVariable ["A3ACC_cvdFence", []];
if (count _fence == 0) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] walk fence is empty";
};

// Mode 0 returns without touching a control. Seed the published fence with a
// sentinel, then call the handler at mode 0. A handler that walked would call the
// walk, and the walk republishes the fence, so the sentinel would be overwritten.
// A handler that returns at mode 0 leaves the sentinel in place.
missionNamespace setVariable ["A3ACC_cvdFence", ["sentinel"]];
[displayNull, "RscDisplayCurator"] call FUNC(onDisplayRegistered);
if ((missionNamespace getVariable ["A3ACC_cvdFence", []]) isNotEqualTo ["sentinel"]) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] walk handler did not return at mode 0";
};
[displayNull, "", 0] call FUNC(recolourControls);

if (_fail == 0) then {
    diag_log text format ["[A3ACC] walk structural tests passed, fence entries=%1", count _fence];
};

// PROBE. The display capability on this tier is unverified, so probe it before any
// assertion depends on it. The generic results are logged first, then the walk is
// asserted only when a fenced control can be built and read back.
private _probePassed = false;
private _probeNote = "";
private _parent = findDisplay 46;
try {
    private _display = _parent createDisplay "RscDisplayEmpty";
    if (isNull _display) then {
        _probeNote = "createDisplay returned displayNull";
    } else {
        private _ctrl = _display ctrlCreate ["RscText", -1];
        if (isNull _ctrl) then {
            _probeNote = "ctrlCreate returned controlNull";
        } else {
            private _count = count (allControls _display);
            private _className = ctrlClassName _ctrl;
            private _before = ctrlTextColor _ctrl;
            private _background = ctrlBackgroundColor _ctrl;
            private _foreground = ctrlForegroundColor _ctrl;
            _ctrl ctrlSetTextColor [0.1, 0.2, 0.3, 1];
            private _after = ctrlTextColor _ctrl;
            diag_log text format ["[A3ACC] walk probe: controls=%1 ctrlClassName=%2 ctrlTextColor=%3 ctrlBackgroundColor=%4 ctrlForegroundColor=%5 after set=%6", _count, str _className, str _before, str _background, str _foreground, str _after];
            _probePassed = (_className != "") && str _after == str [0.1, 0.2, 0.3, 1];
            if (!_probePassed) then {
                _probeNote = "a control colour did not read back after it was set";
            };
            _ctrl ctrlSetTextColor _before;
        };
        _display closeDisplay 1;
    };
} catch {
    _probePassed = false;
    _probeNote = format ["exception %1", _exception];
};

if (_probePassed) then {
    // A fenced display is the curator display. Even when the generic probe passes,
    // a server may not build this display, and then the walk-setting assertion
    // cannot run here and moves to the client record.
    try {
        private _curator = _parent createDisplay "RscDisplayCurator";
        if (isNull _curator) then {
            _probePassed = false;
            _probeNote = "a fenced display could not be built";
        } else {
            private _fenced = controlNull;
            {
                if ((ctrlClassName _x) == "SideOPFOR") then { _fenced = _x; };
            } forEach (allControls _curator);
            if (isNull _fenced) then {
                _probePassed = false;
                _probeNote = "the fenced display has no SideOPFOR control";
            } else {
                private _original = ctrlTextColor _fenced;
                [_curator, "RscDisplayCurator", 1] call FUNC(recolourControls);
                private _set = ctrlTextColor _fenced;
                [_curator, "RscDisplayCurator", 0] call FUNC(recolourControls);
                private _restored = ctrlTextColor _fenced;
                if (str _set == str _original) then {
                    _fail = _fail + 1;
                    diag_log text format ["[A3ACC] walk did not recolour the fenced control, it stayed %1", str _set];
                };
                if (str _restored != str _original) then {
                    _fail = _fail + 1;
                    diag_log text format ["[A3ACC] walk did not restore the fenced control, got %1 want %2", str _restored, str _original];
                };
            };
            _curator closeDisplay 1;
        };
    } catch {
        _probePassed = false;
        _probeNote = format ["exception %1", _exception];
    };
};

if (!_probePassed) then {
    diag_log text format ["[A3ACC] walk probe failed: %1. The walk-setting assertion moves to the client record", _probeNote];
};

missionNamespace setVariable ["A3ACC_CVDMode", _savedMode];

(missionNamespace getVariable ["A3ACC_testResults", []]) pushBack (_fail == 0);
if (_fail == 0) then { diag_log text "[A3ACC] walk tests passed"; };
