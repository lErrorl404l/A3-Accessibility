# The shipped PBO surface

Method: list the PBOs in the game install, then scan each file's bytes for a
config root name. Configs inside a PBO are rapified, so class names appear as
plain bytes and a scan finds them. No extraction and no game run is needed.

Install: `/ext/Development/a3pm-server/addons`. Count: 196 PBOs, 2.3 GB.

To read the values rather than locate the file, extract one PBO. `extractpbo`
derapifies `config.bin` to `config.cpp` by default:

```
/home/matt/bin/extractpbo -P <install>/addons/ui_f.pbo /tmp/out
# result: /tmp/out/a3/ui_f/config.cpp
```

## Where each accessibility-relevant root is defined

| Root | Shipped PBOs |
|---|---|
| `CfgInGameUI` | `ui_f.pbo`, `functions_f.pbo`, `language_f.pbo` |
| `CfgMarkers` | `ui_f.pbo`, `3den.pbo`, `modules_f.pbo`, `functions_f.pbo`, `functions_f_exp_a.pbo` |
| `CfgGroupIcons` | `ui_f.pbo` |
| `CfgNotifications` | `ui_f.pbo`, `modules_f.pbo`, `functions_f.pbo`, `missions_f_epa.pbo`, `missions_f_bootcamp.pbo`, `language_f_bootcamp.pbo` |
| `CfgLocationTypes` | `ui_f.pbo`, `functions_f.pbo` |
| `CfgWrapperUI` | `ui_f.pbo`, `3den.pbo`, `functions_f.pbo` |
| `Cfg3DEN` | `3den.pbo`, `modules_f.pbo`, `ui_f_decade.pbo`, `functions_f.pbo`, `3den_language.pbo` |
| `RscInGameUI` | `ui_f.pbo`, `functions_f.pbo` |
| `RscTitles` | `ui_f.pbo`, `weapons_f.pbo`, `3den.pbo`, `missions_f_beta.pbo`, `ui_f_decade.pbo`, `ui_f_exp_a.pbo`, `functions_f.pbo`, `functions_f_bootcamp.pbo` |
| `CfgMarkerColors` | `ui_f.pbo`, `missions_f_beta.pbo`, `functions_f.pbo` |
| `RscStructuredText` | `ui_f.pbo`, `editor_f.pbo`, `modules_f_beta.pbo`, `ui_f_decade.pbo`, `ui_f_exp_a.pbo`, `functions_f.pbo`, `functions_f_warlords.pbo` |
| `CfgFontFamilies` | `uifonts_f.pbo` |
| `CfgDifficultyPresets` | `data_f.pbo` |
| `CfgCloudlets` | `weapons_f.pbo`, `data_f.pbo`, `weapons_f_decade.pbo`, `props_f_decade.pbo` |
| `CfgLights` | `data_f.pbo`, `weapons_f_decade.pbo`, `props_f_decade.pbo` |

`CfgStructuredText` does not exist as a root. The structured-text class is
`RscStructuredText`.

## What each root controls

- `CfgInGameUI`: the in-game HUD. `SideColors` sets the friendly, enemy, neutral, civilian and unknown colours. `MPTable` sets the respawn table. `SquadRadar` and `IslandMap` set the radar and the map.
- `CfgMarkers`: the map marker catalogue. Each class holds the icon, the size, the side and the colour.
- `CfgGroupIcons`: the 3D group icons.
- `CfgNotifications`: the task and score notifications, with a title, an icon, a sound and a colour.
- `CfgLocationTypes`: the map place-name and icon types.
- `CfgWrapperUI`: the wrapper UI framework, including the Zeus and high-command cursors.
- `Cfg3DEN`: the Eden editor draw colours.
- `RscInGameUI`: the vehicle and weapon optic HUD, including the turret indicator and the compass.
- `RscTitles`: the resource classes a `cutRsc` call can show.
- `CfgMarkerColors`: the named marker palette, for example `ColorWEST`.
- `RscStructuredText`: the structured-text control, with `colorText` and `colorBackground`.
- `CfgFontFamilies`: the font families, including the glyph sets.
- `CfgDifficultyPresets`: the difficulty options, including `visionAid`, `weaponCrosshair` and `friendlyTags`.
- `CfgCloudlets`: smoke, dust, fire and tracer particles.
- `CfgLights`: light colours.

## The dynamic layer

Most of these roots read their colour from a profile variable rather than a
literal, so the engine already re-reads them. The detail, and the 44 variables,
is in `17-dynamic-variable-layer.md`. That is the lever for a mode-driven colour
engine, and it needs no config override at all.

## Not determined here

Exact class PARENT chains cannot be read from a byte scan. Extract the PBO and
read `config.cpp`, which states each parent. The parent chains for the classes
this addon overrides are recorded in `16-vanilla-surface-values.md`.
