# The dynamic variable layer in the shipped configs

Method: extract a shipped PBO with `extractpbo`, which derapifies `config.bin`
to `config.cpp`, then read the result. No game and no server run is needed. The
values and the class parents in this file are the authoritative ones.

```
/home/matt/bin/extractpbo -P /ext/Development/a3pm-server/addons/ui_f.pbo /tmp/out
# result: /tmp/out/a3/ui_f/config.cpp
```

## The finding

The engine already evaluates 591 colour arrays from `profilenamespace`
variables. The game's own Interface > Colours options work by writing those
variables. So the engine demonstrably re-reads them.

The addon does not need to override those classes. It needs to write the
variables. That covers the surface with no config override and no inheritance
risk.

## The 44 colour variables

Two sources give the set, and each one has a blind spot.

1. The strings in `arma3_x64.exe`. `strings -n 5 arma3_x64.exe`, filtered to
   `^(map|igui|gui)_[a-z0-9_]+$`, returns `gui_bcg_rgb`, `igui_bcg_rgb`,
   `igui_error_rgb`, `igui_text_rgb` and `igui_warning_rgb`, each with its `_r`,
   `_g`, `_b` and `_a` forms. The engine reads those families itself.
2. The namespace reads in the shipped configs. The config states the rest, and it
   can read a family the engine never names. `Map_BLUFOR_*` has no engine string
   at all and is read by `CfgMarkerColors`. The same is true of
   `IGUI_TACTPING_RGB_*`, which `CfgInGameUI/TacticalPing/color` reads.

Neither source alone is complete, and a corpus with a PBO missing is not a source
at all. See the correction note at the end of this section.

| Family | Variables | Drives | Read by |
|---|---|---|---|
| `Map_BLUFOR_*` | R, G, B, A | friendly markers, map, ORBAT, sector capture, bases | config |
| `Map_OPFOR_*` | R, G, B, A | enemy markers, map, ORBAT, sector capture, bases | config |
| `Map_Independent_*` | R, G, B, A | neutral markers, map, ORBAT, sector capture, bases | config |
| `Map_Civilian_*` | R, G, B, A | civilian markers, map, ORBAT, bases | config |
| `Map_Unknown_*` | R, G, B, A | unknown markers and bases | config |
| `IGUI_TEXT_RGB_*` | R, G, B, A | interface text, in every menu and HUD | engine and config |
| `IGUI_BCG_RGB_*` | R, G, B, A | interface background | engine and config |
| `IGUI_ERROR_RGB_*` | R, G, B, A | error text, and the radar's incoming danger | engine and config |
| `IGUI_WARNING_RGB_*` | R, G, B, A | warning text, and the radar's lock and waypoints | engine and config |
| `IGUI_TACTPING_RGB_*` | R, G, B, A | the tactical ping icon | config |
| `GUI_BCG_RGB_*` | R, G, B, A | GUI background | engine and config |

The addon writes seven families. `IGUI_TEXT_RGB`, `IGUI_BCG_RGB` and
`GUI_BCG_RGB` are not written, because they are text and background greys rather
than confusion pairs. Alpha is left to the player in every family, so a mode never
changes an opacity.

### Correction: IGUI_TACTPING_RGB was wrongly removed and is back

An earlier revision removed `IGUI_TACTPING_RGB_*`, on the evidence that no engine
string and no shipped config reference existed. Both halves of that evidence were
wrong. The corpus used for the search was missing `ui_f`, the base UI PBO, so its
config was never searched. And absence from the engine strings does not disprove a
variable: `Map_BLUFOR_*` is also absent and is real.

The shipped config states it at `CfgInGameUI/TacticalPing/color`:

```
color[] = {"(profilenamespace getvariable ['IGUI_TACTPING_RGB_R',1.0])",
           "(profilenamespace getvariable ['IGUI_TACTPING_RGB_G',0.8])",
           "(profilenamespace getvariable ['IGUI_TACTPING_RGB_B',0.2])",1};
```

The defaults match the addon's palette entry for the ping, which is where those
numbers came from. The family is written again, and `tests/verify_surface.py`
lists it again.

A test that concludes a feature does not exist must search the whole corpus, and
`Addons__ui_f` and the three `MPMissions` PBOs are the directories to check for a
missing `config.cpp` before trusting a negative result.

## What reads the side variables

The marker catalogue entries are already dynamic. This is the shipped line:

```
class b_unknown: Flag
{
    color[] = {
        "(profilenamespace getvariable ['Map_BLUFOR_R',0])",
        "(profilenamespace getvariable ['Map_BLUFOR_G',1])",
        "(profilenamespace getvariable ['Map_BLUFOR_B',1])",
        "(profilenamespace getvariable ['Map_BLUFOR_A',0.8])"
    };
};
```

`CfgMarkerColors/ColorWEST`, `ColorEAST`, `ColorGUER`, `ColorCIV` and
`ColorUNKNOWN` read the same five families. So do `IslandMap`, `Sides`,
`SectorCapturedWEST` and the base icons.

Consequence: the addon can delete its overrides of `CfgMarkers`,
`CfgGroupIcons`, `CfgLocationTypes` and its 20 `A3ACC_*` marker classes, and
write the variables instead. Those three override files are also the files that
cleared the vanilla parents, so deleting them removes that whole class of defect.

## What reads no variable

These are literals in the shipped config, so a variable write cannot reach them.
Each needs its literal replaced with an expression over an addon variable.

| Surface | Vanilla value |
|---|---|
| `CfgInGameUI/SideColors` | the five literals in `16-vanilla-surface-values.md` |
| `CfgWrapperUI/Cursors` | per-cursor literals |
| `RscInGameUI` optic indicators | per-vehicle literals |
| `Cfg3DEN` draw colours | per-type literals |
| `CfgNotifications` status colours | per-status literals |

## Parent chains, read offline

The extracted config states each parent, so the fix no longer depends on a
client run to discover them. Confirmed against the client RPT, they agree:

```
class b_unknown: Flag
class o_unknown: b_unknown
class n_unknown: b_unknown
class TaskSucceeded: TaskAssigned
class TaskSucceededIcon: TaskCreatedIcon
class HC_move: Track
```

## Limits

The config is read-only at runtime, so a variable write is the only way to
change a surface that reads a variable. A surface that reads a literal can only
be changed by an override that replaces the literal with an expression. Whether
the engine re-evaluates an addon's own expression is UNVERIFIED and needs a
client run.
