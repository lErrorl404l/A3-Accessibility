# Full config sweep for colour-bearing properties

Method: a mission walks the merged `configFile` recursively (depth 16) and logs
every array property whose name matches `color|colour|rgb|tint|hue|mark|line`
with three or more elements. Run on a real Arma 3 2.20 dedicated server through
`tests/ingame`.

Result: **3453 properties**, almost all literally named `color`.

## Roots, by hit count

| Root | Hits | What it colours |
|---|---|---|
| `CfgVehicles` | 1895 | vehicle and unit models, lights, glass, camouflage |
| `CfgCloudlets` | 433 | smoke, dust, fire, tracer and impact particles |
| `CfgMagazines` | 164 | magazine and icon colours |
| `CfgMarkers` | 93 | the marker icon catalogue |
| `CfgWrapperUI` | 72 | wrapper UI controls |
| `CfgInGameUI` | 55 | HUD, map, scoreboard, radar |
| `CfgMarkerColors` | 43 | the named marker palette |
| `cfgGroupIcons` | 39 | group icons and waypoints |
| `RscInGameUI` | 35 | vehicle and weapon HUD |
| `CfgLocationTypes` | 35 | map location names and icons |
| `RscMapControl` | 33 | map terrain and overlays |
| `Cfg3DEN` | 33 | Eden editor UI |
| `RscMapControlEmpty` | 31 | empty-map background |
| `RscDisplayORBAT` | 31 | the ORBAT screen |
| `ctrlMapEmpty` | 31 | empty map control |
| `CfgLights` | 31 | light colour |
| `CfgWeapons` | 28 | weapon models and optics |
| `CfgNotifications` | 20 | notification status colours |
| `RscMiniMap`, `RscCustomInfoMiniMap` | 17, 17 | minimap |
| `CfgFiringDrills`, `CfgTimeTrials` | 14, 18 | training content |

## Findings that change the design

- **`CfgMarkers` holds a per-icon `color`.** The marker catalogue is larger than
  the five side names in `CfgMarkerColors`. Examples: `Empty` `[0.2,0.1,0.4,1]`,
  `Flag` `[1,0,0,1]`, `mil_objective` `[0,0,0,1]`, and the side icons
  `b_unknown`/`o_unknown`, which are profile-driven.
- **`cfgGroupIcons` mirrors the side colours** for group icons and waypoints.
  Same profile-driven side entries as `CfgMarkers`.
- **`RscInGameUI` carries vehicle and weapon HUD colours**, including optic
  indicators that use the vanilla side red `[0.706,0.0745,0.0196,1]`.
- **`CfgVehicles` and `CfgCloudlets` are art**, not side identity. Changing them
  changes how the game looks and risks breaking camouflage and particle reading.
  They are the largest block by count and the lowest value for accessibility.
- **The engine is closed source.** There is no engine source to read. The only
  engine truth is behaviour plus the merged config, which is why every claim here
  is measured in-engine rather than read from source.

## What this means

The side-identity surfaces are `CfgMarkerColors`, `CfgMarkers`, `cfgGroupIcons`,
`CfgInGameUI` (`SideColors`, `IslandMap`, `MPTable`, `SquadRadar`) and
`RscInGameUI` optic indicators. The art surfaces are `CfgVehicles`,
`CfgCloudlets`, `CfgLights`, `RscMapControl` terrain and the `RscDisplay*`
screens. Accessibility work should take the side-identity surfaces and leave the
art, except where a specific screen is unreadable.

## UNVERIFIED

- Whether `CfgMarkers`/`cfgGroupIcons` per-icon colours are used at draw time or
  overridden by the marker's own colour. Needs a client test.
- The rendered result of any override. Needs a client test.
