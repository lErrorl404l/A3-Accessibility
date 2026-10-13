# What else is available: the remaining levers

Method: mine the two sources no earlier note used, then check every candidate
against the roadmap and against the corpus.

1. The identifier strings in `arma3_x64.exe`. `strings -n 4` filtered to
   `^[a-z][a-zA-Z0-9_]{3,28}$` gives 15011 candidates. A command name, a config
   property name and a mission variable name all appear here, so the list has
   false positives and each hit needs a second source.
2. The property names across the 1432 shipped configs, counted by how often they
   are declared.

## New: steady indicator lights

The config property `blinking` is declared 209 times in the shipped configs. No
plan or note in this repository mentioned it before this note.

| Fact | Value |
|---|---|
| Declarations | 209: `CfgVehicles` 183, `CfgLights` 25, `CfgAmmo` 1 |
| Value | 180 state `blinking = 0`, 29 state `blinking = 1` |
| Companions | `blinkingPattern` 80, `blinkingPatternGuarantee` 14, `blinkingPeriod` 3 |
| Classes that blink | `Light_lock_1` to `Light_lock_7`, `Light1`, `Light_1`, `NVGMarker01`, `CollisionLightWhite1`, `PositionRed` |

So the strobing surfaces are the cockpit lock warning, the exterior position and
collision lights, and the NVG markers. A strobe is the photosensitivity trigger,
and a steady light is not.

Open question for a probe: `blinking = 0` should leave the light lit and steady,
but it might leave it dark. The warning cue must survive, so the probe comes
first. `tests/ingame` can settle the property, and the rendered light needs a
client.

## The roadmap's planned mechanisms are real

Every mechanism the roadmap plans on is a literal command name in the engine, so
the plan is buildable and not speculative:

| Group | Mechanisms checked | Found in `arma3_x64.exe` |
|---|---|---|
| MP2, MP5, MP6 | `setAperture`, `setApertureNew`, `camSetFov`, `setCustomAimCoef` | yes |
| MP1 | `enableCamShake`, `resetCamShake`, `setCamShakeDefParams` | yes |
| MP3, MP4 | `ColorCorrections`, `FilmGrain`, `DynamicBlur`, `RadialBlur`, `ChromAberration`, `WetDistortion` | yes |

## Candidates that need a probe

These are in the engine and are not in the roadmap. None is used by a shipped
script, so the semantics are not settled by the corpus.

| Candidate | Domain | Why it might help | Next step |
|---|---|---|---|
| `disableSoundAttenuation` | hearing | Sounds lose volume with distance and through a vehicle. A hard-of-hearing player may hear more without that attenuation | `G-PROBE` on what it changes, then a client listen. It may also flatten the direction cue, which would be a loss |
| `disableDriverAttenuation` | hearing | The attenuation applied when the player is inside a vehicle | the same |
| `setLightFlareSize` | photosensitivity | A light's flare is glare. Vanilla uses it on a laser in `Firing_Drills/laser.sqf`, so the call shape is known. It is per light, so it needs a loop over nearby lights | `G-PROBE`, then a client look |
| `setCamShakeParams` | motion | Tune the shake instead of switching it off | low value: the addon already offers off |

## Checked and rejected

Recorded so the space stays bounded and the same candidates are not re-examined.

| Candidate | Why it is not a lever |
|---|---|
| `setHUDMovementLevels` | The name suggests motion, but `BIS_fnc_HUDLimits` uses it for the HUD's speed, altitude and direction limit markers. Not motion sensitivity |
| `radioVolume` | Not an engine command. A shipped mission reads it as a mission variable set by an Eden attribute |
| `enableZoom`, `hideCursor`, `hideActions` | State switches for a scripted sequence, not accessibility levers |
| `IGUI_TACTPING_RGB` | Does not exist. See `17-dynamic-variable-layer.md` |
| `blinkingPattern` as a separate item | Part of the same surface as `blinking`, not a second one |

## What is left overall

Most of what remains is already written down in `docs/PLAN-accessibility.md`: an
eighth component for the flash, exposure, post-process and blur work (MP2 to
MP4), the hearing caption line and its styling (H2 to H4), text size and the
dyslexia font (LV1, LV5), view distance (LV3), the cognitive prompts (C3 to C5),
and the motor targets and holds (M2, M3). This note adds one further item, the
steady indicator lights, which the roadmap did not have.
