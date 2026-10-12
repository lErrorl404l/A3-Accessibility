# Vanilla surface values, read in engine

Method: `tests/ingame/missions/a3acc_probe.Stratis` dumps the property list of a
named config class. Run with no addon loaded, so the values are the shipped ones.
The run needs `A3ACC_PARAMS="-autoInit -noBattlEye"`, because the compose file
otherwise loads the addon.

## The decisive finding

Vanilla writes marker colours as a profile-variable expression, not a literal:

```
CfgMarkers/b_unknown/color = [
    "(profilenamespace getvariable ['Map_BLUFOR_R',0])",
    "(profilenamespace getvariable ['Map_BLUFOR_G',1])",
    "(profilenamespace getvariable ['Map_BLUFOR_B',1])",
    "(profilenamespace getvariable ['Map_BLUFOR_A',0.8])"
]
```

So the engine supports a config colour that is evaluated from a profile
variable. That is the dynamic form the addon needs. It is vanilla's own pattern,
and the game's own map colour options are the proof that it works.

`CfgInGameUI/SideColors` is a literal in vanilla. It is not player-configurable.
Converting it to an expression is the addon's extension, and the engine's
re-evaluation of it is the blocking unknown.

## Captured values

`CfgMarkers/b_unknown` carries: `name`, `icon`, `texture`, `side`, `size` (29),
`scope` (1), `shadow`, `color`, `markerClass`, `showEditorMarkerColor`.

`CfgInGameUI/SideColors`, five literal keys:

| Key | Value |
|---|---|
| `colorFriendly` | `[0.709, 0.972, 0.384, 1]` |
| `colorEnemy` | `[0.706, 0.0745, 0.0196, 1]` |
| `colorNeutral` | `[0.606, 0.606, 0.606, 1]` |
| `colorCivilian` | `[0.606, 0.606, 0.606, 1]` |
| `colorUnknown` | `[0.863, 0.584, 0, 1]` |

`CfgInGameUI/MPTable`, the side keys:

| Key | Value |
|---|---|
| `colorWest` | `[0.13, 0.41, 0.87, 1]` |
| `colorEast` | `[0.83, 0.17, 0.17, 1]` |
| `colorCiv` | `[0.45, 0.05, 0.9, 1]` |
| `colorRes` | `[0.18, 0.65, 0.12, 1]` |

Note `colorNeutral` and `colorCivilian` are the same grey in vanilla, so the
addon cannot separate them at the HUD without changing one of them.

## Values read from the extracted configs

Source: `/tmp/opencode/vanilla/ui_f/a3/ui_f/config.cpp` and
`/tmp/opencode/vanilla/3den/a3/3den/config.cpp`, both produced by `extractpbo`.

`CfgNotifications`, the status colours:

| Class | Property | Value |
|---|---|---|
| `TaskSucceeded` | `color` | `[0.7, 1.0, 0.3, 1.0]` |
| `TaskFailed` | `color` | `[1.0, 0.3, 0.2, 1.0]` |
| `TaskCanceled` | `color` | `[0.7, 0.7, 0.7, 1.0]` |

`CfgWrapperUI/Cursors`:

| Class | Property | Value |
|---|---|---|
| `HC_move` | `color` | `[0, 0.6, 0, 1]` |
| `HC_overFriendly` | `color` | `[0, 0.6, 0, 1]` |

`Move`, `Move3D`, `Track` and `Track3D` define no colour property in the shipped
config. An override that adds one is inventing a value.

`Cfg3DEN`, the editor draw colours:

| Class | Value |
|---|---|
| `Trigger/Draw/3D` and `2D` | `[0.1, 0.1, 0.9, 1]` |
| `Comment/Draw/3D` and `2D` | `[0, 1, 0.75, 1]` |
| `Connections/Group` | `[0, 1, 1, 1]` |
| `Connections/Sync` | `[0, 0, 1, 1]` |
| `Connections/WaypointActivation` | `[0, 0, 1, 1]` |

Each `Draw` class carries a companion `colorPreview` with the same value. An
override that changes `color` alone leaves the editor preview swatch on the
vanilla colour.

`RscInGameUI` optics. `CA_TurretIndicator` and `CA_HorizontalCompass` use
`color`. `CA_Heading` uses `colorText`. An override that sets `color` on
`CA_Heading` has no effect.

| Colour | Classes |
|---|---|
| `[0.706, 0.0745, 0.0196, 1]`, the side red | `RscOptics_crows`, `RscOptics_Boat_Armed_01_commander`, `RscOptics_APC_Wheeled_01_gunner`, plus `RscOptics_LaserDesignator`, `RscOptics_LaserDesignator_02`, `RscOptics_Rangefinder`, `RscOptics_strider_commander`, `RscWeaponRangeArtillery`, `RscWeaponRangeArtilleryAuto` on `CA_Heading` |
| `[0.709, 0.972, 0.384, 1]`, the side green | `RscOptics_MBT_01_commander`, `RscOptics_MBT_01_commander_RCWS`, `RscOptics_MBT_01_gunner` |
| `[0.95, 0.95, 0.95, 1]`, white | `APC_Tracked_03_gunner`, `APC_Wheeled_03_commander`, `APC_Wheeled_03_gunner`, `MBT_01_driver`, `MBT_02_commander`, `MBT_02_gunner`, `MBT_03_gunner`, `RscOptics_ShipGun_01` |

## Limits of this method

`inheritsFrom` returns a null config on a dedicated server, because the parent
classes live in UI configs the server does not merge. The parent chain therefore
comes from the engine's own `Updating base class` lines in a client RPT, not from
this probe. The client RPT is at
`/ext/SteamLibrary/steamapps/compatdata/107410/pfx/drive_c/users/steamuser/AppData/Local/Arma 3/`.
