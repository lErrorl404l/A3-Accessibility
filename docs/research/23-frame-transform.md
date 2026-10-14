# The frame transform

Method: read the shipped UI config at
`/tmp/opencode/vanilla/ui_f/a3/ui_f/config.cpp` and the engine display
initialiser at
`/tmp/opencode/gamepbo/functions_f/a3/functions_f/GUI/fn_initDisplay.sqf`.
Every count below names the command that produced it.

## The per-element hook: why no class qualifies

The engine compiles a per-class script for a class that declares `scriptName`
and `scriptPath`. `A3\functions_f\GUI\fn_initDisplay.sqf` does that work at
preStart. It walks four config roots (`fn_initDisplay.sqf:66-71`): `configFile`,
`configFile >> "RscTitles"`, `configFile >> "RscInGameUI"` and
`configFile >> "Cfg3DEN" >> "Attributes"`. For each direct child with a text
`scriptPath` (`:63`), it reads `scriptName` and `scriptPath` (`:34-35`), resolves
the file through `CfgScriptPaths` (`:56`), and compiles it into `uiNamespace`
(`:52-60`). The class script is the class itself, so it can address a surface
the shared-class walk cannot.

Measured in the base UI config. Command:
`python3 /tmp/opencode/hook_measure.py /tmp/opencode/vanilla/ui_f/a3/ui_f/config.cpp`.

| Fact | Count |
|---|---|
| Classes that declare `scriptName` or `scriptPath` | 155 |
| `scriptPath` value `GUI` | 116 |
| `scriptPath` value `IGUI` | 33 |
| `scriptPath` value `Loading` | 6 |
| Under `RscTitles` | 19 |
| Under `RscInGameUI` | 3 |
| Direct children of `configFile` | 133 |

The `RscTitles` block runs from `:70667` to `:79636`. The `RscInGameUI` block
starts at `:4467`. The three `RscInGameUI` classes are `RscUnitInfo` (`:4476`),
`RscStanceInfo` (`:5106`) and `RscStaminaBar` (`:5134`). Each states
`scriptPath = "IGUI"` (`:4479`, `:5110`, `:5138`). Of the 102 direct children of
`RscInGameUI`, these three are the only ones with their own `onLoad` (`:4480`,
`:5111`, `:5139`).

The 155 is the base UI config alone. Other shipped UI PBOs declare more, so the
count is a floor for the whole game. Command: `python3
/tmp/opencode/hook_measure.py <file>` for each file. `ui_f_curator` 40,
`ui_f_contact` 39, `3den` 20, `ui_f_orange` 6, `ui_f_decade` 2.

`configFile` is the fourth root and the first in the list (`:66`). The sentence
in `docs/research/20-colour-coverage.md:301-303` names three roots and is short
by one. 133 direct children of `configFile` also declare `scriptName` or
`scriptPath`, for example `RscDisplayAAR` (`:39872`). The candidate set is 155,
not 22.

The element script takes three arguments: `[_mode, _params, _class]`. The engine
calls it that way at `fn_initDisplay.sqf:130` in the public branch and at `:148`
in the internal branch. `_mode` is `"onLoad"` or `"onUnload"` (`:15`). `_params`
is the display `onLoad` `_this`, so element 0 is the display. The display
therefore sits at `_this select 1 select 0` of the element script, and the class
sits at `_this select 2`. The shipped `scripts/igui/rscunitinfo.sqf:2-4` reads
the three elements as `_mode`, `_params` and `_class`, and `:11` reads
`_display = _params select 0`. The shipped `scripts/igui/rscstanceinfo.sqf:1`
reads `(_this select 1) select 0` directly.

The registration brake stops the call for a class that registers. `_register`
defaults to true (`:85`). A positive value runs the register block (`:92`). Its
`onLoad` branch ends in `exitWith` at `:97`, and its `onUnload` branch ends in
`exitWith` at `:116`. Both sit before the script call at `:130` and `:148`. The
class script therefore runs only for a call that passes a non-positive
`_register`.

Measured: the base UI config holds 310 `BIS_fnc_initDisplay` call sites.
Command: `grep -cP "call\s+\(?uinamespace getvariable 'BIS_fnc_initDisplay'\)"
ui_f/config.cpp` gives 310. 304 pass the default register, and 6 pass `0`.
Command: `grep -cP "'[A-Za-z]+',0\] call\s+\(?uinamespace getvariable
'BIS_fnc_initDisplay'\)" ui_f/config.cpp` gives 6. The six belong to the
`RscMsgBoxKeysPreset` family (`:3800-3801`, `:3901-3902`, `:4003-4004`), each
with an `onLoad` and an `onUnload`. None of the 19 `RscTitles` classes and none
of the 3 `RscInGameUI` classes passes `0`. The brake therefore applies to every
candidate, and no candidate class script runs today.

Each candidate, with its rejection:

- `RscInGameUI/RscUnitInfo` (`:4476`). 55 classes inherit it, so one script
  cannot tell them apart. `RscOptics_APC_Wheeled_01_gunner` (`:10550`) and
  `RscOptics_MBT_01_commander` (`:11183`) both declare `: RscUnitInfo`. Its
  subtree carries 56 colour properties. Two are `IGUI_WARNING_RGB` on
  `CA_ValueReload.colorBar` (`:4569`, `:4726`). The rest are `IGUI_TEXT_RGB`,
  `IGUI_BCG_RGB`, transparent black or white. The class is shared, so its script
  cannot give one optics display a role of its own. Its colours stay as config
  overrides.
- `RscInGameUI/RscStanceInfo` (`:5106`). Its subtree carries one colour
  property, `IGUI_BCG_RGB` on `StanceIndicatorBackground.colorText` (`:5116`).
  That is the interface background colour, not a side colour.
  `RscInGameUI/RscStaminaBar` (`:5134`) carries none.
- `RscTitles/RscGroupIndicator` (`:74704`). It declares no `scriptName` and no
  `scriptPath`, so the engine compiles no script for it. Its `onLoad` calls
  `bis_fnc_groupIndicator` (`:74710`). Its 25 colour properties are the MiniMap
  chrome and the task and name text controls (`:74729-74747`, `:74777-74790`),
  all transparent. The `scriptName` at `:74923` belongs to the next class,
  `RscTitles/RscTilesGroup` (`:74921`).
- `RscTitles/RscRespawnCounter` (`:78677`). It declares
  `scriptName = "RscRespawnCounter"` (`:78679`) and `scriptPath = "IGUI"`
  (`:78680`). Its four colour properties are `IGUI_BCG_RGB` or transparent black
  (`:78691`, `:78700`, `:78714`, `:78728`). None is a side colour.
- `RscTitles/RscMissionStatus`. No class of that name sits under `RscTitles`.
  Command: `grep -n "class RscMissionStatus" ui_f/config.cpp` returns one line,
  `:3106`, and that class is a controls group
  (`: RscControlsGroupNoScrollbars`), not a display. The name is the
  `scriptName` of `RscTitles/RscMPProgress` (`:78961`, script name at `:78966`).
- Of the 19 `RscTitles` classes that declare a script, the 18 besides
  `RscRespawnCounter` carry no side colour. Their colour properties are
  `IGUI_TEXT_RGB`, `IGUI_BCG_RGB`, transparent black, grey or white. The
  coloured literals are blue `{0,0.3,0.6,1}` (`:78311`) and `{0,0,1,0.5}`
  (`:79497`), amber `{0.8,0.5,0,1}` (`:79474`, `:79531`, `:79552`) and
  `{0.8,0.5,0,0.7}` (`:79252`), and grey `{0.3,0.3,0.3,0.7}` (`:79218`) and
  `{0.1,0.1,0.1,1}` (`:79573`). No value is a side red or a side green.
  Command: `python3 /tmp/opencode/hook_colours.py`.

No shipped class qualifies. A qualifying class must declare `scriptName` and
`scriptPath`, must carry a side colour, and must not be shared by several
displays with different roles. The 19 `RscTitles` classes fail the side-colour
test. The three `RscInGameUI` classes fail it too, except `RscUnitInfo`, which
fails the shared-class test. The brake means no candidate class script runs in
any case.

The walk over registered displays is the mechanism instead.
`fn_initDisplay.sqf:113` fires `OnDisplayRegistered` for every registered
display, inside the register block and before the brake `exitWith`. The handler
in `addons/colourblind/functions/fnc_onDisplayRegistered.sqf` takes the display
and its class from that event and walks the display controls. That event reports
`RscUnitInfo` for all 55 inheritors, because the `onLoad` string is inherited
and names `RscUnitInfo`. That is why the fence keys only where the event reports
a unique class.

The mechanism stays documented here, so a later change that finds a qualifying
class adds one script file, one `scriptName` and `scriptPath` pair, and one
fence entry.

## The per-mode frame parameters

Method: read the wiki page `ppEffectAdjust` and the wiki page `Post Process
Effects` through the Wayback Machine, then read every shipped template and every
shipped call that sets a `colorCorrections` array. The engine's own values are
the authority, because the wiki contradicts itself.

### What the documentation says, and where it contradicts itself

The `Post Process Effects` page gives the parameter table. Six values, in order:
brightness, contrast, offset, the blend array, the colorize array and the
luminance weights. The page states each one:

| Parameter | Documented sentence |
|---|---|
| brightness | "image brightness (0 - black, 1 - unchanged, 2 - white)" |
| contrast | "image contrast (1 - normal contrast)" |
| offset | "image contrast offset (0 - unchanged)" |
| blend | "color for blending (r, g, b - color, a - blend factor (0 - original color, 1 - blend color))" |
| colorize | "color for colorization (r, g, b - color, a - saturation (0 - original color, 1 - B&W multiplied by colorize color))" |
| weights | "color rgb weights for desaturation", default `[0.299, 0.587, 0.114, 0]` |

The colorize sentence is the one that matters, and the page contradicts itself
about it. The table says an alpha of 1 gives black and white. Four other places
say the reverse:

- the same page's fade-out line calls
  `[1,1,0,[0,0,0,0],[1,1,1,1],[0.299,0.587,0.114,0]]` "the default values";
- the `ppEffectAdjust` page's black-and-white example is
  `[1,0.4,0,[0,0,0,0],[1,1,1,0],[1,1,1,0]]`, an alpha of 0;
- the shipped `CfgPostProcessTemplates/BlackAndWhite` is
  `{1,1,0,{1,1,1,0},{1,1,1,0},{0.75,0.25,0,1.0}}`, an alpha of 0;
- the shipped `CfgPostProcessTemplates/Default` is
  `{1,1,0,{0,0,0,0},{1,1,1,1},{0,0,0,0}}`, an alpha of 1, and the engine applies
  it as the neutral baseline at the first post-process template call;
- the debriefing script `RscDisplayDebriefing.sqf:646-650` fades from
  `[0.4,0.4,0.4,1]` to `[0.4,0.4,0.4,0]` and calls the result "Monochromatic
  post-process".

A Default of alpha 1 cannot be black and white, or every mission would start in
grey. The table's sentence is therefore reversed. An alpha of 1 leaves the frame
unchanged, and an alpha of 0 replaces it with the grey the weights give, times
the colorize colour. The weights are the luminance coefficients, so the Rec.601
set gives a proper grey.

The seventh array is documented too, as the optional Arma 3 radial ellipse. The
addon does not use it, because an ellipse leaves the frame centre ungraded and a
mode must reach every pixel.

### The first client reading, 14 October 2026

The owner ran the mod at a client and reported, in their words: "Feels like some
is working and some isn't, not ALL colours are changing like red line, yellow
line, blue line. PP effects seem a little strong maybe?"

The client RPT is `Arma3_x64_2026-10-14_05-15-12.rpt` in the game's profile
folder. `python3 tests/check_client_rpt.py <rpt>` exits 0. The log holds no error
line that names the addon. It holds 18 warning lines of the form `Warning: Cannot
evaluate '(missionnamespace getvariable ['A3ACC_Surf_...'])'`, all at 5:15:18 to
5:15:20, before `preStart` at 5:15:21. Those name the MPTable and
DragAndDropFont surface strings, which the engine read before the addon wrote
the variables. That is the startup-ordering limit `18-wiki-command-verification`
records, and it is not a frame defect. Two further warnings are the engine's
animation noise.

The run applied mode 3 at `postInit`, then the owner stepped the mode through 3,
1, 2, 3, 4 and 0. Each step logged `frame mode N applied`, and Off logged `frame
off destroyed`. So the transform reached the engine on every step.

Every walk line reads `set=0`, for `RscDisplayMain` (319 controls), `Display3DEN`
(144), `RscDiary` (113), `RscDisplayInterrupt` (101 and 97) and
`RscDisplayGameOptions` (235 and 159). The walk set nothing because the fence
declares only the two `RscDisplayCurator` side rows, and the curator display was
never open in that session. That is the design, and it is not a defect.

The owner's red, yellow and blue lines are named by the log. At 5:19:48 the
addon logged:

    [A3ACC] marker colour 'ColorRed' has no remap and stays unchanged
    [A3ACC] marker colour 'ColorYellow' has no remap and stays unchanged
    [A3ACC] marker colour 'ColorGreen' has no remap and stays unchanged
    [A3ACC] marker colour 'ColorBlue' has no remap and stays unchanged

So the map's generic marker palette is deliberately not remapped. The frame
transform is the only mechanism that can move those colours, and only as
rendered pixels. Whether it reaches a 2D control at all is the question todo 16's
double-transform probe settles. The same block logged `applyMode 1 scope=all
visited=13 recoloured=5 live=13`, so five live surfaces did take the mode colour
on the later pass.

### The values, corrected

Two defects follow from the documented direction, and three values follow from
the owner's reading of the strength.

| Mode | Parameter | Old | New | Reason |
|---|---|---|---|---|
| 4 Achromatopsia | colorize alpha | 1 | 0 | The shipped `BlackAndWhite` template uses an alpha of 0. An alpha of 1 is the neutral set, so the first draft's achromatopsia mode applied no desaturation at all. |
| 4 Achromatopsia | contrast | 0.4 | 1 | The shipped `BlackAndWhite` template uses 1. The owner reports the effect strong, and a contrast below 1 flattens the frame. |
| 1 Protan, 2 Deutan, 3 Tritan | colorize alpha | 0.1 | 0.4 | The alpha is the desaturation, so 0.1 is a 90 percent desaturation, stronger than every shipped template except full black and white. 0.4 is the shipped `RealIsBrown` level, 60 percent, which keeps the desaturation that moves a saturated colour onto a luminance difference. |
| 1 Protan, 2 Deutan, 3 Tritan | contrast | 1.25 | 1.15 | The owner reports the effect strong. The documented normal contrast is 1, and the shipped templates use 1, 1.08 and 1.14. |
| 1 Protan, 2 Deutan, 3 Tritan | blend alpha | 0.15 | 0.1 | The alpha is the blend factor, so a smaller value is a lighter tint. The owner reports the effect strong. |

Brightness, offset, the blend colours, the colorize colours and the weights are
unchanged. The weights stay at the documented Rec.601 default, which
`tests/verify_frame.py` pins in every mode.

### The probe, and what the next run settles

`tests/probes/probe_frame_params.sqf` is the harness. Paste its body into the
Arma 3 debug console at a client with the mode set to Off. It draws sixteen known
patches on the HUD, steps through the five modes' six values, then applies an
alpha of 1 and an alpha of 0 in turn, then passes a seven-element array once. It
writes every step to the RPT and leaves the verdict to the operator.

The next run settles four things, and each costs a look, not a session:

1. Does the picture change at all on each of the five modes?
2. Which of the two alpha sets greys the picture? That closes the documentation
   conflict above.
3. Does the engine accept the seven-element form, and does the frame centre stay
   ungraded?
4. Do red, yellow and blue stay distinct on each mode, and does the picture look
   tinted or grey?

Record the answers here, with the RPT path, and then write the settled values
into `fnc_frameParams.sqf`.
