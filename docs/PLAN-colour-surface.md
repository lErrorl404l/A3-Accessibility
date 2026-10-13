# A3 Accessibility - whole colour-surface remap for colour-vision deficiency

**Superseded.** The colour engine is now dynamic: a mode change writes the
engine profile variables rather than replacing config values. See
`docs/PLAN-dynamic.md` for the current design, `docs/research/17-dynamic-variable-layer.md`
for the 44 variables the engine reads, and `docs/research/20-colour-coverage.md`
for what is covered. This file is kept for the palette tables in sections 2.3 to
2.5, which are still the source of the mode values.

Status: decision complete. The worker needs no further interview.
Slice: extend the addon from map markers only to the whole in-game colour surface.
Evidence base: `docs/research/10-colour-surface-dump.md` (authoritative key list),
`docs/research/06-arma3-colour-surface.md`, `docs/research/01-cvd-types.md`,
`docs/research/05-aee-prior-art.md`, `docs/research/02-cba-and-tooling.md`,
`docs/research/03-testing.md`, and `docs/PLAN.md` (the plan of record).
British English. ASD-STE100. ASCII only.

Scope boundary: the existing marker behaviour stays unchanged. This plan adds
surfaces. It changes no marker value, no marker class, and no marker code path.

## 1. The design problem, and the decision

An addon config is compiled once. It is static. `CfgInGameUI/SideColors`,
`CfgInGameUI/MPTable`, `CfgInGameUI/IslandMap`, `CfgNotifications` and
`RscMapControl` are each a single fixed class name with fixed property names, so
only one value set can exist in config at a time. The marker trick, several
classes plus `setMarkerColorLocal`, does not exist for them. There is no script
command that sets a HUD side colour, a notification colour, or a map overlay
colour.

The vanilla config already solves this for some keys. `CfgInGameUI/IslandMap`
side colours and some `CfgNotifications` entries are written as
`(profilenamespace getvariable ['<NAME>',<default>])` expressions
(`10-colour-surface-dump.md` section 8). The engine evaluates the expression.
`getArray` returns the raw expression string, so a runtime profile change is not
observable through `getArray`. Whether the engine re-reads an expression live is
UNVERIFIED (`10-colour-surface-dump.md` section 9).

**Decision: option (c), a hybrid.** The mechanism is the profileNamespace
expression for every remapped key. The tier split is by value, not by
mechanism:

- **Per-mode tier.** The correct CVD-safe value depends on the deficiency type
  for a side-identity or status colour. A protanope needs the blue-amber axis.
  A tritanope needs the red-green axis. An achromatope needs luminance only. One
  value cannot serve all four, so these keys vary by mode.
- **Universal tier.** The key carries no CVD confusion pair in the same view. It
  needs a luminance separation only. No single hue is safe for all four
  deficiencies, so the universal value is a grey. One grey value set serves all
  four modes. These keys are mode-invariant.

**Why not option (a) alone.** A pure per-mode answer for every key would force a
mode-specific hue onto keys that carry no identity, and would multiply the
gated-pair count without an accessibility gain. It also claims a capability,
per-mode, that the unverified live re-read does not yet support.

**Why not option (b) alone.** A single universal palette is correct only where
the key has no confusion pair. Applied to `SideColors` and to the notification
status colours, it would show a protanope the tritan palette or the reverse. It
also throws away the per-mode capability that the marker work already proves.

**Why (c) is safe against a failed live re-read.** The mechanism is identical for
both tiers. If the engine does not re-read live, per-mode and universal fail
together, and no tier choice changes that. The plan therefore does not bet the
feature on the live re-read. It adds three guarantees that hold even in the worst
case: the variables are written before any display is built, they are persisted
with `saveProfileNamespace`, and a spike task records the evaluation timing so
the setting's `_needRestart` flag tells the truth (section 8).

**Rejected: a static concrete palette.** A concrete array in config is applied
unconditionally. Off must restore vanilla, and a static array cannot. Rejected.

**Rejected: a post-process or simulation filter.** `01-cvd-types.md` section 4
states the central error is a filter that simulates CVD. The mod remaps colours.
It does not filter.

## 2. The mechanism, exactly

For every remapped key, the config value becomes an array of per-channel string
expressions, in the shape the vanilla `IslandMap` already uses
(`10-colour-surface-dump.md` section 8). The alpha channel keeps the vanilla
literal, because alpha is not a CVD property.

```
class CfgInGameUI {
    class SideColors {
        colorFriendly[] = {
            "(profilenamespace getvariable ['A3ACC_Surf_SideColors_colorFriendly_R',0.709])",
            "(profilenamespace getvariable ['A3ACC_Surf_SideColors_colorFriendly_G',0.972])",
            "(profilenamespace getvariable ['A3ACC_Surf_SideColors_colorFriendly_B',0.384])",
            1
        };
    };
};
```

Rules:

1. The variable name is `A3ACC_Surf_<surface>_<key>_<R|G|B>`, where `<surface>`
   is `SideColors`, `Notifications`, `MPTable` or `IslandMap`, and `<key>` is the
   property name with any dot replaced by an underscore. For a
   `CfgNotifications` class the key is `<ClassName>_<property>`, for example
   `A3ACC_Surf_Notifications_TaskSucceeded_color_R`.
2. The expression default is the vanilla channel value, to four decimal places or
   fewer. When the addon has written nothing, the key behaves exactly as vanilla.
3. The property is written with the array suffix, for example `colorFriendly[]`.
   Every key in the dump holds an array. Task 1 confirms the spelling against the
   live config and the in-engine `getArray` assertion catches a mismatch.
4. A whole-array expression, for example
   `colorFriendly[] = (profilenamespace getvariable ['X',[0.709,0.972,0.384,1]]);`,
   is **not used**. It is unverified. Only the per-channel string form is
   confirmed.
5. The parent restatement rule applies to every reopened class
   (`05-aee-prior-art.md` section 3). A bare reopen of a class that has a parent
   strips inherited fields and logs `Updating base class '<parent>'->''`. A
   reopened parentless class must stay bare. Task 1 dumps the real parent of
   every reopened class with `inheritsFrom`, and the config restates it.

## 3. Palette data

### 3.1 Per-mode roles

The per-mode tier reuses the six existing marker roles and their exact values.
One palette per mode then drives the markers, the HUD, the scoreboard and the
notifications, so the same side is the same colour everywhere. Alpha is 1 except
where the key states otherwise.

| Role | Protan | Deutan | Tritan | Achromatopsia | Luminance P/D | Tritan | Achroma |
|---|---|---|---|---|---|---|---|
| friendly | 0.00, 0.35, 0.85, 1 | 0.00, 0.35, 0.85, 1 | 0.70, 0.00, 0.00, 1 | 0.98, 0.98, 0.98, 1 | 0.122 | 0.095 | 0.955 |
| enemy | 1.00, 0.70, 0.00, 1 | 1.00, 0.70, 0.00, 1 | 0.30, 0.90, 0.30, 1 | 0.25, 0.25, 0.25, 1 | 0.533 | 0.584 | 0.051 |
| neutral | 0.00, 0.80, 0.80, 1 | 0.00, 0.80, 0.80, 1 | 0.75, 0.75, 0.75, 1 | 0.56, 0.56, 0.56, 1 | 0.475 | 0.523 | 0.274 |
| unknown | 0.75, 0.75, 0.75, 1 | 0.75, 0.75, 0.75, 1 | 0.45, 0.45, 0.45, 1 | 0.56, 0.56, 0.56, 1 | 0.523 | 0.171 | 0.274 |
| civilian | 0.35, 0.35, 0.35, 1 | 0.35, 0.35, 0.35, 1 | 0.20, 0.20, 0.20, 1 | 0.98, 0.98, 0.98, 1 | 0.100 | 0.033 | 0.955 |
| objective | 1.00, 1.00, 1.00, 1 | 1.00, 1.00, 1.00, 1 | 1.00, 0.85, 0.00, 1 | 1.00, 1.00, 1.00, 1 | 1.000 | 0.708 | 1.000 |

Luminance is the WCAG 2.2 relative luminance, the method already in
`tests/verify_palette.py`. The `objective` role is unused by this slice. It stays
in the table because the marker function already carries it.

Design limit that shapes this slice: within one mode the role table supplies two
mutually 3:1 luminance tiers, not three. A mid value near 0.48 and a bright value
near 1.00 are only about 2:1 apart. A three-way mutually 3:1 set is therefore
impossible from these roles. Every surface below is built from cross-tier pairs
only, exactly as the marker palette is.

### 3.2 Universal values

No single hue is safe for all four deficiencies. The universal tier therefore
uses two greys, separated by luminance alone.

| Role | RGBA | Luminance |
|---|---|---|
| U_dark | 0.10, 0.10, 0.10, 1 | 0.010 |
| U_mid | 0.45, 0.45, 0.45, 1 | 0.171 |

The map background is `[0.969, 0.957, 0.949, 1]` with luminance 0.909
(`10-colour-surface-dump.md` section 6). Both greys stay legible on it and stay
3:1 apart from each other.

## 4. Keys to override, by surface

Every key below is taken from `10-colour-surface-dump.md`. No key is invented.
Alpha is the vanilla alpha and is written as a literal.

### 4.1 `CfgInGameUI/SideColors` - per-mode, 5 keys

The HUD and 3D icon side colours. This is the highest-value surface: vanilla
friendly is green and vanilla enemy is red, the classic protan and deutan
confusion pair.

| Key | Role | Protan | Deutan | Tritan | Achromatopsia |
|---|---|---|---|---|---|
| `colorFriendly` | friendly | 0.00, 0.35, 0.85 | 0.00, 0.35, 0.85 | 0.70, 0.00, 0.00 | 0.98, 0.98, 0.98 |
| `colorEnemy` | enemy | 1.00, 0.70, 0.00 | 1.00, 0.70, 0.00 | 0.30, 0.90, 0.30 | 0.25, 0.25, 0.25 |
| `colorNeutral` | neutral | 0.00, 0.80, 0.80 | 0.00, 0.80, 0.80 | 0.75, 0.75, 0.75 | 0.56, 0.56, 0.56 |
| `colorCivilian` | civilian | 0.35, 0.35, 0.35 | 0.35, 0.35, 0.35 | 0.20, 0.20, 0.20 | 0.98, 0.98, 0.98 |
| `colorUnknown` | unknown | 0.75, 0.75, 0.75 | 0.75, 0.75, 0.75 | 0.45, 0.45, 0.45 | 0.56, 0.56, 0.56 |

Alpha 1 for all five. Vanilla values for the Off restore:
`colorFriendly` 0.709, 0.972, 0.384. `colorEnemy` 0.706, 0.0745, 0.0196.
`colorNeutral` 0.606, 0.606, 0.606. `colorCivilian` 0.606, 0.606, 0.606.
`colorUnknown` 0.863, 0.584, 0.

Why remap at all, when vanilla already clears the floor: the vanilla pair
friendly against enemy is 5.45:1 by luminance, so it passes the 3:1 non-text
floor. It sits on the red-green hue axis. The remap keeps a luminance separation
at or above 3:1 and moves the hue off the confused axis. That is the accessibility
gain.

### 4.2 `CfgNotifications` - per-mode, 13 class properties

Status colours. Vanilla success is green and vanilla failure is red, and the
vanilla pair is only 2.73:1 by luminance, which is below the 3:1 floor. This
surface fails the floor today.

| Class | Property | Role | Protan | Deutan | Tritan | Achromatopsia |
|---|---|---|---|---|---|---|
| `TaskSucceeded` | `color` | friendly | 0.00, 0.35, 0.85 | 0.00, 0.35, 0.85 | 0.70, 0.00, 0.00 | 0.98, 0.98, 0.98 |
| `TaskSucceededIcon` | `color` | friendly | 0.00, 0.35, 0.85 | 0.00, 0.35, 0.85 | 0.70, 0.00, 0.00 | 0.98, 0.98, 0.98 |
| `ScoreAdded` | `color` | friendly | 0.00, 0.35, 0.85 | 0.00, 0.35, 0.85 | 0.70, 0.00, 0.00 | 0.98, 0.98, 0.98 |
| `TaskFailed` | `color` | enemy | 1.00, 0.70, 0.00 | 1.00, 0.70, 0.00 | 0.30, 0.90, 0.30 | 0.25, 0.25, 0.25 |
| `TaskFailedIcon` | `color` | enemy | 1.00, 0.70, 0.00 | 1.00, 0.70, 0.00 | 0.30, 0.90, 0.30 | 0.25, 0.25, 0.25 |
| `APTicketsGone` | `color` | enemy | 1.00, 0.70, 0.00 | 1.00, 0.70, 0.00 | 0.30, 0.90, 0.30 | 0.25, 0.25, 0.25 |
| `ArmoryGearAddingFailed` | `color` | enemy | 1.00, 0.70, 0.00 | 1.00, 0.70, 0.00 | 0.30, 0.90, 0.30 | 0.25, 0.25, 0.25 |
| `ArmoryInventoryFull` | `color` | enemy | 1.00, 0.70, 0.00 | 1.00, 0.70, 0.00 | 0.30, 0.90, 0.30 | 0.25, 0.25, 0.25 |
| `ArmoryMissingRequiredGear` | `color` | enemy | 1.00, 0.70, 0.00 | 1.00, 0.70, 0.00 | 0.30, 0.90, 0.30 | 0.25, 0.25, 0.25 |
| `TaskCanceled` | `color` | neutral | 0.00, 0.80, 0.80 | 0.00, 0.80, 0.80 | 0.75, 0.75, 0.75 | 0.56, 0.56, 0.56 |
| `TaskCanceledIcon` | `color` | neutral | 0.00, 0.80, 0.80 | 0.00, 0.80, 0.80 | 0.75, 0.75, 0.75 | 0.56, 0.56, 0.56 |
| `TaskAssignedIcon` | `colorIconPicture` | unknown | 0.75, 0.75, 0.75 | 0.75, 0.75, 0.75 | 0.45, 0.45, 0.45 | 0.56, 0.56, 0.56 |
| `CuratorAddAddons` | `color` | unknown | 0.75, 0.75, 0.75 | 0.75, 0.75, 0.75 | 0.45, 0.45, 0.45 | 0.56, 0.56, 0.56 |

Alpha 1 for all thirteen. Vanilla values for the Off restore, in row order:
0.7, 1, 0.3 / 0.7, 1, 0.3 / 0.5, 1, 1 / 1, 0.3, 0.2 / 1, 0.3, 0.2 / 1, 0.3, 0.2 /
0.8, 0, 0 / 0.8, 0, 0 / 0.8, 0, 0 / 0.7, 0.7, 0.7 / 0.7, 0.7, 0.7 / 1, 0.7, 0 /
1, 1, 0.4.

`Default` and `HubSysTemplate` are excluded. They use the profile-driven
`IGUI_TEXT_RGB_*` keys, so overriding them would change every notification text
in the game, not only a status colour.

### 4.3 `CfgInGameUI/MPTable` - per-mode, 1 key

| Key | Role | Protan | Deutan | Tritan | Achromatopsia | Vanilla |
|---|---|---|---|---|---|---|
| `colorWest` | friendly | 0.00, 0.35, 0.85 | 0.00, 0.35, 0.85 | 0.70, 0.00, 0.00 | 0.98, 0.98, 0.98 | 0.13, 0.41, 0.87 |

Alpha 1. This is the team colour in the multiplayer scoreboard.

### 4.4 `CfgInGameUI/IslandMap` - per-mode, 3 keys

| Key | Role | Protan | Deutan | Tritan | Achromatopsia | Alpha | Vanilla |
|---|---|---|---|---|---|---|---|
| `colorExplosive` | enemy | 1.00, 0.70, 0.00 | 1.00, 0.70, 0.00 | 0.30, 0.90, 0.30 | 0.25, 0.25, 0.25 | 1 | 1, 0, 0 |
| `colorExposureEnemy` | enemy | 1.00, 0.70, 0.00 | 1.00, 0.70, 0.00 | 0.30, 0.90, 0.30 | 0.25, 0.25, 0.25 | 0.5 | 1, 0.2, 0.2 |
| `colorExposureUnknown` | civilian | 0.35, 0.35, 0.35 | 0.35, 0.35, 0.35 | 0.20, 0.20, 0.20 | 0.98, 0.98, 0.98 | 0.5 | 0.8, 0.8, 0.2 |

The two exposure overlays are a pair and must never merge. They take the two
most separated tiers, the enemy tier and the civilian tier, so the pair clears
3:1 in every mode.

### 4.5 `CfgInGameUI/IslandMap` - universal, 11 keys

Map workflow overlays. They carry no side identity, so one grey value set serves
all four modes.

| Key | Value | Alpha | Vanilla |
|---|---|---|---|
| `colorPath` | U_dark 0.10, 0.10, 0.10 | 1 | 0, 1, 1 |
| `colorPathDone` | U_mid 0.45, 0.45, 0.45 | 0.8 | 0, 1, 0 |
| `colorSync` | U_dark 0.10, 0.10, 0.10 | 1 | 0, 0, 1 |
| `colorDetectorSync` | U_mid 0.45, 0.45, 0.45 | 1 | 0, 1, 0 |
| `colorGroups` | U_dark 0.10, 0.10, 0.10 | 0.5 | 0, 0.5, 0.5 |
| `colorActiveGroup` | U_mid 0.45, 0.45, 0.45 | 1 | 0, 1, 1 |
| `colorCamera` | U_dark 0.10, 0.10, 0.10 | 1 | 0.1, 0.1, 0.9 |
| `colorSensor` | U_dark 0.10, 0.10, 0.10 | 1 | 0.1, 0.1, 0.9 |
| `colorMissions` | U_mid 0.45, 0.45, 0.45 | 0.5 | 0.5, 0.5, 0 |
| `colorActiveMission` | U_dark 0.10, 0.10, 0.10 | 1 | 0, 0, 0 |
| `colorCheckpoints` | U_dark 0.10, 0.10, 0.10 | 1 | 0.2, 0.2, 0.2 |

The universal values are written identically for modes 1, 2, 3 and 4.

### 4.6 Contrast gates

Every pair that must be told apart, with the WCAG 2.2 relative-luminance ratio.
The floor is 3:1, the same floor as the existing verifier.

Per-mode pairs, ratio for Protan / Deutan / Tritan / Achromatopsia:

| Surface | Pair | Ratio | Verdict |
|---|---|---|---|
| SideColors | friendly vs enemy | 3.39 / 3.39 / 4.37 / 9.96 | pass |
| SideColors | neutral vs civilian | 3.49 / 3.49 / 6.89 / 3.10 | pass |
| SideColors | enemy vs civilian | 3.87 / 3.87 / 7.63 / 9.96 | pass |
| SideColors | friendly vs unknown | 3.33 / 3.33 / 1.52 / 3.10 | Tritan FAIL, see section 10 |
| Notifications | success vs failure | 3.39 / 3.39 / 4.37 / 9.96 | pass |
| Notifications | success vs cancelled | 3.06 / 3.06 / 3.94 / 3.10 | pass |
| IslandMap | exposureEnemy vs exposureUnknown | 3.87 / 3.87 / 7.63 / 9.96 | pass |

Universal pairs, one ratio each:

| Pair | Ratio | Verdict |
|---|---|---|
| U_dark vs U_mid | 3.68 | pass |
| U_dark vs map background 0.969, 0.957, 0.949 | 15.98 | pass |
| U_mid vs map background | 4.35 | pass |

Pairs deliberately not gated, with the reason:

- Notifications failure (enemy tier) vs cancelled (neutral tier) is 1.11 in
  Protan and Deutan and 1.11 in Tritan. Both values are on the mid tier. The
  status is also carried by the task name text, so colour is not the sole
  carrier, and the two hues sit on opposite sides of each mode's own axis.
- SideColors friendly vs unknown in Tritan is 1.52. This is a pre-existing gap in
  the marker palette, recorded in section 10. It is not fixed here, because a fix
  would change a verified marker value.
- Any pair where both values are on the mid tier, for example enemy vs neutral,
  is not gated. It is hue-separated on the mode's own axis.

## 5. Runtime apply path

### 5.1 New functions

| Function | File | Signature | Purity |
|---|---|---|---|
| `fnc_surfaceColourFor` | `addons/colourblind/functions/fnc_surfaceColourFor.sqf` | `[mode, key] -> RGBA` | pure |
| `fnc_applySurface` | `addons/colourblind/functions/fnc_applySurface.sqf` | `[mode] -> nothing` | impure |
| `fnc_applyAll` | `addons/colourblind/functions/fnc_applyAll.sqf` | `[mode] -> nothing` | impure |

`fnc_surfaceColourFor` is pure for the same reason `fnc_paletteForMode` is. It
reads only its arguments, writes nothing, and holds a `private` literal table. It
returns the vanilla value for mode 0, so Off is a true restore. It returns `[]`
for a key outside the list, for a mode below 0 or above 4.

Table shape inside `fnc_surfaceColourFor.sqf`, so the offline verifier can parse
it by the same regular expression it already uses:

```
private _keys = [ <33 key strings, fixed order> ];
private _vanilla = [ <33 RGBA literals, same order> ];
private _modes = [
    [ <33 RGBA literals> ],   // Protan
    [ <33 RGBA literals> ],   // Deutan
    [ <33 RGBA literals> ],   // Tritan
    [ <33 RGBA literals> ]    // Achromatopsia
];
```

165 RGBA literals in total: 33 vanilla plus 4 x 33.

`fnc_applySurface` does this, in order:

1. Clamp `_mode` to 0..4. A non-number becomes 0.
2. For each key in the fixed list, call `fnc_surfaceColourFor` and read the RGBA.
3. For each of R, G and B, call
   `profileNamespace setVariable [format ["A3ACC_Surf_%1_%2", _key, _channel], _value]`.
   The key string is the same string the config variable name is built from.
   A dot in the key becomes an underscore.
4. Write `profileNamespace setVariable ["A3ACC_CVDMode_Last", _mode]`.
5. Call `saveProfileNamespace` once, so the values survive to the next launch
   under the config-load-evaluation branch of section 8.
6. Write one `diag_log` line per call, at most once per session, with the mode and
   the key count. This is the receipt the Docker test reads.

`fnc_applyAll` calls `[mode] call fnc_applyMode` then
`[mode] call fnc_applySurface`. Marker behaviour is unchanged: `fnc_applyMode` is
not edited.

### 5.2 Changed wiring

| File | Change |
|---|---|
| `addons/colourblind/XEH_PREP.hpp` | add `PREP(surfaceColourFor)`, `PREP(applySurface)`, `PREP(applyAll)` |
| `addons/colourblind/initSettings.inc.sqf` | the 7th argument becomes `{ [_this] call A3ACC_colourblind_fnc_applyAll }` |
| `addons/colourblind/XEH_preStart.sqf` | add `[profileNamespace getVariable ["A3ACC_CVDMode_Last", 0]] call FUNC(applySurface)` |
| `addons/colourblind/config.cpp` | add `#include "CfgInGameUI.hpp"` and `#include "CfgNotifications.hpp"` |
| `addons/colourblind/CfgTests.hpp` | add `surface = QPATHTOF(test_surface.sqf);` |

`fnc_watch.sqf` is unchanged. It keeps calling `fnc_applyMode` every 2 seconds, so
the surface variables are not rewritten on every scan.

`XEH_preStart.sqf` currently holds only a comment. The write there runs before any
display is built, which covers the read-at-first-use branch of section 8.

### 5.3 How a mode change propagates to each surface

One path for every surface:

1. The player changes `A3ACC_CVDMode`.
2. CBA runs the 7th-argument script, which is `fnc_applyAll`.
3. `fnc_applyMode` recolours the map markers client-local, exactly as today.
4. `fnc_applySurface` writes 99 profile variables and one mode variable, then
   saves the profile.
5. The engine resolves each config expression to the new value when it next reads
   the key. The timing is the section 8 item.

Per-surface propagation:

| Surface | Read point | Mode change applies |
|---|---|---|
| `SideColors` | when the HUD and the 3D icons draw | live, or at the next mission, see section 8 |
| `CfgNotifications` | when a notification is created | at the next notification, always |
| `MPTable` | when the scoreboard display is built | at the next open, always |
| `IslandMap` | when the map is drawn | live, or at the next map open |
| markers | `setMarkerColorLocal`, immediate | immediate, unchanged |

The marker path stays client-local and unchanged. `fnc_applySurface` writes to
`profileNamespace`, which is per machine and per player, so it never reaches
another client.

## 6. Config files

### 6.1 `addons/colourblind/CfgInGameUI.hpp`

```
class CfgInGameUI {
    class SideColors {
        colorFriendly[] = { <3 expressions, default 0.709 / 0.972 / 0.384>, 1 };
        colorEnemy[]    = { <default 0.706 / 0.0745 / 0.0196>, 1 };
        colorNeutral[]  = { <default 0.606 / 0.606 / 0.606>, 1 };
        colorCivilian[] = { <default 0.606 / 0.606 / 0.606>, 1 };
        colorUnknown[]  = { <default 0.863 / 0.584 / 0>, 1 };
    };
    class MPTable {
        colorWest[] = { <default 0.13 / 0.41 / 0.87>, 1 };
    };
    class IslandMap {
        colorExplosive[]       = { <default 1 / 0 / 0>, 1 };
        colorExposureEnemy[]   = { <default 1 / 0.2 / 0.2>, 0.5 };
        colorExposureUnknown[] = { <default 0.8 / 0.8 / 0.2>, 0.5 };
        colorPath[]            = { <default 0 / 1 / 1>, 1 };
        colorPathDone[]        = { <default 0 / 1 / 0>, 0.8 };
        colorSync[]            = { <default 0 / 0 / 1>, 1 };
        colorDetectorSync[]    = { <default 0 / 1 / 0>, 1 };
        colorGroups[]          = { <default 0 / 0.5 / 0.5>, 0.5 };
        colorActiveGroup[]     = { <default 0 / 1 / 1>, 1 };
        colorCamera[]          = { <default 0.1 / 0.1 / 0.9>, 1 };
        colorSensor[]          = { <default 0.1 / 0.1 / 0.9>, 1 };
        colorMissions[]        = { <default 0.5 / 0.5 / 0>, 0.5 };
        colorActiveMission[]   = { <default 0 / 0 / 0>, 1 };
        colorCheckpoints[]     = { <default 0.2 / 0.2 / 0.2>, 1 };
    };
};
```

Each `<...>` is the three-line per-channel expression block of section 2.
`CfgInGameUI`, `SideColors`, `MPTable` and `IslandMap` are parentless vanilla
classes, so they are reopened bare. Task 1 confirms that with `inheritsFrom`. If
the dump shows a parent, restate it.

### 6.2 `addons/colourblind/CfgNotifications.hpp`

```
class CfgNotifications {
    class TaskSucceeded: <parent> { color[] = { <3 expressions>, 1 }; };
    // one line per class of section 4.2, in the same order
};
```

`<parent>` is the value the Task 1 dump returns from
`configName (inheritsFrom (configFile >> "CfgNotifications" >> "<class>"))`. When
the dump returns the class itself or a null config, reopen the class bare.
Restating a wrong parent rebases the class and is the defect this rule prevents.

## 7. Test additions

### 7.1 `tests/verify_palette.py` - offline gate

New constants:

```
SURFACE_FUNCTION = ROOT / "addons" / "colourblind" / "functions" / "fnc_surfaceColourFor.sqf"
IGUI_CONFIG      = ROOT / "addons" / "colourblind" / "CfgInGameUI.hpp"
NOTIF_CONFIG     = ROOT / "addons" / "colourblind" / "CfgNotifications.hpp"

SURFACE_KEYS = [ <the 33 keys of section 4, in the fixed order> ]
SURFACE_ROLE = { <key>: <role or "U_dark" or "U_mid">, for all 33 }
SURFACE_ALPHA = { <key>: <vanilla alpha>, for the 14 keys whose alpha is not 1> }
UNIVERSAL = {"U_dark": (0.10, 0.10, 0.10, 1), "U_mid": (0.45, 0.45, 0.45, 1)}
MAP_BACKGROUND = (0.969, 0.957, 0.949, 1)
SURFACE_GATED_PAIRS = [ <the 7 per-mode pairs of section 4.6> ]
UNIVERSAL_GATED_PAIRS = [ ("U_dark", "U_mid"), ("U_dark", "MAP_BACKGROUND"),
                          ("U_mid", "MAP_BACKGROUND") ]
VARIABLE_RE = re.compile(r"A3ACC_Surf_([A-Za-z0-9_]+)_(R|G|B)")
EXPRESSION_RE = re.compile(
    r"\(profilenamespace getvariable \['(A3ACC_Surf_[A-Za-z0-9_]+_[RGB])',([0-9.]+)\)\]"
)
```

New gate functions:

1. `parse_surface_function()`. Read `fnc_surfaceColourFor.sqf`. Count the RGBA
   literals. Require exactly 165. Require 33 key strings. Return
   `vanilla[key]`, `modes[mode][key]`.
2. `parse_surface_config()`. Read `CfgInGameUI.hpp` and `CfgNotifications.hpp`.
   For every property, extract the three expression tuples and the alpha literal
   with `EXPRESSION_RE` and a sibling alpha pattern. Return
   `{(surface, key): (var_r, var_g, var_b, default_r, default_g, default_b, alpha)}`.
3. `main()` gains five new gates:
   - **Gate 4, key coverage.** The key set in the config equals `SURFACE_KEYS`.
     A missing key or an extra key fails.
   - **Gate 5, variable name and default.** For every key, the config variable
     names equal `A3ACC_Surf_<surface>_<key>_<R|G|B>` and the expression default
     equals the `vanilla` entry from the function. A drift between the two copies
     fails.
   - **Gate 6, alpha.** The config alpha literal equals the vanilla alpha of the
     dump, per key.
   - **Gate 7, role sync.** For every per-mode key, the function value for each
     mode 1..4 equals `parse_function()[mode][SURFACE_ROLE[key]]`. For every
     universal key, the function value is identical in modes 1..4 and equals
     `UNIVERSAL[SURFACE_ROLE[key]]`. This is the marker-to-surface sync gate.
   - **Gate 8, contrast.** Recompute every pair of `SURFACE_GATED_PAIRS` for every
     mode and every pair of `UNIVERSAL_GATED_PAIRS`. Require 3.0. Print the ratio
     table in the existing format.
   - **Gate 9, Off restore.** For every key, the function value for mode 0 equals
     the `vanilla` entry, and the config default equals the same value.
4. The pass line becomes:
   `[verify_palette] PASS: 24 function entries, 20 config classes in sync, 33 surface keys in sync, every gated pair clears 3:1`.

The verifier keeps exit code 0 as the only success. The CI step of
`docs/PLAN.md` section 7.6 item 6 already runs it, so no CI change is needed.

### 7.2 Docker in-engine test

New file `addons/colourblind/test_surface.sqf`, registered in `CfgTests.hpp`.
Assertions:

1. For every one of the 33 keys, the config entry exists. `TEST_TRUE` that
   `!isNull (configFile >> <path>)`, where the path is
   `CfgInGameUI >> SideColors >> colorFriendly`, `CfgNotifications >>
   TaskSucceeded >> color`, and so on.
2. For every key, `TEST_TRUE` that `count (getArray (_class >> _property)) == 4`.
   This also catches the file-root forward-declaration trap.
3. For every key, `TEST_TRUE` that each of the first three elements of
   `getArray` is a `STRING`, and that the string contains
   `profilenamespace getvariable`. A concrete array means the override did not
   take.
4. For every key, `TEST_TRUE` that `compile (_array select 0)` evaluates to a
   number in 0..1. Use `call compile` inside a `TEST_TRUE`, or compare
   `call compile (_array select 0)` against the expected channel. This proves the
   expression resolves through the profile variable inside the real engine.
5. For every mode 1..4: call `[mode] call A3ACC_colourblind_fnc_applySurface`,
   then for every key `TEST_OP` that
   `profileNamespace getVariable ["A3ACC_Surf_<surface>_<key>_R", -1]` equals the
   function value for that mode. This is the write-path gate.
6. For mode 0: call `[0] call A3ACC_colourblind_fnc_applySurface`, then `TEST_OP`
   that every profile variable equals the vanilla default from the config. This is
   the Off restore gate.
7. `TEST_OP(profileNamespace getVariable ["A3ACC_CVDMode_Last", -1], ==, 0, "mode
   variable restored")`.
8. `TEST_TRUE` that `RscStructuredText` still resolves, and that the existing
   `test_config.sqf` assertions still pass unchanged. The marker suite is
   untouched.

New file `tests/ingame/missions/a3acc_test.Stratis/surface_probe.sqf`, `execVM`ed
from `init.sqf` after the CBA suite. It writes one `[A3ACC-SURF] <key> <mode>
<PASS|FAIL>` line per key per mode, so a failure names the key.

`tests/ingame/verify.py` gains two rules:

- Require the line `[A3ACC-SURF] DONE`.
- Fail on any line that contains `[A3ACC-SURF]` and `FAIL`.
- Add `Updating base class` to the failure list, alongside the existing `Error`
  rule. A parent restatement defect must fail the tier.

### 7.3 Manual client QA

The Docker harness is a dedicated server. It has no HUD, no map display and no
notification popup. The rendered result and the read timing are client-only.
Add these steps to `docs/QA-colourblind.md`:

1. Launch with `hemtt launch`. Set mode Protan. Open the map. Confirm the side
   colours, the exposure overlays and the workflow overlays changed.
2. Confirm the HUD 3D friendly and enemy icons changed.
3. Fire a task-succeeded and a task-failed notification. Confirm the two colours
   differ by more than hue alone.
4. Open the multiplayer scoreboard. Confirm the team colour changed.
5. Change the mode to Tritan while the map is open. Record whether the map
   recoloured live or only on reopen. This is the section 8 measurement.
6. Change the mode to Achromatopsia. Confirm the surfaces are greyscale.
7. Set Off. Confirm every surface returns to the vanilla colour, and confirm the
   map workflow overlays are back to cyan, green and blue.
8. Check the RPT for `Error` and for `Updating base class`. Both must be absent.
9. View each mode through a CVD simulator and confirm the gated pairs stay
   distinct.

## 8. The one unverified mechanism, and the pre-decided branches

`10-colour-surface-dump.md` section 9 states that whether the engine re-reads a
config expression after a runtime change is UNVERIFIED. Task 2 is a spike that
records the answer. The response is pre-decided, so the worker makes no judgement
call.

| Spike result | What the worker does |
|---|---|
| The engine re-reads per read or per draw | Nothing. Ship as designed. Keep `_needRestart = false`. |
| The engine re-reads when the UI is built | Nothing in code. Document in `README.md` and `ACCESSIBILITY.md` that a mid-mission change applies when the surface is next built, and that the HUD applies at the next mission. Keep `_needRestart = false`. |
| The engine reads the expression only at config load | Set `_needRestart = true` in `initSettings.inc.sqf`. Document that a mode change applies at the next game launch. The `saveProfileNamespace` call of section 5.1 already makes the next launch correct. |

The design is identical in all three cases. Only the documentation and the
`_needRestart` flag change. That is why the plan can be decision complete without
the answer.

## 9. Risk of breaking the game, by surface

| Surface | Failure mode | Blast radius | Mitigation | Detection |
|---|---|---|---|---|
| `SideColors` | a malformed expression makes a HUD icon colour resolve to 0, so the icon draws black or invisible | HUD and 3D icons for one side | the expression default is the vanilla value, so an unset variable is vanilla. In-engine assertion 4 resolves every expression | `test_surface.sqf` assertion 4, RPT check, QA step 2 |
| `CfgNotifications` | a wrong parent rebases a notification class and strips its inherited fields | one notification type loses its icon or duration | Task 1 dumps the real parent. `Updating base class` is a hard failure in `verify.py` | `verify.py`, QA step 8 |
| `MPTable` | a malformed expression makes the scoreboard team colour resolve to 0 | the scoreboard team row colour | one key only. Vanilla default in the expression | assertion 4, QA step 4 |
| `IslandMap` | a malformed expression makes a map overlay resolve to 0, or a grey overlay is invisible on the light map | map overlays and the exposure tint | both greys are gated at or above 3:1 against the map background. Alpha is preserved | universal gates of section 4.6, QA step 1 |
| markers | none. No marker value, class or code path changes | none | the marker function and `fnc_applyMode` are not edited | the existing `test_palette.sqf`, `test_config.sqf` and `test_setting.sqf` run unchanged |

Compatibility risk, stated once for every overridden key. `getArray` on an
overridden key returns four strings instead of four numbers, because that is how
the vanilla `IslandMap` and `IGUI_TEXT_RGB_*` keys already behave. A third-party
addon that calls `getArray` on one of these keys and expects numbers would see
strings. The affected keys are the 33 in section 4. The exposure is bounded: the
engine resolves the expressions, the vanilla config already uses the same shape,
and disabling the addon restores the vanilla concrete arrays.

## 10. Excluded surfaces and keys, and why

| Surface or key | Why it is excluded |
|---|---|
| `RscMapControl` terrain: `colorBackground`, `colorOutside`, `colorSea`, `colorForest`, `colorRocks`, `colorCountlines`, `colorMainCountlines`, `colorCountlinesWater`, `colorMainCountlinesWater`, `colorPowerLines`, `colorRailWay`, `colorLevels`, `colorInactive` | `10-colour-surface-dump.md` section 6 states these are art, not side identity, and that changing them is the highest risk of breaking the game. A CVD user gains nothing from a recoloured sea. |
| `RscMapControl` `colorText`, `colorNames` | map label text on a light map. The vanilla values are already dark and already clear the floor. A per-mode change could only make the map harder to read. |
| `CfgInGameUI/MPTable` `color`, `colorBg`, `colorBgAlt`, `colorCaptionBg`, `colorTitleBg`, `colorSelected` | backgrounds and the white scoreboard text. There is no CVD confusion pair. White on black already clears the floor. |
| `CfgInGameUI/SquadRadar` `friendlyUnitColor`, `enemyUnitColor`, `taskIconColor`, `colorBackground` | every vanilla value has alpha 0, so the colour is invisible. A remap has no visible effect, and raising the alpha would change visibility, which is not a colour remap. |
| `CfgNotifications` `Default`, `HubSysTemplate` | both use the profile-driven `IGUI_TEXT_RGB_*` keys. Overriding them changes all notification text, not a status colour. |
| `CfgInGameUI/IslandMap` `colorMe`, `colorPlayable`, `colorNonPlayable` | a three-way unit-identity set cannot be gated. Section 3.1 gives only two mutually 3:1 tiers per mode, so at most two of the three pairs clear the floor. The map markers already carry unit identity. |
| `CfgInGameUI/IslandMap` `colorSelect`, `colorDragging`, `colorInfoMove`, `colorInactive`, `colorLabelBackground` | selection, drag ghost, move ghost, fade-out and label background. No CVD confusion pair, and several carry a non-opaque alpha that makes a luminance gate meaningless. |
| `CfgInGameUI/IslandMap` side colours, the profile-driven `colorEnemy`-style keys | the key names and the profile variable names are not confirmed. The dump names only `colorEnemy` and the variable `Map_OPFOR_R`. These keys are also the game's own map-colour options, so writing them would fight the player's own preference and would need record-and-restore of variables outside the addon's namespace. Follow-up: dump every expression and its variable name, then decide. |
| `CfgMarkerColors` | already covered by the addon. Unchanged by this slice. |
| `PlayerColors` | `10-colour-surface-dump.md` section 8 states these are procedural textures, not RGBA arrays. Not remappable as colour. |

Residual risk carried forward:

- SideColors friendly vs unknown is 1.52:1 in Tritan. The gap comes from the
  verified marker palette and is not fixed in this slice.
- Notifications failure vs cancelled is 1.11:1 in Protan and Deutan. The status
  text is the second carrier.
- Alpha compositing is not gated. The gate uses RGB only, as the existing
  verifier does. A key with alpha 0.5 composites towards the map background, so
  its effective contrast is lower than the printed ratio.

## 11. Files to add and to change

Add:

```
addons/colourblind/functions/fnc_surfaceColourFor.sqf   pure, [mode, key] -> RGBA
addons/colourblind/functions/fnc_applySurface.sqf       impure, writes 99 profile variables
addons/colourblind/functions/fnc_applyAll.sqf           impure, markers plus surfaces
addons/colourblind/CfgInGameUI.hpp                      SideColors, MPTable, IslandMap
addons/colourblind/CfgNotifications.hpp                 13 status colours
addons/colourblind/test_surface.sqf                     in-engine assertions on the new surface
tests/ingame/missions/a3acc_test.Stratis/surface_probe.sqf   per-key per-mode probe lines
```

Change:

```
addons/colourblind/config.cpp          include the two new hpp files
addons/colourblind/XEH_PREP.hpp        PREP the three new functions
addons/colourblind/XEH_preStart.sqf    apply the persisted mode before any display
addons/colourblind/initSettings.inc.sqf  hook becomes fnc_applyAll
addons/colourblind/CfgTests.hpp        register test_surface.sqf
tests/verify_palette.py                gates 4 to 9 of section 7.1
tests/ingame/verify.py                 SURF DONE rule, SURF FAIL rule, parent rule
tests/ingame/missions/a3acc_test.Stratis/init.sqf  execVM the surface probe
docs/QA-colourblind.md                 the nine client steps of section 7.3
docs/PLAN.md                           record this slice as the successor
README.md                              one sentence on the wider surface, no table
ACCESSIBILITY.md                       the per-surface limitation of section 8
```

Not changed: `addons/main/`, `fnc_paletteForMode.sqf`, `fnc_colourNameFor.sqf`,
`fnc_applyMode.sqf`, `fnc_watch.sqf`, `CfgMarkerColors.hpp`,
`CfgStructuredText.hpp`, `.github/workflows/ci.yml`.

## 12. Todos

- [ ] 1. Dump the engine parents, the property spellings and the IslandMap expressions.
  - Acceptance: one RPT block records, for each of the 13 `CfgNotifications` classes and for `CfgInGameUI`, `SideColors`, `MPTable` and `IslandMap`, the line `[A3ACC-DUMP] <path> parent=<configName (inheritsFrom ...)>`. It also records every property name under `CfgInGameUI/SideColors`, `MPTable` and `IslandMap` from `configProperties`, and the raw value of every profile-driven `IslandMap` expression. The parent for each notification class is a single token, or the class name itself when there is no parent.
  - QA: run the probe under `tests/ingame/run.sh` and read the RPT. Evidence is the dumped block in `tests/ingame/run.log`.
  - Commit: `colourblind: dump the engine parents and colour property names`.
- [ ] 2. Spike the expression read timing.
  - Acceptance: one recorded measurement states which of the three rows of section 8 holds, with the observation that proves it: set a profile variable, then read the surface, and record whether the change appears per read, per UI build, or only after a restart. The measurement names the surface it used.
  - QA: the client steps 1, 5 and 7 of section 7.3. Evidence is the written measurement in `docs/QA-colourblind.md`.
  - Commit: `docs: record the config expression read timing`.
- [ ] 3. Write the pure surface function.
  - Acceptance: `fnc_surfaceColourFor.sqf` returns the exact value of section 4 for every one of the 33 keys and every mode 1..4, the vanilla value for mode 0, and `[]` for an unknown key or a mode outside 0..4. It reads no global and no config. The file holds exactly 165 RGBA literals and 33 key strings in the fixed order.
  - QA: `python3 tests/verify_palette.py` reports the new key count once gate 4 is added, and the function passes the SQF-VM include path check.
  - Commit: `colourblind: add the pure colour-surface palette`.
- [ ] 4. Write the surface apply path.
  - Acceptance: `fnc_applySurface` writes all 99 profile variables and `A3ACC_CVDMode_Last`, then calls `saveProfileNamespace` once. `fnc_applyAll` calls `fnc_applyMode` then `fnc_applySurface`. `fnc_applyMode` is byte-identical to today.
  - QA: in the debug console, `[1] call A3ACC_colourblind_fnc_applyAll` then `profileNamespace getVariable ["A3ACC_Surf_SideColors_colorFriendly_R", -1]` returns `0`. Evidence is the console output.
  - Commit: `colourblind: write the colour-surface profile variables`.
- [ ] 5. Add `CfgInGameUI.hpp` with the 19 keys of sections 4.1, 4.3, 4.4 and 4.5.
  - Acceptance: 19 properties exist. Each holds three per-channel expressions whose defaults equal the vanilla channel values of section 4, and one alpha literal equal to the vanilla alpha. Each class restates the parent the dump returned, or is reopened bare when the dump shows no parent. No key outside the dump is present.
  - QA: `hemtt check -p -e` exits 0 with no `L-C03` and no `L-C04`. Evidence is the CI log.
  - Commit: `colourblind: remap the HUD, scoreboard and map colours`.
- [ ] 6. Add `CfgNotifications.hpp` with the 13 status colours of section 4.2.
  - Acceptance: 13 class properties exist, each with three per-channel expressions and alpha 1. Every class restates its dumped parent. The RPT carries no `Updating base class` line.
  - QA: `hemtt check -p -e` is clean, and the in-engine suite reports no `Updating base class`. Evidence is the CI log and the RPT.
  - Commit: `colourblind: remap the notification status colours`.
- [ ] 7. Wire the new files and the setting hook.
  - Acceptance: `config.cpp` includes both new headers. `XEH_PREP.hpp` lists the three functions. `XEH_preStart.sqf` applies the persisted mode. The setting's 7th argument calls `fnc_applyAll`. `fnc_watch` still calls `fnc_applyMode`.
  - QA: `hemtt build` succeeds and the setting appears in Eden under `A3 Accessibility`. Evidence is a screenshot and the build log.
  - Commit: `colourblind: wire the colour-surface apply path`.
- [ ] 8. Extend `tests/verify_palette.py` with gates 4 to 9.
  - Acceptance: the verifier parses 165 function literals and 33 config keys, checks the variable names and the expression defaults, checks the role sync against the marker function, checks the alpha literals, recomputes every per-mode and universal pair at or above 3:1, and checks the mode 0 restore. A single changed channel in either copy fails the run.
  - QA: `python3 tests/verify_palette.py` exits 0 and prints the ratio table. Then change one channel in the config and confirm exit 1. Evidence is both outputs.
  - Commit: `tests: gate the whole colour surface offline`.
- [ ] 9. Extend the in-engine suite and the Docker verifier.
  - Acceptance: `test_surface.sqf` makes the eight assertion groups of section 7.2. `surface_probe.sqf` writes one line per key per mode. `tests/ingame/verify.py` requires `[A3ACC-SURF] DONE`, fails on any `[A3ACC-SURF] ... FAIL`, and fails on `Updating base class`.
  - QA: `tests/ingame/run.sh` exits 0, and a deliberate break of one channel makes it exit 1. Evidence is `tests/ingame/run.log` and the exit codes.
  - Commit: `colourblind: assert the colour surface in the engine`.
- [ ] 10. Update the documentation.
  - Acceptance: `docs/QA-colourblind.md` holds the nine client steps and the section 8 measurement. `README.md` carries one sentence about the wider surface and no table. `ACCESSIBILITY.md` carries the per-surface limitation. `docs/PLAN.md` records this slice as the successor.
  - QA: a second person runs the client checklist without asking a question. Evidence is the completed checklist.
  - Commit: `docs: record the colour-surface modes and their limits`.

## 13. Final verification wave

- [ ] F1. Recompute every contrast gate from the live engine. In the Docker suite, read each surface value from `configFile`, resolve the expression, recompute the WCAG ratio for every pair of section 4.6, and require 3:1. No ratio may come from a comment.
- [ ] F2. Prove the marker suite is unchanged. Run `test_palette.sqf`, `test_config.sqf` and `test_setting.sqf` and confirm zero failures, with `fnc_paletteForMode.sqf`, `fnc_colourNameFor.sqf`, `fnc_applyMode.sqf`, `fnc_watch.sqf` and `CfgMarkerColors.hpp` byte-identical to the state before this slice.
- [ ] F3. Prove the Off restore for every surface. Set mode 1, then Off, and confirm every one of the 99 profile variables returns to its vanilla default and every config expression resolves to the vanilla value.
- [ ] F4. Prove the RPT is clean. No `Error`, no `Updating base class`, and no warning outside the benign allowlist of `tests/ingame/verify.py`.
- [ ] F5. Prove the offline and in-engine tiers agree. The 33 keys, the 99 variable names and the expression defaults in `tests/verify_palette.py` must equal what `test_surface.sqf` reads from `configFile`. A drift between the two gates must fail one of them.

## 14. Acceptance criteria for the slice

1. `hemtt check -p -e` and `hemtt build` pass on Linux.
2. `python3 tests/verify_palette.py` exits 0, with the 24 marker entries, the 20 marker classes, the 33 surface keys and every gated pair in sync.
3. `tests/ingame/run.sh` exits 0, with no `[A3ACC-SURF] ... FAIL` line and no `Updating base class` line.
4. Every one of the 33 keys holds three per-channel profile expressions whose defaults equal the vanilla channel values.
5. A mode change writes all 99 profile variables, and Off restores all 99 to vanilla.
6. The four modes each recolour all five `SideColors` keys, all 13 notification status colours, the scoreboard team colour and the map exposure overlays.
7. Every gated pair of section 4.6 meets 3:1 in every mode it is gated for.
8. The marker suite passes unchanged, and no marker file changed.
9. `CfgInGameUI` and `CfgNotifications` reopen every class with the correct parent, or bare when the class has no parent.

## 15. UNVERIFIED, and what must be checked first

1. Whether the engine re-reads a config expression after a runtime profile
   change, and at which point. `10-colour-surface-dump.md` section 9. Task 2
   measures it. The design is identical in all three outcomes.
2. The real parent of each `CfgNotifications` class. Task 1 dumps it. A wrong
   parent rebases the class and logs `Updating base class`.
3. Whether `CfgInGameUI`, `SideColors`, `MPTable` and `IslandMap` are parentless.
   Task 1 dumps it. A parentless class must stay bare.
4. Whether an array property is spelled `colorFriendly[]` or `colorFriendly` in
   the vanilla `CfgInGameUI`. Task 1 dumps the property names, and in-engine
   assertion 1 catches a mismatch.
5. Whether the notification background colour is light or dark. The dump does not
   give it, so a text-legibility gate against the background is not possible. The
   manual QA step covers it.
6. The key names and the profile variable names of the profile-driven `IslandMap`
   side colours. The dump names only `colorEnemy` and `Map_OPFOR_R`. These keys
   are excluded from this slice.
7. Whether `saveProfileNamespace` is needed for the next launch to see the
   variables. Task 2 records whether the values survive a restart without it. The
   plan calls it once per mode change regardless.
8. Whether `profileNamespace` writes are cheap enough to run once per mode
   change. Expected to be, at 100 variables. Measure in the spike.
9. The rendered result of any surface change. `03-testing.md` section 2 states the
   rendered pixel is not observable to an automated test. The manual QA step is
   the only check.

## 16. Must NOT have

- No post-process, no simulation filter, no colour matrix.
- No change to any marker value, marker class, marker function or marker test.
- No override of `RscMapControl`, of any terrain colour, or of any `RscDisplay*`.
- No change to `CfgInGameUI/MPTable` backgrounds, to `SquadRadar`, or to the
  profile-driven `IGUI_TEXT_RGB_*` keys.
- No new key, class or property outside `10-colour-surface-dump.md`.
- No `setMarkerColor` global call, and no write that reaches another client.
- No table in `README.md`.
- No high-contrast mode, no stringtable, and no feature outside the colour
  surface. The wider roadmap of `docs/PLAN.md` section 12 stays unplanned.
