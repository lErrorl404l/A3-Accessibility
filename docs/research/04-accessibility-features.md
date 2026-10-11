# Accessibility feature catalogue and Arma 3 feasibility

Source of record for the roadmap. `ACHIEVABLE` = plain config/script. `ACHIEVABLE WITH LIMITS`
= possible with a stated caveat. `NOT ACHIEVABLE` = blocked by the engine. Claims marked
INFERRED were not verified against a primary source (BIKI returned 403 this pass).

Guideline sources: Game Accessibility Guidelines <https://gameaccessibilityguidelines.com/full-list/>;
WCAG 2.2 <https://www.w3.org/TR/WCAG22/>; Xbox Accessibility Guidelines (XAG 101-123)
<https://learn.microsoft.com/en-us/xbox/accessibility/xag-version-history>.

## The engine boundary

Everything **above** the game layer is reachable by an addon: dialogs, HUD, map markers,
`RscStructuredText`, CBA settings and keybinds, and scripted effects. Everything **inside** the
renderer or the audio mixer is not. There is no exposed post-process colour-matrix hook and no
audio-downmix API. Aim the roadmap at the reachable layer and state plainly, in the addon's own
accessibility note, which features are addon-scoped rather than game-wide.

## Feasibility verdicts

### Colour and contrast

| Feature | Verdict | Caveat |
|---|---|---|
| Colour-blind modes (addon UI, HUD, markers) | ACHIEVABLE WITH LIMITS | Can recolour everything the addon owns via `CfgInGameUI`, `RscStructuredText`, `setMarkerColor`. Cannot recolour the 3D world - no post-process hook |
| High-contrast mode | ACHIEVABLE WITH LIMITS | Own dialogs strong; wholesale vanilla `RscDisplay*` restyle not guaranteed |
| Remove colour reliance (add shape/text) | ACHIEVABLE WITH LIMITS | Own markers/icons yes; every vanilla texture overridable is INFERRED |
| Full-screen CVD render filter | NOT ACHIEVABLE | No exposed post-process or colour matrix |

### Vision

| Feature | Verdict | Caveat |
|---|---|---|
| Text size / UI scaling | ACHIEVABLE WITH LIMITS | Own dialogs only; cannot rescale every vanilla menu. Target XAG 101: 26 px at 1080p, 200% scaling |
| Subtitle size and background | ACHIEVABLE WITH LIMITS | Engine-rendered vanilla subtitles not restyleable; own subtitle display only |
| Dyslexia-friendly font | ACHIEVABLE WITH LIMITS | Ship via `CfgFonts`, apply to own UI; Arma uses bitmap fonts (INFERRED) |
| Screen-shake reduction | ACHIEVABLE WITH LIMITS | `addCamShake` is scripted; engine-native shake partially interceptable |
| Motion/flash reduction | ACHIEVABLE WITH LIMITS | Scripted effects only; post-process (bloom, motion blur, film grain) not exposed |
| Field of view | ACHIEVABLE WITH LIMITS | `camSetFov` works; some views/seats override; camera-level not monitor-level |

### Hearing

| Feature | Verdict | Caveat |
|---|---|---|
| Subtitles (addon overlay) | ACHIEVABLE WITH LIMITS | Own display via `RscStructuredText`; vanilla control not exposed |
| Closed captions for non-speech audio | ACHIEVABLE WITH LIMITS | Event-handler driven; coverage finite |
| Visual cues for audio direction | ACHIEVABLE WITH LIMITS | Same event-coverage caveat |
| Mono audio | NOT ACHIEVABLE | No addon audio downmix API; OS/driver setting only |

### Motor

| Feature | Verdict | Caveat |
|---|---|---|
| Remappable controls | ACHIEVABLE | `CBA_fnc_addKeybind` + native keybinds. Strongest fit |
| Hold-to-toggle / reduced repeated input | ACHIEVABLE WITH LIMITS | For addon interactions via `BIS_fnc_holdActionAdd`; vanilla unchanged |
| Aim assist | ACHIEVABLE WITH LIMITS | Scriptable; design trade against simulation feel |
| Difficulty / assist modes | ACHIEVABLE WITH LIMITS | `CfgDifficultyPresets` exists; cannot change core AI/ballistics |

### Cognitive

| Feature | Verdict | Caveat |
|---|---|---|
| Objective reminders | ACHIEVABLE | Persistent HUD via `RscStructuredText`; read engine task state |
| Simplified UI | ACHIEVABLE WITH LIMITS | Own menus only |
| Tutorial reinforcement | ACHIEVABLE | Self-contained overlays and prompts |
| No time pressure | ACHIEVABLE WITH LIMITS | Supporting missions only; vanilla timers unchanged |

### Speech

| Feature | Verdict | Caveat |
|---|---|---|
| Text-to-speech | ACHIEVABLE WITH LIMITS | No native TTS; needs `callExtension` (Windows SAPI) or pre-recorded audio. Binary dependency |
| Speech-to-text | NOT ACHIEVABLE | No in-engine speech recognition |

## Roadmap

Build first (plain config/script, high fit):

1. Colour-blind modes for addon UI, HUD and markers, switched by a `CBA_fnc_addSetting` LIST
   setting. This is the current first feature and it is the right one.
2. Remappable controls / accessibility-oriented keybind presets via `CBA_fnc_addKeybind`.
3. Objective and control reminders as a persistent structured-text HUD.
4. Hold-to-toggle for addon interactions via `BIS_fnc_holdActionAdd`.
5. Tutorial / help overlay for the addon's own features.

Build with a stated design caveat and dedicated testing:

- High-contrast mode and colour-reliance removal (own UI strong, vanilla partial).
- Text size and UI scaling (own UI only).
- Subtitle size and background (own subtitle display only).
- Dyslexia-friendly font (own UI, bitmap-font limits).
- Screen-shake, motion and flash reduction (scripted effects only).
- Field of view (camera-level, state-dependent).
- Closed captions and audio-direction cues (event coverage incomplete).
- Aim assist and difficulty/assist modes (design trade).
- No time pressure (supporting missions only).
- Text-to-speech (extension-dependent, Windows-only).

Out of reach at addon level: full-screen CVD render filter; unrestricted motion-blur/film-grain
control; mono audio downmix; speech-to-text.
