#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Assert the larger-marker setting on real markers: the full pass, the
 * single-marker path the created-marker event uses, and the event handler's
 * wiring. The handler reads the setting from missionNamespace, where CBA
 * publishes it, and takes the marker name from the event argument.
 *
 * Public: No
 */

private _fail = 0;
private _marker = "a3acc_test_marker_lv";
createMarker [_marker, [0, 0, 0]];

// The full pass enlarges the marker and records the prior state.
[true] call FUNC(applyLegibility);
if ((markerSize _marker) isNotEqualTo [1.2, 1.2]) then {
    _fail = _fail + 1;
    diag_log text format ["[A3ACC] legibility on did not resize the marker: %1", str markerSize _marker];
};
if ((markerAlpha _marker) != 1) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] legibility on did not set the marker fully opaque";
};

// The single-marker path, which the created-marker event calls. It must not
// record a second prior size for a marker already in the cache.
_marker setMarkerSizeLocal [0.7, 0.7];
[true, _marker] call FUNC(applyLegibility);
if ((markerSize _marker) isNotEqualTo [1.2, 1.2]) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] the single-marker legibility path did not resize the marker";
};

// The created-marker event must enlarge a marker created after the setting is on.
// fnc_watch returns early without an interface, so a dedicated server never
// registers the handler and this block is skipped here. The client tier covers
// it: docs/QA-accessibility.md.
if (hasInterface) then {
    missionNamespace setVariable ["A3ACC_MapLegibility", true];
    private _late = "a3acc_test_marker_lv_late";
    createMarker [_late, [0, 0, 0]];
    private _deadline = diag_tickTime + 5;
    waitUntil { (markerSize _late) isNotEqualTo [1, 1] || {diag_tickTime > _deadline} };
    if ((markerSize _late) isNotEqualTo [1.2, 1.2]) then {
        _fail = _fail + 1;
        diag_log text format ["[A3ACC] the created-marker handler did not enlarge a new marker: %1", str markerSize _late];
    };
    deleteMarker _late;
    missionNamespace setVariable ["A3ACC_MapLegibility", false];
};

// Off restores the recorded size and clears the cache.
[false] call FUNC(applyLegibility);
if ((markerSize _marker) isNotEqualTo [1, 1]) then {
    _fail = _fail + 1;
    diag_log text format ["[A3ACC] legibility off did not restore the marker size: %1", str markerSize _marker];
};
if ((count (missionNamespace getVariable ["A3ACC_markerLegibilityPrior", createHashMap])) != 0) then {
    _fail = _fail + 1;
    diag_log text "[A3ACC] legibility off did not clear the prior-size cache";
};
deleteMarker _marker;

(missionNamespace getVariable ["A3ACC_testResults", []]) pushBack (_fail == 0);
if (_fail == 0) then { diag_log text "[A3ACC] lowvision tests passed"; };
