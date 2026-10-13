# Fonts and difficulty, read from the game PBOs

Method: `extractpbo` derapifies `config.bin` to `config.cpp`. Sources:
`Addons/uifonts_f.pbo` and `Addons/data_f.pbo`.

The point of this file is to say what a mod can and cannot change for text size,
for labels, and for aim assistance, from the shipped definitions rather than from
guesswork.

## Text size is not globally settable

`CfgFontFamilies` in `uifonts_f.pbo` holds 11 families:

`EtelkaMonospacePro`, `LCD14`, `EtelkaMonospaceProBold`, `EtelkaNarrowMediumPro`,
`PuristaBold`, `PuristaLight`, `PuristaMedium`, `PuristaSemibold`,
`RobotoCondensed`, `RobotoCondensedBold`, `RobotoCondensedLight`.

Nine of them carry a CJK fallback. Each family holds one array and one number:

```
class RobotoCondensed
{
    fonts[] = {
        {"...Roboto-Condensed8", "...NotoSansCJK-Light6"},
        {"...Roboto-Condensed9", "...NotoSansCJK-Light7"},
        ...
    };
    spacing = ...;
};
```

`fonts[]` is a size-indexed array. Each index pairs a Latin font with a CJK
fallback for the same size. The engine picks an index from the control's size,
so text size is decided by the `sizeEx` and `font` of each control, not by a
single global value.

Consequence: there is no global text-size lever. A mod can add a family, or
override a control's `sizeEx`, but it cannot scale the interface in one step.
A dyslexia-friendly font would also need a CJK fallback per size, so it means
shipping font assets.

## Difficulty is the lever for labels and aim aid

`CfgDifficultyPresets` in `data_f.pbo` holds four presets, `Recruit`, `Regular`,
`Veteran` and `Custom`, each with `Options` of 24 members. A legacy
`CfgDifficulties` root holds the same names under `Flags`.

The accessibility-relevant members, with the shipped value per preset. `0` is
off, `1` is limited, `2` is on:

| Option | Recruit | Regular | Veteran | Custom |
|---|---|---|---|---|
| `friendlyTags` | 2 | 1 | 0 | 0 |
| `enemyTags` | 0 | 0 | 0 | 0 |
| `visionAid` | 1 | 0 | 0 | 0 |
| `weaponCrosshair` | 1 | 1 | 0 | 0 |
| `cameraShake` | 1 | 1 | 1 | 1 |
| `groupIndicators` | 2 | 1 | 0 | 0 |
| `stanceIndicator` | 2 | 2 | 1 | 0 |
| `staminaBar` | 1 | 1 | 0 | 0 |
| `thirdPersonView` | 1 | 1 | 0 | 0 |
| `weaponInfo` | 2 | 2 | 1 | 2 |

The other members are `reducedDamage`, `detectedMines`, `commands`, `waypoints`,
`tacticalPing`, `scoreTable`, `deathMessages`, `vonID`, `mapContentFriendly`,
`mapContentEnemy`, `mapContentMines`, `mapContentPing`, `autoReport` and
`multipleSaves`.

Read a value at runtime with `difficultyOption`, for example
`difficultyOption "friendlyTags"`.

## What that means for this addon

- **Friendly tags.** A player on `Veteran` or `Custom` has `friendlyTags` off
  and `enemyTags` off. Those are the labels a low-vision or cognitive player
  relies on. A mod can ship a difficulty preset, but it cannot force the player
  to select one, and there is no script command to raise the tags at runtime.
  So this is a documentation and preset matter, not a runtime feature.
- **Aim assistance.** `visionAid` and `weaponCrosshair` are difficulty
  options. The same limit applies. A runtime lever would be `setCustomAimCoef`,
  and the roadmap already marks its semantics UNVERIFIED. Probe it before any
  claim.
- **Camera shake.** `cameraShake` is `1` in every shipped preset, so the
  option does not help. `enableCamShake false` is the only lever a mod has, which
  is what the motion component already uses. That feature is justified.
- **Text size.** Limited to the addon's own interface, because there is no
  global lever. The roadmap item LV1 must say so.

## Related shipped roots worth knowing

`data_f.pbo` also defines `ScrollBar` as a top-level class, with `thumb`,
`arrowEmpty`, `arrowFull`, `border`, `shadow` and `scrollSpeed`. It is not a
colour surface, but it is part of the interface a low-vision player reads.
