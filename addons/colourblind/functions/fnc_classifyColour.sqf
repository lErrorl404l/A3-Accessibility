#include "script_component.hpp"

/*
 * Author: lErrorl404l
 * Return the colour family and the brightness band one observed RGBA colour
 * belongs to, or an empty array when the colour carries no meaning this addon
 * owns.
 * Pure function: it reads only its arguments, so SQF-VM can run it.
 *
 * THE FUNCTION RETURNS A FAMILY, NOT A ROLE, AND GREEN IS THE REASON.
 * A hue test cannot tell the friendly green from the Independent green, because
 * both shipped values land inside the GREEN window:
 *   friendly    0.709,0.972,0.384  hue 86.8
 *   Independent 0,0.5,0           hue 120
 * The Independent green ships on the curator side row, on the compass cursors
 * and on the tank optics. A hue-derived role would repaint all of them with the
 * friendly colour. The FENCE therefore declares the role, and this function
 * only confirms that an observed colour is one this addon owns. A surface the
 * fence does not name is never visited, and a colour that matches no window is
 * art and returns an empty array.
 *
 * There is no CIVILIAN family. Vanilla ships one grey for neutral and civilian
 * together: CfgInGameUI/SideColors states colorNeutral and colorCivilian both
 * as 0.606,0.606,0.606,1. The classifier cannot separate two surfaces that the
 * engine draws with the same value, and a Civilian window would match no
 * shipped literal. Both grey surfaces are fenced at role neutral, and the
 * civilian palette stays reachable through the kept config paths.
 *
 * The classifier uses hue, saturation and value. It never compares the observed
 * colour with a colour literal, because a derived shade such as the optics red
 * 1,0.15,0.15 is in a side family and an exact match misses it.
 *
 * The tolerances. Hue is in degrees 0 to 360. Saturation, value and the band
 * are 0 to 1.
 *
 *   family RED    hue 0 to 25,  saturation at or above 0.35, value at or above 0.20
 *   family AMBER  hue 33 to 52, saturation at or above 0.55, value at or above 0.55
 *   family GREEN  hue 70 to 160, saturation at or above 0.25, value at or above 0.30
 *   family GREY   saturation below 0.25, value at or above 0.40
 *   band dark     value below 0.45
 *   band mid      value 0.45 to 0.75
 *   band bright   value above 0.75
 *
 * Why each window. The GREY test runs first, because a low saturation colour is
 * grey at any hue and no other family owns it.
 *
 * RED. Hue 0 to 25 catches the pure red at 0, the shipped OPFOR red at 4.8, the
 * curator player red at 8.6 and the derived optics red at 0. The saturation
 * floor of 0.35 rejects a pale pink that a deficient eye already reads as grey,
 * so GREY keeps it. The value floor of 0.20 rejects a near-black red used for
 * shading, which carries no side meaning.
 *
 * AMBER. Hue 33 to 52 catches the shipped amber at 40.6 and the tactical ping
 * 1,0.8,0.2 at 45. The window is narrow and the floors are high, so a yellow
 * green at hue 65 and a brown stay out. The ping is not a side, so the
 * classifier returns AMBER for it and the fence, not the hue, keeps the ping
 * out of the walk. The same holds for the Error and Warning text colours.
 *
 * GREEN. Hue 70 to 160 catches the friendly green at 86.8 and the Independent
 * green at 120. The saturation floor is 0.25, the same as GREY, so a green
 * below it is GREY and not a washed-out GREEN.
 *
 * GREY. Saturation below 0.25 catches the one shipped grey that neutral and
 * civilian share. The value floor of 0.40 rejects dark shading that carries no
 * meaning.
 *
 * The band is INFORMATIONAL. It is logged only. The fence in todo 7 is a table
 * of class, property and role, so a band has no place in it, and the mapper
 * FUNC(colourForRole) takes no band, so one role yields one mode colour at any
 * observed brightness.
 *
 * The hue conversion uses the standard sector constants: 60 degrees to a
 * sector, six sectors to a turn, and 360 degrees to a full turn. The sector
 * offsets are 0 for the red channel, 2 for the green channel and 4 for the blue
 * channel. An achromatic colour has no hue, and the code marks it with the
 * sentinel minus one, so no window matches it. The entry guard needs the first
 * three channels, because the classifier reads red, green and blue and ignores
 * alpha.
 *
 * THE TOLERANCE TABLE BELOW IS MACHINE-READ. A gate parses it instead of
 * restating the values by hand, so keep the format and keep it in step with the
 * body.
 * TOLERANCE_TABLE_BEGIN
 * FAMILY RED   HUE 0 25    SAT 0.35  VAL 0.20
 * FAMILY AMBER HUE 33 52   SAT 0.55  VAL 0.55
 * FAMILY GREEN HUE 70 160  SAT 0.25  VAL 0.30
 * FAMILY GREY  HUE - -     SAT 0.25  VAL 0.40
 * BAND dark   VAL 0 0.45
 * BAND mid    VAL 0.45 0.75
 * BAND bright VAL 0.75 1
 * TOLERANCE_TABLE_END
 *
 * Arguments:
 * 0: Observed RGBA colour <ARRAY>
 *
 * Return Value:
 * [family, band] for RED, AMBER, GREEN or GREY, or an empty array <ARRAY>
 *
 * Example:
 * [[0.706, 0.0745, 0.0196]] call A3ACC_colourblind_fnc_classifyColour
 *
 * Public: No
 */

params [["_rgba", [], [[]]]];

if (count _rgba < 3) exitWith { [] };

private _r = _rgba select 0;
private _g = _rgba select 1;
private _b = _rgba select 2;

private _max = _r max _g max _b;
private _min = _r min _g min _b;
private _chroma = _max - _min;
private _value = _max;
private _saturation = 0;
if (_value > 0) then { _saturation = _chroma / _value; };

private _hue = -1;
if (_chroma > 0) then {
    private _sector = 0;
    if (_max == _r) then {
        _sector = ((_g - _b) / _chroma) mod 6;
    } else {
        if (_max == _g) then {
            _sector = ((_b - _r) / _chroma) + 2;
        } else {
            _sector = ((_r - _g) / _chroma) + 4;
        };
    };
    _hue = 60 * _sector;
    if (_hue < 0) then { _hue = _hue + 360; };
};

private _band = "mid";
if (_value < 0.45) then {
    _band = "dark";
} else {
    if (_value > 0.75) then { _band = "bright"; };
};

private _family = "";
if (_saturation < 0.25 && _value >= 0.40) then {
    _family = "GREY";
} else {
    if (_hue >= 0 && _hue <= 25 && _saturation >= 0.35 && _value >= 0.20) then {
        _family = "RED";
    } else {
        if (_hue >= 33 && _hue <= 52 && _saturation >= 0.55 && _value >= 0.55) then {
            _family = "AMBER";
        } else {
            if (_hue >= 70 && _hue <= 160 && _saturation >= 0.25 && _value >= 0.30) then {
                _family = "GREEN";
            };
        };
    };
};

if (_family == "") exitWith { [] };

[_family, _band]
