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

| Family | Variables | Drives |
|---|---|---|
| `Map_BLUFOR_*` | R, G, B, A | friendly markers, map, ORBAT, sector capture, bases |
| `Map_OPFOR_*` | R, G, B, A | enemy markers, map, ORBAT, sector capture, bases |
| `Map_Independent_*` | R, G, B, A | neutral markers, map, ORBAT, sector capture, bases |
| `Map_Civilian_*` | R, G, B, A | civilian markers, map, ORBAT, bases |
| `Map_Unknown_*` | R, G, B, A | unknown markers and bases |
| `IGUI_TEXT_RGB_*` | R, G, B, A | interface text, in every menu and HUD |
| `IGUI_BCG_RGB_*` | R, G, B, A | interface background |
| `IGUI_ERROR_RGB_*` | R, G, B, A | error text |
| `IGUI_WARNING_RGB_*` | R, G, B, A | warning text |
| `IGUI_TACTPING_RGB_*` | R, G, B, A | tactical ping |
| `GUI_BCG_RGB_*` | R, G, B, A | GUI background |

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
