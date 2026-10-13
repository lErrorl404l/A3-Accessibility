# Colour coverage across the shipped game

Method: walk every extracted shipped config and classify each colour-bearing
property as dynamic (already a profile or mission expression, so the engine
re-reads it) or literal (a fixed value, which only a config override can move).
Then flag the literals whose value is a red or a green, the protan and deutan
confusion pair. Script: `/tmp/opencode/coverage.py`, run against
`/tmp/opencode/vanilla` and `/tmp/opencode/gamepbo`.

The rule ignores a triple outside 0 to 1, so a coordinate is not mistaken for a
colour. It still reports some art: a compass `up` vector, a scrollbar, and the
`RscTest*` developer displays. Those are noted rather than treated as targets.

## Summary, by root, worst first

| Root | Total | Dynamic | Literal | Red or green |
|---|---|---|---|---|
| `RscInGameUI` | 537 | 125 | 321 | 133 |
| `CfgInGameUI` | 181 | 83 | 94 | 18 |
| `CfgUIColors` | 96 | 0 | 81 | 14 |
| `CfgNotifications` | 45 | 12 | 29 | 12 |
| `RscDisplayAAR` | 18 | 0 | 18 | 11 |
| `Cfg3DEN` | 426 | 5 | 333 | 10 |
| `CfgMarkers` | 58 | 3 | 54 | 7 |
| `CfgWrapperUI` | 73 | 0 | 73 | 6 |
| `CfgCurator` | 58 | 0 | 53 | 6 |
| `RscDisplayCampaignLobby` | 89 | 0 | 86 | 5 |
| `RscDisplayMultiplayer` | 29 | 2 | 23 | 5 |
| `CfgMarkerColors` | 23 | 5 | 18 | 5 |

`CfgCurator` is covered. `CfgContact` appeared high on a first pass, but every
hit was a task destination coordinate, so the rule now rejects it.

## Tier A. Side and status identity, real user impact

These carry what a player uses to tell friend from foe, or good from bad.

| Root | Class | Property | Shipped | Map to |
|---|---|---|---|---|
| `CfgMarkers` | `Flag` | `color` | `1,0,0` red | OPFOR |
| `CfgMarkers` | `Select` | `color` | `1,0,0` red | OPFOR |
| `CfgMarkers` | `GroundSupport_CAS_EAST` | `color` | `0.5,0,0` red | OPFOR |
| `CfgMarkers` | `GroundSupport_CAS_RESISTANCE` | `color` | `0,0.5,0` green | Independent |
| `CfgMarkers` | `GroundSupport_ARTY_EAST` | `color` | `0.5,0,0` red | OPFOR |
| `CfgMarkers` | `GroundSupport_ARTY_RESISTANCE` | `color` | `0,0.5,0` green | Independent |
| `CfgMarkers` | `Minefield` | `color` | `0.9,0,0` red | OPFOR |
| `CfgGroupIcons` | `Flag` | `color` | `1,0,0` red | OPFOR |
| `CfgGroupIcons` | `Select` | `color` | `1,0,0` red | OPFOR |
| `RscCustomInfoSensors` | `targets` | `colorFriendly` | `0,1,0` green | BLUFOR |
| `RscCustomInfoSensors` | `targets` | `colorEnemy` | `1,0,0` red | OPFOR |
| `RscCustomInfoSensors` | `targets` | `colorAssigned` | `1,0,0` red | OPFOR |
| `RscCustomInfoSensors` | `threats` | `colorMissile` | `1,0,0` red | OPFOR |
| `CfgWrapperUI/Cursors` | `3DENPlaceWaypoint` and its six siblings | `color` | `0.5,1.0,0.5` green | Independent |
| `CfgInGameUI` | `CommandBar/UnitInfo/UnitCombatMode` | `colorBlue`, `colorGreen`, `colorRedTeam`, `colorWhite`, `colorText` | red | OPFOR |
| `CfgInGameUI` | `DragAndDropFont` | `colorEnabled`, `colorDisabled` | green, red | BLUFOR, OPFOR |
| `RscDisplayCurator/Controls/Add/controls` | `SideOPFOR` | `colorText` | `0.5,0,0` red | OPFOR |
| `RscDisplayCurator/Controls/Add/controls` | `SideIndependent` | `colorText` | `0,0.5,0` green | Independent |
| `RscDisplayMultiplayer` | self and `CA_ValueSessions` | `colorPingGood`, `colorPingBad`, `colorVersionBad` | green, red | BLUFOR, OPFOR |
| `CfgORBATDefault` | self | `color` | `1,0,0` red | OPFOR |
| `RscChatListDefault` | self | `colorGroupChannel`, `colorGroupChannelPlayerBackground` | green | BLUFOR |

Note on `RscCustomInfoSensors`: `colorFriendly` is a green literal, so the
sensor panel does not read `Map_BLUFOR_*` and does not follow the mode today.
That panel is a side-identity surface, so it is a real gap.

## Tier B. Large but mechanical

`RscInGameUI` holds about 148 optic and artillery text colours set to the exact
side red `0.706,0.0745,0.0196`. They are `colorText` on controls such as
`CA_Heading`, `CA_OpticsPitch`, `CA_Distance`, `CA_Elev`, across
`RscWeaponRangeArtillery`, `RscWeaponRangeArtilleryAuto`, `RscOptics_Rangefinder`,
`RscOptics_LaserDesignator`, `RscOptics_strider_commander` and more. Each is the
same red, so a single mechanical pass covers them. The addon covers only the six
turret indicator and compass cases today.

## Largely handled already

`CfgUIColors` holds the interface and map colour PRESETS, for example
`CfgUIColors/Map/Presets/PresetA3/Variables/OPFOR` at `0.5,0,0` and
`Independent` at `0,0.5,0`, and `CfgUIColors/IGUI/Presets/*/Variables/ERROR_RGB`
at the side red. A preset supplies the default for a profile variable. The addon
writes the profile variable itself, so the preset does not decide the colour
while a mode is on. Worth a line in the notes rather than an override.

## A vanilla inconsistency in the map colours

The shipped `CfgInGameUI/IslandMap` does not use the same variable for a role as
the marker catalogue does. Read from the extracted config:

| `IslandMap` key | Reads | The marker catalogue uses that variable for |
|---|---|---|
| `colorFriendly` | `Map_Independent` | neutral |
| `colorNeutral` | `Map_Civilian` | civilian |
| `colorCivilian` | `Map_BLUFOR` | friendly |
| `colorEnemy` | `Map_OPFOR` | enemy |
| `colorUnknown` | `Map_Unknown` | unknown |

So the map's unit icons take their colour from a different family than the map
markers and the HUD. In vanilla the default values happen to look consistent, so
the swap is invisible. With a CVD palette the roles separate, and the map's
friendly colour can differ from the HUD's.

The addon does not override `IslandMap`, so it inherits the swap. Correcting it
means overriding the five keys to read the family the role implies. That is a
behaviour change to vanilla, and the result cannot be seen from a dedicated
server, so it is left as a recorded finding with a client check: compare a
friendly unit icon on the map with a friendly marker and with the HUD tag.

## Art, not identity

Each surface below carries no side identity, or carries a status that no
confusion pair shares. The addon leaves every one as shipped.

- `RscDisplayAAR/controls/Dead_0` to `Dead_10` state
  `colorBackground = {1,0,0,0}`. The alpha is zero, so the control paints
  nothing. A lone red with no green counterpart is not a protan or deutan
  confusion pair either way, so the addon leaves it.
- `RscCombo/colorScrollbar` and `RscCombo/colorActive`, the `RscDebugConsole`
  button backgrounds, `RscDisplayArcadeMap_Layout_2/Controls/Watermark/colorText`,
  `ctrlMap/colorRailWay`, `RscDisplayMainMap/objects/Compass/*` and
  `RscDisplayMainMap/controls/CA_MouseOver/colorText` are interface chrome or
  art. None of them tells one side from another, so the addon leaves them.
- `ctrlMap/colorForest` and the other terrain colours are art. ACCESSIBILITY.md
  already states the addon does not change terrain, so the addon leaves them.
- The `RscTest*` developer displays and the compass `up` vector are the same
  kind of art.

Listed so the next pass does not rediscover them.

## What this means

The remaining work is finite and named. Tier A is about 40 properties across 13
roots, each with an authoritative value in the table above. Tier B is about 148
properties in one root, all the same red, so one mechanical pass.

## Status

Tier A and Tier B are covered. The config reads a per-channel profile variable
and `addons/colourblind/functions/fnc_applyVars.sqf` writes it. The value of
every expression default comes from the shipped config, not from this report.

Three rows needed a correction against the shipped config:

- `CfgInGameUI/CommandBar/UnitInfo/UnitCombatMode` states `colorBlue`,
  `colorGreen`, `colorWhite` and `colorText`, all the side red. It states no
  `colorRedTeam`. `CfgInGameUI/CommandBar` states `colorRedTeam`. Both classes
  are converted.
- `RscDisplayMultiplayer/controls/CA_ValueSessions` states no
  `colorVersionBad`, so the addon converts only the two ping colours there.
- `CfgInGameUI/CommandBar/UnitInfo/UnitCombatMode` also states `colorRed` and
  `colorYellow`, both black. The addon leaves those as shipped.

The two `GroundSupport` resistance markers map to `Independent`, because the
green means the neutral side. The `GroundSupport` east markers map to `OPFOR`.

`RscOpticsRangeFinderMRAWS` and `RscOpticsRangeFinderVorona` come from the Tank
DLC, and the `GroundSupport` markers come from the Helicopters DLC. The addon
lists `A3_Ui_F_Tank` and `A3_Missions_F_Heli` in `requiredAddons`.

A later pass covers three more status surfaces:

- `RscCustomInfoAirborneMiniMap/controls/MiniMap/Controls/CA_MiniMap` states the
  altitude gradient `altitudeMapColorLow` green, `altitudeMapColorMid` yellow and
  `altitudeMapColorHigh` red, each at alpha 0.15. A gradient maps by luminance,
  so Low takes `Independent`, Mid takes `Unknown` and High takes `OPFOR`.
- `RscDisplayMultiplayerSetup/colorConfirmed` green takes `BLUFOR`, and
  `RscDisplayMultiplayerSetup/controls/CA_ValueRoles/colorAI` red takes `OPFOR`.
- `RscHorizontalCompass/Controls/Compass/Controls/DangerZone/colorText` dark red
  and `RscHorizontalCompass/Controls/Compass/Controls/Bar1/Controls/HQ/colorText`
  red both take `OPFOR`.

`RscHorizontalCompass` lives in `A3_UI_F_Contact`, so the addon lists that name
in `requiredAddons`.
