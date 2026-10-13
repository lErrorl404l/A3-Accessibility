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

## Art, not identity

A compass `up` vector, `colorScrollbar`, `RscDisplayAAR/Dead_*/colorBackground`,
`RscDisplayArcadeMap*` watermarks, and the `RscTest*` developer displays. Listed
so the next pass does not rediscover them.

## What this means

The remaining work is finite and named. Tier A is about 40 properties across 13
roots, each with an authoritative value in the table above. Tier B is about 148
properties in one root, all the same red, so one mechanical pass.
