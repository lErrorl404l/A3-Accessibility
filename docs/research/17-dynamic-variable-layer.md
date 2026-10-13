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

## The colour variables, and how they were verified

Two independent sources give the complete set, and neither is a guess:

1. The strings in `arma3_x64.exe`. The engine reads its own interface colours from
   a profile variable whose name is stored verbatim. `strings -n 5 arma3_x64.exe`
   filtered to `^(map|igui|gui)_[a-z0-9_]+$` returns exactly
   `gui_bcg_rgb`, `igui_bcg_rgb`, `igui_error_rgb`, `igui_text_rgb` and
   `igui_warning_rgb`, each with its `_r`, `_g`, `_b` and `_a` forms.
2. The namespace reads in the shipped configs. Across the 1432 `config.cpp` files
   extracted from every game PBO, the colour families read from a namespace are
   `Map_{BLUFOR,OPFOR,Independent,Civilian,Unknown}_*`, `IGUI_TEXT_RGB_*`,
   `IGUI_BCG_RGB_*`, `IGUI_WARNING_RGB_*` and `GUI_BCG_RGB_*`.

So there are ten families, forty names, and the addon writes seven of them.

| Family | Drives | Addon |
|---|---|---|
| `Map_BLUFOR_*` | friendly markers, map, ORBAT, sector capture, bases | writes R, G, B |
| `Map_OPFOR_*` | enemy markers, map, ORBAT, sector capture, bases | writes R, G, B |
| `Map_Independent_*` | neutral markers, map, ORBAT, sector capture, bases | writes R, G, B |
| `Map_Civilian_*` | civilian markers, map, ORBAT, bases | writes R, G, B |
| `Map_Unknown_*` | unknown markers and bases | writes R, G, B |
| `IGUI_ERROR_RGB_*` | error text, and the radar's incoming-danger and assault colours | writes R, G, B |
| `IGUI_WARNING_RGB_*` | warning text, and the radar's lock and waypoint colours | writes R, G, B |
| `IGUI_TEXT_RGB_*` | interface text, in every menu and HUD | not written: a text grey, not a confusion pair |
| `IGUI_BCG_RGB_*` | interface background | not written: a background |
| `GUI_BCG_RGB_*` | GUI background | not written: a background |

Alpha is left to the player in every family, so a mode never changes an
opacity.

An earlier revision of this file listed eleven families and forty-four names,
including `IGUI_TACTPING_RGB_*` for the tactical ping. That family does not
exist. The name appears in no engine string, in no shipped config and in no
script, and the string `tactping` appears nowhere in the executable. The
tactical ping is a difficulty option (`tacticalPing` in
`CfgDifficultyPresets`), and its colour is internal to the engine. The addon no
longer writes the family. `tests/verify_surface.py` holds the list above as the
engine variables the writer owns, so a name that does not exist cannot come
back.

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
