# Accessibility manual QA

The rendered and interactive half of every gate. The automated gates
(`hemtt check -p -e`, `tests/verify_palette.py`, `tests/ingame`) run headless and
cannot see a pixel or accept a keypress. This checklist is the only check of the
final result.

Run it at a real Arma 3 client, after the automated gates pass.

Build and launch with `hemtt launch`. The default profile carries the CBA_A3
workshop id `450814997`, from `.hemtt/project.toml`.

## Every feature

1. Open the CBA settings menu. Confirm the `A3 Accessibility` category lists
   every setting: colour blind mode, reduce camera shake, force subtitles,
   directional gunfire cues, reduce HUD clutter, larger map markers, always
   walk, and show the current objective.
2. Confirm every default is off, and the colour blind mode default is Off.

## Colour blind mode

3. Place one marker of each of the five classes in Eden. Select each mode in
   turn and confirm the markers change, and that no marker keeps its vanilla
   colour. Select Off and confirm they all return.
4. Create a marker while a mode is active. Confirm it is recoloured. The marker
   event fires on creation, so it should be immediate, not after a delay.
5. Confirm the HUD side colours changed: a friendly and an enemy unit name tag
   and 3D icon must be blue and amber, not green and red.
6. Open the map. Confirm the scoreboard side colours and the map location names
   carry the same palette.
7. Enter a gunner optic on a vehicle. Confirm the turret indicator, the heading
   and the compass are amber or blue, not the vanilla red or green. Try a
   tracked vehicle, a wheeled gunner and a boat commander, since the optic
   classes differ.
8. Enter the Zeus editor. Confirm the selection square is cyan and the disabled
   preview is amber, not the vanilla green and red. Confirm the waypoint cursors
   are cyan, not green.
9. Open Eden. Confirm the trigger, comment and connection draw colours follow
   the mode, and that the preview swatch beside each matches.
10. Open the sensor panel. Confirm the friendly and enemy target colours follow
    the mode, since that panel does not read the map variables.
11. Open the server browser. Confirm the ping colours separate good from bad.
12. Have a task succeed and another fail. Confirm the two notification colours
    differ.
13. Fly a helicopter low then high with the airborne mini map shown. Confirm the
    altitude gradient separates low from high by brightness, not only by hue.
14. Compare a friendly unit icon on the map with a friendly marker and with the
    HUD name tag. The shipped `IslandMap` reads a different variable family for
    its side roles than the marker catalogue does, so these three may not agree.
    Record what you see. See `docs/research/20-colour-coverage.md`.

## Hearing

14. Turn subtitles off in Options. Enable "force subtitles". Confirm subtitles
    appear. Disable it. Confirm the previous setting is restored, not forced on.
15. Enable "directional gunfire cues". Have a unit fire near you. Confirm an
    on-screen cue appears in the direction of the fire, with a distance, and
    fades. Confirm it does not appear for distant fire. Repeat this on high
    ground, at least 100 m above sea level, on a hill or a mountain: confirm the
    cue sits at the shooter's position and not above them. `drawIcon3D` takes a
    PositionAGL, so an unconverted sea-level position floats higher the greater
    the elevation, and no headless test can see it.

## Motion

16. Enable "reduce camera shake". Stand near an explosion or a passing vehicle.
    Confirm the camera no longer shakes. Disable it and confirm the shake
    returns.

## Cognitive

17. Enable "reduce HUD clutter". Confirm the kill feed and the panel groups
    disappear, the HUD group icons go, and the radio chatter stops. Disable it
    and confirm the HUD is restored to its previous state, not to a default.
18. Open the pause menu and confirm an `A3 Accessibility` entry opens the help
    screen, and that the screen lists every feature.
19. Enable "show the current objective". Confirm a small panel shows the current
    task. Change task and confirm it updates. Disable it and confirm it clears.

## Low vision

20. Enable "larger map markers". Confirm the markers grow and become fully
    opaque. Disable it and confirm the previous size and alpha return, including
    for a marker that had a custom size.

## Motor

21. Enable "always walk". Confirm you walk and cannot sprint, and that
    disabling it returns sprint. This removes sprint, other players see the
    change, and a mission that depends on sprint can break. Use it deliberately.
22. Bind the keybinds. Confirm each unbound action appears in the CBA keybind
    list, and that a bound key toggles its setting.

## Log

23. Check the RPT for `Error`. It must be absent.
24. Check the addon's own report. It names the phase, the interface, the world,
    the mission, the side, the mode from both the setting and the saved value,
    the palette size, and one config sample as raw, as resolved and as written:

        [A3ACC] postInit: interface=true dedicated=false multiplayer=false world=Stratis ...
        [A3ACC] postInit: setting=2 saved=2 palette=6
        [A3ACC] postInit: CfgMarkers/Flag raw=["(missionnamespace getvariable [...])",...] resolved=[0,0.35,0.85,1] written=[0,0.35,0.85]

    A `resolved` value that equals the written value means the expression works.
    A `resolved` value that equals the shipped colour means the expression fell
    back, and the engine read that class before the addon wrote its variable.
25. Check that `[A3ACC] setting changed to N` appears when the mode is changed in
    the settings menu. It proves the callback ran live, and `applying mode N`
    follows it. `applyMode N scope=... visited=... recoloured=... live=...` then
    reports how many markers the change touched.
26. `applyVars` logs every variable it writes, with its value and its namespace,
    so a client RPT shows exactly which colours were written and when.

## UNVERIFIED items this checklist closes

- Whether the engine re-reads a profile variable expression after a runtime
  change, and at which moment each surface is evaluated. The wiki is silent, and
  the scoreboard is known to be read at load, so a mode change may need the next
  mission load for some surfaces.
- Whether the addon's own expression on a surface the game leaves uncoloured has
  any effect. `tests/verify_shipped.py` reports none such today.
- That the keybinds work: CBA keybinds are client-only and never register on a
  dedicated server, so no automated gate covers them.
- The rendered result of every palette change.

## Frame transform client gate (todo 16)

The frame transform and the double-transformation question. This section is a
record to fill from one client session. Run it after the automated gates pass,
because a client is the only tier with a renderer.

Two kinds of line appear below:

- **machine** is a line the probe or a gate wrote. Copy it from the RPT.
- **observed** is the operator's eye. No command reads the screen.

### How to run

1. Start a client with the addon loaded and the colour blind mode at Off.
2. Paste `tests/probes/probe_frame_params.console.sqf` into the debug console.
   The debug console does not accept comments, so paste the console copy and not
   the readable source. Wait for the `[A3ACC-PROBE] done` line. Record the four
   answers in `docs/research/23-frame-transform.md`.
3. Paste `tests/probes/probe_double_transform.console.sqf`. Follow each `LOOK`
   line.
4. Fill every table below.
5. Run `python3 tests/check_client_rpt.py <client rpt>`. It must exit 0.
6. Leave the mode at a value other than Off, quit, restart, and read the
   `preStart` line. Then set the mode back to Off.

The two console copies are generated from their sources by
`tests/make_console_probes.py`. That script removes whole-line comments and blank
lines, and refuses a trailing comment. Run it after an edit to a source, so the
console copy cannot go stale.

### 1. The double-transformation result

The probe draws five controls and shows four states. `A` is rule off and frame
off, `B` is rule off and frame on, `C` is rule on and frame off, and `D` is rule
on and frame on. The rule-on colour is the addon's own mapper output. Read the
on-screen colour of each control with a screen colour picker, and write it as
`R,G,B`. The six readings per control are `A`, `B`, `C`, `D` and the two pair
differences.

| Control | Configured base (machine) | Configured rule (machine) | A | B | C | D | A to B | C to D |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| OPFOR | `1,0,0` | `1,0.7,0` | | | | | | |
| BLUFOR | `0,1,1` | `0,0.35,0.85` | | | | | | |
| white | `1,1,1` | `1,1,1` | | | | | | |
| black | `0,0,0` | `0,0,0` | | | | | | |
| no-role | `0,1,0` | `0,1,0` | | | | | | |

Outcome, name one:

- **OUTCOME A, the transform moves a control the rule set.** The `C` to `D`
  difference for OPFOR and BLUFOR is inside the classifier's tolerance. The
  record names the order that holds it.
- **OUTCOME B, the transform does not move a UI control at all.** `A` equals
  `B` and `C` equals `D` for every control. The two mechanisms are independent.
  This falsifies the reach claim in the success criteria, and it is reported.
- **OUTCOME C, the transform moves the role colours past the tolerance.** The
  `C` to `D` difference for OPFOR or BLUFOR is outside the tolerance. The order
  must change, and the record names the chosen order.

Outcome: ______  Difference measured: ______  Order chosen: ______

The classifier's families and bands are in
`addons/colourblind/functions/fnc_classifyColour.sqf`. A moved colour that stays
in its own family and band is inside the tolerance.

### 2. The frame lines (machine)

From the mode change in the probe and from the settings menu:

- `[A3ACC] frame handle=1991` present: ______
- `[A3ACC] frame off destroyed` present: ______

### 3. The four settings the server tier cannot observe

Each row is an effect, not a variable. The machine line is what the probe
logged. The observation is what you saw. The objective panel needs a current
task, so give the mission one before the run.

| Setting | Machine evidence | Observed |
| --- | --- | --- |
| `A3ACC_ObjectiveHud` | on: `playerEH=true pfh=true panel=true`; off: all false | the panel text on screen |
| `A3ACC_SoundCues` | on: `firedNear=true pfh=true`; off: both false | the cue icon and its distance label |
| `A3ACC_ForceWalk` | none: no getter reads the walk flag | walk only, sprint refused; sprint returns |
| `A3ACC_ReduceMotion` | none: no getter reads cam-shake state | no shake with it on; shake with it off |

Filled:

- ObjectiveHud machine: ______  observed: ______
- SoundCues machine: ______  observed: ______
- ForceWalk observed: ______
- ReduceMotion observed: ______

### 4. The Zeus reachability result

With a mode active, open Zeus. The `RscDisplayCurator` `SideOPFOR` and
`SideIndependent` rows must render the mode colours. This is the proof that the
two retirements are safe.

- machine: `ColorEAST=______` `ColorGUER=______`
- observed: ______

### 5. The marker and group-icon result

With a mode active, confirm the flag marker, the group icons, the ORBAT default
and the Minefield marker follow the mode. This is the proof that the KEEP
decision was right.

- observed: ______

### 6. The drawn-line result

Draw a freehand line with the mode active. Draw a second line after Off. The
first must keep the colour it was drawn with.

- machine: `ColorEAST` with the mode active `______`, after Off `______`
- observed line 1 colour: ______
- observed line 2 colour: ______

### 7. The restart line

Leave the mode at a value other than Off, quit, restart.

- machine: `[A3ACC] preStart: setting=nil saved=______`

### 8. The log reader

- `python3 tests/check_client_rpt.py <client rpt>` exit: ______
- RPT path: ______
