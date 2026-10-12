# Verified command capability for non-colour accessibility

Method: a mission calls each candidate command inside `try`/`catch` and logs the
exception. An empty exception means the engine accepted the command and its
arguments. Run on a real Arma 3 2.20 dedicated server through `tests/ingame`.

All 32 candidates were accepted. **Existence is verified. Semantics and the
rendered result are not** - those need a client test.

## Confirmed available

| Area | Commands |
|---|---|
| Camera shake | `enableCamShake`, `setCamShakeDefParams`, `setCamShakeParams`, `addCamShake`, `resetCamShake` |
| Brightness and exposure | `setAperture`, `setApertureNew` |
| Post-process | `ppEffectCreate`, `setPiPEffect` |
| HUD | `showHUD`, `setGroupIconsVisible`, `setGroupIconsSelectable`, `disableMapIndicators` |
| Markers | `setMarkerSize`, `setMarkerAlpha` |
| Motor | `forceWalk`, `allowSprint`, `setCustomAimCoef` |
| View | `setViewDistance`, `setObjectViewDistance`, `setTerrainGrid` |
| Audio | `playSound3D`, `createSoundSource`, `addMusicEventHandler`, `setSpeaker`, `setSoundVolume` |
| Character | `setFatigue`, `setAnimSpeedCoef`, `enableStressDamage` |
| Environment | `enableEnvironment` |
| UI | `ctrlSetFont` |

## What each could support

- **Motion sensitivity:** `enableCamShake`, `setCamShakeDefParams` and
  `setCamShakeParams` can reduce or remove camera shake, the main cause of motion
  discomfort in Arma.
- **Photosensitivity:** `ppEffectCreate` can build a colour-correction or bloom
  effect, and `setAperture`/`setApertureNew` control exposure.
- **Low vision:** `setMarkerSize`, `setMarkerAlpha`, `setViewDistance` and
  `setObjectViewDistance` change how legible the world and the map are.
- **Motor:** `forceWalk`, `allowSprint` and `setCustomAimCoef` change the demand
  on the player's hands, but they are gameplay levers, not input remapping. Arma
  exposes no command to add a toggle for a held key.
- **Hearing:** the audio commands can play and position sound, but the engine
  exposes no command to read a sound event. A directional sound indicator must
  therefore be built from gameplay events (`FiredNear`, `Explosion`,
  `Hit`, nearby entities), not from the audio mixer.

## Limitation found

`BIS_fnc_showSubtitle` was probed but is a variable reference, not a command, so
the probe proves nothing about it. Captions need a different mechanism.

## UNVERIFIED

- The semantics and safe ranges of every command above.
- Whether any of them is client-only and therefore inert on a dedicated server.
- The rendered result of any setting.
