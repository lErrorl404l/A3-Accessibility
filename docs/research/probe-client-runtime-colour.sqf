// Client-side capability probe for runtime colour work. Paste the body into the
// Arma 3 debug console, or run it from a mission. It writes to the RPT.
//
// It answers three questions:
// 1. Can every colour-bearing property be found at runtime, across the whole
//    merged config, including mods?
// 2. Can a UI control colour be changed at runtime and read back?
// 3. Can a marker take an arbitrary colour array at runtime?

private _t0 = diag_tickTime;

private _hits = [];
private _walk = {
    params ["_cfg", "_path", "_depth"];
    if (_depth <= 0) exitWith {};
    {
        private _entry = _x;
        if (isClass _entry) then {
            [_entry, format ["%1/%2", _path, configName _entry], _depth - 1] call _walk;
        } else {
            if (isArray _entry) then {
                private _name = toLowerANSI configName _entry;
                if ((_name find "color") >= 0 || {(_name find "colour") >= 0}) then {
                    if ((count (getArray _entry)) >= 3) then {
                        _hits pushBack format ["%1/%2", _path, configName _entry];
                    };
                };
            };
        };
    } forEach (configProperties [_cfg, "true", false]);
};

[configFile, "configFile", 12] call _walk;
diag_log format ["[A3ACC-CPROBE] colour properties found=%1", count _hits];
diag_log format ["[A3ACC-CPROBE] sample=%1", (_hits select [0, 5])];

// Can a control colour be changed at runtime and read back?
private _display = displayNull;
{
    private _d = findDisplay _x;
    if (!isNull _d) exitWith { _display = _d; };
} forEach [46, 12, 49, 602, 313];

if (isNull _display) then {
    diag_log "[A3ACC-CPROBE] no display open, control test skipped";
} else {
    private _controls = allControls _display;
    private _changed = 0;
    {
        private _control = _x;
        _control ctrlSetTextColor [0, 0.35, 0.85, 1];
        if ((ctrlTextColor _control) isEqualTo [0, 0.35, 0.85, 1]) then {
            _changed = _changed + 1;
        };
    } forEach _controls;
    diag_log format ["[A3ACC-CPROBE] display %1 controls=%2 accepted text colour=%3",
        (ctrlIDD _display), count _controls, _changed];
};

// Can a marker take an arbitrary colour array?
private _marker = "a3acc_cprobe_marker";
createMarker [_marker, [0, 0, 0]];
_marker setMarkerColorLocal [0.1, 0.2, 0.3, 1];
private _read = markerColor _marker;
diag_log format ["[A3ACC-CPROBE] marker array round trip=%1 want=[0.1,0.2,0.3,1]",
    _read isEqualTo [0.1, 0.2, 0.3, 1]];
deleteMarker _marker;

diag_log format ["[A3ACC-CPROBE] done in %1 s", diag_tickTime - _t0];
