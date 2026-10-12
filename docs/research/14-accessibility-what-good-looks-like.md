# What good looks like: standards, prior art and the addon boundary

This report answers three questions. Which accessibility requirements apply to a
game HUD? What do real Arma 3 accessibility mods implement? Which of those
behaviours can an Arma 3 addon reach, and which cannot?

It is a field survey, not a description of this project. Files 01 to 13 hold the
background. This file adds the named guideline numbers, the verified prior art
and a gap list.

Evidence rule: every claim cites a URL. Where a claim could not be verified it is
marked UNVERIFIED. `websearch` failed in this session, so the prior art comes
from Steam Workshop pages, the GitHub search API and a subagent fetch pass.

## 1. Applicable standards

### 1.1 WCAG 2.2

WCAG is a web standard. A game HUD is not a web page, so WCAG is voluntary here.
It still gives the clearest numeric thresholds, and it is the base that other
guidance copies.

| Criterion | Level | Requirement (quoted) | URL |
|---|---|---|---|
| 1.4.1 Use of Color | A | "Color is not used as the only visual means of conveying information, indicating an action, prompting a response, or distinguishing a visual element." | https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html |
| 1.4.3 Contrast (Minimum) | AA | "The visual presentation of text and images of text has a contrast ratio of at least 4.5:1", with 3:1 for large-scale text. | https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html |
| 1.4.11 Non-text Contrast | AA | UI components and graphical objects "have a contrast ratio of at least 3:1 against adjacent color(s)". | https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html |
| 1.3.1 Info and Relationships | A | "Information, structure, and relationships conveyed through presentation can be programmatically determined or are available in text." | https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships.html |
| 2.1.1 Keyboard | A | "All functionality of the content is operable through a keyboard interface without requiring specific timings for individual keystrokes". | https://www.w3.org/WAI/WCAG22/Understanding/keyboard.html |
| 2.3.1 Three Flashes or Below Threshold | A | Content must not flash "more than three times in any one second period", unless below the general flash and red flash thresholds. | https://www.w3.org/WAI/WCAG22/Understanding/three-flashes-or-below-threshold.html |

Two notes carry weight. First, 1.4.1 accepts a luminance difference of 3:1 as a
second distinction, but only where the meaning does not depend on perceiving a
particular hue. Second, 1.3.1 is the requirement a colour swap cannot meet on
its own. It needs structure that a machine or a reader can recover.

### 1.2 Xbox Accessibility Guidelines

The Xbox Accessibility Guidelines (XAG) are game-specific. They are voluntary.
They fill the gap that WCAG leaves for a first-person shooter.

| XAG | Title | Requirement (quoted or closely paraphrased) | URL |
|---|---|---|---|
| 101 | Text display | Minimum default text: 26 px at 1080p on console, 18 px at 1080p on PC. Text scales "up to 200 percent" with no loss of content. Include one sans serif option. | https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/101 |
| 102 | Contrast | Standard text and meaningful non-text at 4.5:1. Large text and inactive elements at 3:1. High contrast mode at 7:1. | https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/102 |
| 103 | Additional channels for visual and audio cues | "Color alone should never be used to represent information." Simulation filters "shouldn't be used as a replacement for testing with actual players with colorblindness." | https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/103 |
| 104 | Subtitles and captions | Subtitles for all spoken content. Captions for all important non-speech sounds, with spatial indication. Adjustable size to 200 percent. A solid background with adjustable opacity from 0 to 100 percent. No more than two lines on screen. | https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/104 |
| 107 | Input | "Players should be given the option to remap all of the controls within the game itself". A UI must be navigable "by using single, non-simultaneous key presses". Provide "toggles and 'auto' holds" for controls that are normally held. | https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/107 |
| 117 | Visual distractions and motion settings | "Avoid the use of camera shake, camera bobbing effects, motion blur, mouse blur, and more or provide an option to turn off these behaviors." Also requires adjustable field of view and camera sensitivity. | https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/117 |
| 118 | Photosensitivity | A luminance flash failure occurs when a flash of "10% change in luminance" covers "approximately 20 percent or more" of the screen and occurs "more than three per second". A red flash fails at a lower threshold. | https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/118 |

### 1.3 GOV.UK guidance

GOV.UK adds one requirement that neither WCAG nor the XAG states: a published
accessibility statement. GOV.UK says a site meets the legal requirements if it
publishes "an accessibility statement that explains how accessible your website
or mobile app is". The service manual also requires teams to work on the
commonly used assistive technologies and to include disabled people in user
research.

- https://www.gov.uk/guidance/accessibility-requirements-for-public-sector-websites-and-apps
- https://www.gov.uk/service-manual/helping-people-to-use-your-service/making-your-service-accessible-an-introduction

This duty binds public sector bodies. It does not bind a private game mod. The
report cites it as good practice, not as law.

## 2. Prior art

Verified from the mod's own Workshop page or repository. All Steam URLs are
`https://steamcommunity.com/sharedfiles/filedetails/?id=<ID>`.

| Mod | Platform | ID or repo | What it implements |
|---|---|---|---|
| TrueColor | Steam Workshop | 3726750329 | A client-side visual tuning panel on a CBA keybind. Adjusts brightness, contrast, saturation, temperature and RGB balance, and optional film grain, blur and chromatic aberration. Saves a per-client profile. This is a post-process colour grade, not a colour-blind mode. |
| ReColor | Steam Workshop | 649832908 | Adds customisable colour-correction and film-grain post-process effects to a mission. Visual grading. |
| More Map Colors | Steam Workshop | 3159181992 | Adds named map-draw colours for map planning. |
| More Map Colors | Steam Workshop | 3435316688 | Adds named map-draw colours, including a cyan noted as high contrast for night. |
| Universal Map Marker Colours | Steam Workshop | 2991973526 | Adds marker-menu colours and adds `ColorUMMCNAME` classes. |
| ATLAS - More Map Colours | Steam Workshop | 3028027998 | Adds 12 map-draw and marker colours. |
| GX - Additional Map Marker Colors | Steam Workshop | 2116771393 | Additional map marker colours. |
| Native Keybinding for Addons | Steam Workshop | 3789881573 | Native keybinds for TFAR, CTAB and ACE, so joystick and alternative input users avoid the 20 Custom Control limit. |
| A3-TTS (text to speech) | Steam Workshop | 2958067561 | Scripted text to speech for mission makers, called with `A3TTS_fnc_say`. Word-for-word fallback. Not a subtitle or screen-reader feature. |
| Moose's Simple Subtitle Template | Steam Workshop | 2580968721 | A copy-and-paste subtitle template for mission makers. |
| Hotkey Volume Adjust | Steam Workshop | 3711784861 | Keybound 25 percent volume steps. |
| Deadzone Aiming Style Tank | Steam Workshop | 3606054870 | An alternate controller aiming style. |
| Extra Post-Process Themes | Steam Workshop and GitHub | 2861950022, https://github.com/M9-SD/A3_Extra-Post-Process-Effects-GUI-Comp | Post-process GUI themes. |
| arma3-subtitle-tool | GitHub, MIT | https://github.com/SerBlackwater/arma3-subtitle-tool | A browser tool that generates multiplayer-safe Arma 3 subtitle sequences, with style presets and a timeline editor. |
| A3-Accessibility (this project) | GitHub, GPL-2.0 | https://github.com/lErrorl404l/A3-Accessibility | The reference implementation. Its scope and limits are in `ACCESSIBILITY.md`. |

Findings:

- No Arma 3 mod was found that ships a colour-vision-deficiency palette as its
  main feature. The Workshop search for "colorblind" returns 3 items, none of
  them a CVD mod. The colour mods that exist add map-draw colours for planning.
- No Arma 3 mod was found that removes camera shake or screen effects for motion
  sensitivity. `CamShake Recoil` (3810870299) adds shake.
- No Arma 3 mod was found that scales text or the HUD, restyles the engine
  subtitle control, or reduces flashes.
- No open-source Arma 3 repo was found for colour-blind, subtitle-restyle or
  shake-reduction features. ACE3 was checked and no such feature was found,
  though the code index may be incomplete, so this is UNVERIFIED.

## 3. Capability split

### An addon can

- Recolour named colours. The prior-art colour mods and this project override
  `CfgMarkerColors`, the marker catalogue and the map-draw palette. The engine
  surface is counted in `docs/research/11-config-sweep.md`.
- Apply a post-process colour grade. TrueColor proves this. It is a global
  filter, so it changes the whole picture. XAG 103 warns that a simulation
  filter does not replace a second cue or testing with disabled players.
- Add its own HUD and dialogs. An addon can draw `RscTitles` and
  `RscStructuredText`, and can set font and size on its own controls.
- Force subtitles and radio sentences for the local player, and reduce HUD
  clutter. The accepted commands are listed in
  `docs/research/12-command-capability.md`.
- Reduce scripted camera shake. `enableCamShake` and `resetCamShake` are client
  effects. Engine-native shake is only partly reachable.
- Register keybinds through `CBA_fnc_addKeybind`. Native Keybinding for Addons
  shows the same native-keybind route for joystick users.
- Offer a difficulty preset through `CfgDifficultyPresets` and read options with
  `difficultyOption`.

### An addon cannot

- Add a shape, icon, pattern or text cue where the game conveys meaning by
  colour alone. This is the core limit. WCAG 1.4.1 and XAG 103 both require the
  second cue. No Arma 3 mod found supplies it.
- Restyle the 3D world. There is no per-object colour hook for terrain and
  models. `docs/research/11-config-sweep.md` records the ceiling.
- Restyle every vanilla menu or scale all vanilla text. Arma 3 uses bitmap
  fonts and has no global UI scale command. A mod can change its own controls
  and reach a few named vanilla controls, not the whole interface.
- Downmix audio to mono, or add screen narration. The engine exposes no
  downmix matrix and no narration API. `docs/research/12-command-capability.md`
  records both as absent.
- Change core AI, ballistics or the game engine. The addon is addon-scoped.

## 4. Gap list

The gaps below follow from the standards in section 1 and the prior art in
section 2. They are ordered by how well the standard matches an Arma 3 addon.

1. A second cue for colour. XAG 103 and WCAG 1.4.1 require a non-colour cue.
   No Arma 3 mod found supplies one. This is the largest gap.
2. Subtitle and caption restyle. XAG 104 requires adjustable size to 200
   percent, a solid background with adjustable opacity, and captions for
   important non-speech sounds. No Arma 3 mod found does this.
3. Text and HUD scaling. XAG 101 requires 200 percent scaling with no loss.
   No Arma 3 mod found scales text.
4. A high contrast mode at 7:1. XAG 102 requires it. No Arma 3 mod found
   provides one.
5. Photosensitivity control. XAG 118 and WCAG 2.3.1 set the flash limits. No
   Arma 3 mod found reduces flashes, muzzle flash or explosion brightness.
6. Toggles and auto-holds for held controls. XAG 107 requires them. No Arma 3
   mod found provides them for native actions.
7. Aim and difficulty assist. XAG 108 covers difficulty. No accessibility-declared
   Arma 3 mod found provides an assist preset.
8. An accessibility statement. GOV.UK requires one. This project has
   `ACCESSIBILITY.md`. A published statement is a separate artefact.
9. Testing with disabled players. XAG 103 states that a simulation filter does
   not replace this. No Arma 3 mod found states that disabled players tested it.
   This project records the same gap in `ACCESSIBILITY.md`.

## 5. Limits of this report

- `websearch` returned an execution error on every call, so no general web
  search was possible. Findings rest on Steam Workshop pages, the GitHub API and
  a fetch pass.
- Steam Workshop descriptions are author-written. A mod's stated behaviour may
  differ from its code. The open-source column is the only code-verified entry.
- The ACE3 check used a code index that may not cover the whole repository.
  That single claim is UNVERIFIED.
- WCAG is a web standard and the XAG is a console guideline. Neither binds an
  Arma 3 addon. They are the best available measure, not a compliance claim.
