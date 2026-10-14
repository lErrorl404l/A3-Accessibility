#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Walk one display's controls and apply the side-and-status rule.
 *
 * THE FENCE IS THE AUTHORITY AND THE CLASSIFIER ONLY CONFIRMS. A control the
 * fence does not name is never visited, so the fence is the false-positive
 * control as well as the rule. The fence declares the ROLE of a surface, because
 * the classifier can only return a FAMILY. A hue test cannot separate the
 * friendly green at hue 86.8 from the Independent green at hue 120, so both are
 * family GREEN and a hue-derived role would repaint the Independent surfaces with
 * the friendly colour. The fence states the contradiction it resolves: the
 * curator SideIndependent row is green 0,0.5,0 and is fenced role neutral, while
 * the friendly green is fenced role friendly.
 *
 * THE FENCE IS SEEDED ONLY WHERE THE REGISTRATION EVENT REPORTS A UNIQUE DISPLAY
 * CLASS. The optics family is not fenced: every optics class inherits one onLoad
 * from RscUnitInfo, so the event reports RscUnitInfo for the MBT commander and
 * the wheeled gunner alike, and one fence entry would give both the same role.
 * Those classes keep their config override instead, because the override's
 * variable name carries the display class that the event cannot report.
 *
 * THE PROPERTY DOMAIN IS THE GETTER TABLE BELOW. A fenced property must be
 * readable AND writable through a control command. Only colorText and
 * colorBackground qualify. colorTextSecondary has a setter and no getter.
 * colorShadow has no verified mapping. ctrlSetActiveColor and ctrlSetDisabledColor
 * have no getter, so the walk cannot read an original for them and cannot restore
 * one on Off, and they stay outside the domain. The listbox getters carry no
 * config property this rule needs.
 *
 * THE ROLE VOCABULARY IS THE MAPPER'S DOMAIN: enemy, friendly, neutral or unknown,
 * one of exactly four. It is not the addon's older surface keys OPFOR, BLUFOR and
 * Independent. FUNC(colourForRole) takes the palette class names, and a fence role
 * is one of the four, so no bridge from the old keys is needed here.
 *
 * THE GETTER TABLE IS MACHINE-READ. tests/verify_fence.py parses it, so keep the
 * format and keep it in step with the body.
 * GETTER_TABLE_BEGIN
 * GETTER ctrlTextColor       SETTER ctrlSetTextColor       PROPERTY colorText
 * GETTER ctrlBackgroundColor SETTER ctrlSetBackgroundColor PROPERTY colorBackground
 * GETTER ctrlForegroundColor SETTER ctrlSetForegroundColor PROPERTY UNVERIFIED
 * GETTER lbColor             SETTER lbSetColor             PROPERTY listbox-item-colour
 * GETTER lbColorRight        SETTER lbSetColorRight        PROPERTY listbox-right-colour
 * GETTER lbPicture           SETTER lbSetPicture           PROPERTY listbox-picture
 * GETTER lbPictureRight      SETTER lbSetPictureRight      PROPERTY listbox-right-picture
 * GETTER_TABLE_END
 *
 * Arguments:
 * 0: Display to walk <DISPLAY>
 * 1: Display class the registration event reported <STRING>
 * 2: Mode index <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_display", displayNull, [displayNull]], ["_displayClass", "", [""]], ["_mode", 0, [0]]];

private _fence = [
    ["RscDisplayCurator", "SideOPFOR", "colorText", "enemy"],
    ["RscDisplayCurator", "SideIndependent", "colorText", "neutral"]
];

// The fence is published so a test can see its shape without a display, and so
// the walk test can observe that a mode-0 call never reaches the walk at all.
missionNamespace setVariable ["A3ACC_cvdFence", _fence];

if (isNull _display || _displayClass == "") exitWith {};

_mode = _mode max 0 min 4;

// The key is the triple display class, control class and property, joined into
// one string, because a string is a stable HashMap key.
private _fenceIndex = createHashMap;
{
    _x params ["_fenceDisplay", "_fenceControl", "_fenceProperty", "_fenceRole"];
    _fenceIndex set [format ["%1/%2/%3", _fenceDisplay, _fenceControl, _fenceProperty], _fenceRole];
} forEach _fence;

// Only these two properties are readable AND writable through a control command.
// The getter and setter names are commands, and the fence holds config property
// names, so this table is the only bridge between the two.
private _getterFor = createHashMapFromArray [
    ["colorText", "ctrlTextColor"],
    ["colorBackground", "ctrlBackgroundColor"]
];
private _setterFor = createHashMapFromArray [
    ["colorText", "ctrlSetTextColor"],
    ["colorBackground", "ctrlSetBackgroundColor"]
];

private _originals = missionNamespace getVariable ["A3ACC_cvdOriginal", createHashMap];
private _controls = allControls _display;
private _set = 0;
private _start = diag_tickTime;

{
    private _ctrl = _x;
    private _ctrlClass = ctrlClassName _ctrl;
    if (_ctrlClass == "") then {
        diag_log text format ["[A3ACC] walk %1: a control has no class name and is skipped", _displayClass];
    } else {
        {
            private _property = _x;
            private _key = format ["%1/%2/%3", _displayClass, _ctrlClass, _property];
            private _role = _fenceIndex getOrDefault [_key, ""];
            if (_role != "") then {
                // The store predicate is key absence, never classification. A
                // mode colour classifies to no family, so a classification guard
                // would store the mode colour over the true original and Off
                // would then restore the mode colour.
                if !(_key in _originals) then {
                    private _observed = _ctrl call (compile format ["%1 _this", _getterFor get _property]);
                    _originals set [_key, _observed];
                };
                private _original = _originals get _key;
                private _confirmed = [_original] call FUNC(classifyColour);
                if (count _confirmed > 0) then {
                    diag_log text format ["[A3ACC] band %1/%2 %3", _displayClass, _ctrlClass, _confirmed select 1];
                    private _target = if (_mode == 0) then { _original } else { [_mode, _role] call FUNC(colourForRole) };
                    if (count _target == 4) then {
                        private _current = _ctrl call (compile format ["%1 _this", _getterFor get _property]);
                        if (str _current != str _target) then {
                            [_ctrl, _target] call (compile format ["(_this select 0) %1 (_this select 1)", _setterFor get _property]);
                            _set = _set + 1;
                        };
                    };
                };
            };
        } forEach (keys _getterFor);
    };
} forEach _controls;

missionNamespace setVariable ["A3ACC_cvdOriginal", _originals];
diag_log text format ["[A3ACC] walk class=%1 controls=%2 set=%3 ms=%4", _displayClass, count _controls, _set, round ((diag_tickTime - _start) * 1000)];
