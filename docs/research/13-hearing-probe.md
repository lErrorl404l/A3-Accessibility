# Probe results: hearing mechanisms

Method: a mission on a real Arma 3 2.20 dedicated server registered the hearing
event handlers, fired a scripted shot between two spawned units, and called the
subtitle commands. Run through `tests/ingame`.

## Results

| Mechanism | Result | Meaning |
|---|---|---|
| `addEventHandler ["FiredNear", ...]` | **No event** | The handler registered but did not fire on a scripted `doFire`. The directional-cue feature is not proven. UNVERIFIED |
| `addEventHandler ["Explosion", ...]` | **No event** | No explosion occurred, so this is untested rather than failed |
| `RscDynamicText` class | **Does not exist** | The planned subtitle-restyle mechanism is wrong. `BIS_fnc_showSubtitle` does not cut this class |
| `RscTitles` class | Exists | An addon caption display can inherit it |
| `showSubtitles true` | Works | Returns the prior value |
| `shownSubtitles` | Works | Reports the current state |
| `getSubtitleOptions` | Works | Returned `[true, true]` |
| `playSound3D` | Inconclusive | The probe expression was malformed; the command itself was accepted by `12-command-capability.md` |

## What changes in the roadmap

- **H4 (restyle the vanilla subtitle control) is wrong as planned.** The class it
  names does not exist. Drop it, or find the real control first.
- **H1 (directional sound cue) stays gated.** `FiredNear` did not fire for a
  scripted shot. A client test is needed before any feature is built on it.
- **H7 (subtitle state control) is viable.** `showSubtitles`, `shownSubtitles`
  and `getSubtitleOptions` all work.

## UNVERIFIED

- Why `FiredNear` did not fire. The spawned units may not have been aware of each
  other, or `doFire` may not have produced a shot.
- Whether any of the above behaves differently with a real client.
