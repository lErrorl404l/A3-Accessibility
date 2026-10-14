#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Assert the frame parameter table and the server half of the transform.
 *
 * A dedicated server has no renderer, so this test asserts only what a server
 * can assert. The create, the adjust, the commit, the enable and the destroy
 * are unreachable here, because the runtime returns before them when there is
 * no interface. Those five belong to the client record in
 * docs/QA-accessibility.md, and this test does not assert them.
 *
 * The handle alone cannot prove the early return. ppEffectCreate returns nil on
 * a dedicated server, so the handle variable is never observable there. An
 * assertion on it would pass whatever the function did. The test therefore
 * seeds the handle with a sentinel before the call. The function writes the
 * handle only on the render path. A sentinel that survives proves the early
 * return. The function clears a sentinel when it does not return early, so the
 * test fails on that run.
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _fail = 0;

// Every array nested anywhere inside the value, so a colour matrix cannot hide
// one level down. The parameter table holds no such array. A matrix is ten or
// more numbers in one array, and the scripting API has no matrix argument.
private _fnc_hasWideArray = {
    params ["_value"];
    private _wide = false;
    if (_value isEqualType []) then {
        if ((count (_value select { _x isEqualType 0 })) >= 10) then {
            _wide = true;
        };
        {
            if ([_x] call _fnc_hasWideArray) then { _wide = true; };
        } forEach _value;
    };
    _wide
};

// The five modes. Each returns exactly six documented parameters, and no
// element holds ten or more numbers.
{
    private _params = [_x] call FUNC(frameParams);
    if (count _params != 6) then {
        _fail = _fail + 1;
        diag_log text format ["[A3ACC] frame mode %1 returned %2 parameters, want 6", _x, count _params];
    };
    if ([_params] call _fnc_hasWideArray) then {
        _fail = _fail + 1;
        diag_log text format ["[A3ACC] frame mode %1 has a numeric array of ten or more numbers", _x];
    };
} forEach [0, 1, 2, 3, 4];

if (hasInterface) then {
    // A client has the create path. This test does not run the call there,
    // because it would create an effect without a same-test destroy. The client
    // record covers the create.
    diag_log text "[A3ACC] frame applyFrame not called: hasInterface is true, the create path belongs to the client record";
} else {
    // With no interface the function returns before the render path, so it
    // writes nothing. The handle is the only state it writes, and a nil handle
    // proves nothing here, because ppEffectCreate returns nil on a dedicated
    // server. The sentinel makes the write visible: the function must leave it
    // in place. A run with the guard removed reaches the Off path, clears the
    // handle and fails the assertion.
    private _sentinel = 7;
    missionNamespace setVariable ["A3ACC_colourblind_ppHandle", _sentinel];
    [0] call FUNC(applyFrame);
    private _handle = missionNamespace getVariable ["A3ACC_colourblind_ppHandle", -1];
    if (_handle isEqualTo _sentinel) then {
        diag_log text "[A3ACC] frame applyFrame skipped on a server: hasInterface is false and the handle is untouched";
    } else {
        _fail = _fail + 1;
        diag_log text format ["[A3ACC] frame applyFrame did not return early on a server: the handle changed from %1 to %2", str _sentinel, str _handle];
    };
    missionNamespace setVariable ["A3ACC_colourblind_ppHandle", nil];
};

(missionNamespace getVariable ["A3ACC_testResults", []]) pushBack (_fail == 0);
if (_fail == 0) then { diag_log text "[A3ACC] frame tests passed"; };
