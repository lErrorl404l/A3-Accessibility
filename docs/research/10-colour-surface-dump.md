# Vanilla colour surface, dumped in-engine

Source of record for the whole-game colour expansion. Dumped from a real Arma 3
2.20 dedicated server by walking `configFile` in a mission and logging every
colour key. Method: `tests/ingame` with a config-dump `init.sqf`.

This closes the UNVERIFIED items in `06-arma3-colour-surface.md`: the exact
`CfgInGameUI` colour keys are now known.

## 1. CfgInGameUI/SideColors (HUD and 3D icon side colours)

The friend/foe colours the HUD and 3D icons use. Concrete RGBA arrays, so an
addon config can override them.

| Key | Value |
|---|---|
| `colorFriendly` | `[0.709, 0.972, 0.384, 1]` (light green) |
| `colorEnemy` | `[0.706, 0.0745, 0.0196, 1]` (red) |
| `colorNeutral` | `[0.606, 0.606, 0.606, 1]` (grey) |
| `colorCivilian` | `[0.606, 0.606, 0.606, 1]` (grey) |
| `colorUnknown` | `[0.863, 0.584, 0, 1]` (amber) |

Note the conflict: friendly is green and enemy is red, the classic
protan/deutan confusion pair. This is the highest-value HUD target.

## 2. CfgInGameUI/IslandMap (map object colours)

Most side colours here are profile-driven expressions, for example
`colorEnemy = ["(profilenamespace getvariable ['Map_OPFOR_R',0])", ...]`. The
engine evaluates these; `getArray` returns the raw expression. The rest are
concrete:

| Key | Value |
|---|---|
| `colorExplosive` | `[1, 0, 0, 1]` |
| `colorNonPlayable` | `[0.25, 0.25, 0.25, 1]` |
| `colorMe` | `[0.7, 0.1, 0, 1]` |
| `colorPlayable` | `[0.7, 0, 0.7, 1]` |
| `colorSelect` | `[0, 0, 0, 1]` |
| `colorCamera` | `[0.1, 0.1, 0.9, 1]` |
| `colorSensor` | `[0.1, 0.1, 0.9, 1]` |
| `colorDragging` | `[0.8, 0.8, 0.8, 1]` |
| `colorInactive` | `[1, 1, 1, 0.6]` |
| `colorExposureEnemy` | `[1, 0.2, 0.2, 0.5]` |
| `colorExposureUnknown` | `[0.8, 0.8, 0.2, 0.5]` |
| `colorCheckpoints` | `[0.2, 0.2, 0.2, 1]` |
| `colorMissions` | `[0.5, 0.5, 0, 0.5]` |
| `colorActiveMission` | `[0, 0, 0, 1]` |
| `colorPath` | `[0, 1, 1, 1]` |
| `colorPathDone` | `[0, 1, 0, 0.8]` |
| `colorInfoMove` | `[1, 1, 1, 1]` |
| `colorGroups` | `[0, 0.5, 0.5, 0.5]` |
| `colorActiveGroup` | `[0, 1, 1, 1]` |
| `colorSync` | `[0, 0, 1, 1]` |
| `colorDetectorSync` | `[0, 1, 0, 1]` |
| `colorLabelBackground` | `[0, 0, 0, 1]` |

## 3. CfgInGameUI/MPTable (multiplayer scoreboard)

| Key | Value |
|---|---|
| `color` | `[1, 1, 1, 1]` |
| `colorBg` | `[0, 0, 0, 0.6]` |
| `colorBgAlt` | `[0, 0, 0, 0.65]` |
| `colorCaptionBg` | `[0, 0, 0, 1]` |
| `colorTitleBg` | `[0, 0, 0, 1]` |
| `colorSelected` | `[0, 0, 0, 0.9]` |
| `colorWest` | `[0.13, 0.41, 0.87, 1]` |

## 4. CfgInGameUI/SquadRadar

| Key | Value |
|---|---|
| `friendlyUnitColor` | `[0.8, 0.8, 0.8, 0]` |
| `enemyUnitColor` | `[0.7, 0.1, 0, 0]` |
| `taskIconColor` | `[0.8, 0.6, 0, 0]` |
| `colorBackground` | `[0.8, 0.8, 0.8, 0]` |

## 5. CfgNotifications (status colours)

Concrete where not profile-driven:

| Class | Key | Value |
|---|---|---|
| `TaskSucceeded` | `color` | `[0.7, 1, 0.3, 1]` |
| `TaskFailed` | `color` | `[1, 0.3, 0.2, 1]` |
| `TaskCanceled` | `color` | `[0.7, 0.7, 0.7, 1]` |
| `TaskAssignedIcon` | `colorIconPicture` | `[1, 0.7, 0, 1]` |
| `TaskSucceededIcon` | `color` | `[0.7, 1, 0.3, 1]` |
| `TaskFailedIcon` | `color` | `[1, 0.3, 0.2, 1]` |
| `TaskCanceledIcon` | `color` | `[0.7, 0.7, 0.7, 1]` |
| `ScoreAdded` | `color` | `[0.5, 1, 1, 1]` |
| `ArmoryGearAddingFailed` | `color` | `[0.8, 0, 0, 1]` |
| `ArmoryInventoryFull` | `color` | `[0.8, 0, 0, 1]` |
| `ArmoryMissingRequiredGear` | `color` | `[0.8, 0, 0, 1]` |
| `APTicketsGone` | `color` | `[1, 0.3, 0.2, 1]` |
| `CuratorAddAddons` | `color` | `[1, 1, 0.4, 1]` |

The `Default` notification and `HubSysTemplate` use profile-driven
`IGUI_TEXT_RGB_*`.

## 6. RscMapControl (map terrain and overlay colours)

| Key | Value |
|---|---|
| `colorBackground` | `[0.969, 0.957, 0.949, 1]` |
| `colorOutside` | `[0, 0, 0, 1]` |
| `colorText` | `[0, 0, 0, 1]` |
| `colorSea` | `[0.467, 0.631, 0.851, 0.5]` |
| `colorForest` | `[0.624, 0.78, 0.388, 0.5]` |
| `colorRocks` | `[0, 0, 0, 0.3]` |
| `colorCountlines` | `[0.572, 0.354, 0.188, 0.25]` |
| `colorMainCountlines` | `[0.572, 0.354, 0.188, 0.5]` |
| `colorCountlinesWater` | `[0.491, 0.577, 0.702, 0.3]` |
| `colorMainCountlinesWater` | `[0.491, 0.577, 0.702, 0.6]` |
| `colorPowerLines` | `[0.1, 0.1, 0.1, 1]` |
| `colorRailWay` | `[0.8, 0.2, 0, 1]` |
| `colorNames` | `[0.1, 0.1, 0.1, 0.9]` |
| `colorInactive` | `[1, 1, 1, 0.5]` |
| `colorLevels` | `[0.286, 0.177, 0.094, 0.5]` |

Terrain colours are art, not side identity. Changing them alters the look of the
map and is the highest risk of "breaking the game". Treat as optional.

## 7. CfgMarkerColors

Already covered by the addon. See `06-arma3-colour-surface.md` section 7 for the
vanilla palette.

## 8. Mechanism findings

- `SideColors`, `MPTable`, `SquadRadar`, `RscMapControl` and most
  `CfgNotifications` entries hold concrete RGBA arrays. An addon config override
  replaces them.
- `IslandMap` side colours and some `CfgNotifications` entries are
  `(profilenamespace getvariable ['<NAME>',<default>])` expressions. The engine
  evaluates them. `getArray` returns the raw expression string, so a runtime
  profile change cannot be observed through `getArray`. Whether the engine
  re-reads them live is UNVERIFIED and needs a client test.
- `PlayerColors` entries are procedural textures (`#(argb,8,8,3)color(...)`),
  not arrays, so they are not remappable as RGBA.

## 9. UNVERIFIED

- Whether the engine re-reads `CfgInGameUI` colours after a runtime change, or
  only when the UI is built. Needs a client test.
- Whether overriding `RscMapControl` terrain colours is visually acceptable.
- The rendered result of any palette change. Needs a client test.
