# Mod survey: Arma 3 accessibility and colour mods

This report surveys Arma 3 mods that touch accessibility or colour. It asks what
each mod does, which technique it uses, and whether the profile-variable
technique in this addon has precedent. Evidence rule: every claim cites a URL.
A claim with no source is marked UNVERIFIED.

Steam URLs are `https://steamcommunity.com/sharedfiles/filedetails/?id=<ID>`.
GitHub search results are cited by repository and file path.

## 1. Mods

| Mod | Author | Platform | Repository or Workshop URL | Licence | Last update | Accessibility behaviour |
|---|---|---|---|---|---|---|
| TrueColor | Ruca | Steam Workshop | id=3726750329 | APL-SA | 2026 | Post-process colour grade panel on a CBA keybind. Brightness, contrast, saturation, temperature, RGB balance, film grain, blur, chromatic aberration. Per-client profile. |
| ReColor | UNVERIFIED | Steam Workshop | id=649832908 | NONE stated | UNVERIFIED | Colour-correction and film-grain post-process effects. Visual grading only. |
| More Map Colors | UNVERIFIED | Steam Workshop | id=3159181992 | NONE stated | UNVERIFIED | Named map-draw colours for planning. |
| More Map Colors | UNVERIFIED | Steam Workshop | id=3435316688 | NONE stated | UNVERIFIED | Named map-draw colours, one cyan noted as high contrast for night. |
| Universal Map Marker Colours (UMMC) | Tek191 | Workshop + GitHub | id=2991973526, https://github.com/Tek191/UMMC | GPL-3.0 | 2023 | Redefines every vanilla `CfgMarkerColors` entry and adds 18 `ColorUMMCNAME` colours. Keeps originals as `ColorVanillaNAME`. |
| ATLAS - More Map Colours | UNVERIFIED | Steam Workshop | id=3028027998 | NONE stated | UNVERIFIED | Adds 12 map-draw and marker colours. |
| GX - Additional Map Marker Colors | GanX, Indianawinny | Steam Workshop | id=2116771393 | NONE stated | 2024 | Adds marker colours and renames some existing ones. |
| Native Keybinding for Addons | UNVERIFIED | Steam Workshop | id=3789881573 | NONE stated | UNVERIFIED | Native keybinds for TFAR, CTAB and ACE, for joystick and alternative input users. |
| A3-TTS (text to speech) | UNVERIFIED | Steam Workshop | id=2958067561 | NONE stated | UNVERIFIED | Scripted text to speech for mission makers. Not a screen reader. |
| Moose's Simple Subtitle Template | UNVERIFIED | Steam Workshop | id=2580968721 | NONE stated | UNVERIFIED | Copy-and-paste subtitle template for mission makers. |
| Hotkey Volume Adjust | UNVERIFIED | Steam Workshop | id=3711784861 | NONE stated | UNVERIFIED | Keybound 25 percent volume steps. |
| Deadzone Aiming Style Tank | UNVERIFIED | Steam Workshop | id=3606054870 | NONE stated | UNVERIFIED | Alternate controller aiming style. |
| Extra Post-Process Themes | M9-SD | Workshop + GitHub | id=2861950022, https://github.com/M9-SD/A3_Extra-Post-Process-Effects-GUI-Comp | MIT | 2022 | Colour-correction themes applied as a post-process effect. |
| arma3-subtitle-tool | SerBlackwater | GitHub | https://github.com/SerBlackwater/arma3-subtitle-tool | MIT | 2026 | Browser tool that generates multiplayer-safe subtitle sequences. |
| WaldosMissionPack | AdamWaldie | GitHub | https://github.com/AdamWaldie/WaldosMissionPack | NOASSERTION | 2026 | Mission-side accessibility screen with colour-vision profiles. Profile-persisted per client. |
| TroubleInArmaville | AdamWaldie | GitHub | https://github.com/AdamWaldie/TroubleInArmaville | MIT | 2026 | Colourblind-safe Okabe-Ito palette toggle, profile-persisted, for the game mode UI. |
| ACM-Extended | hesherson | GitHub | https://github.com/hesherson/ACM-Extended | NONE | 2026 | Runtime colour resolver that transforms every addon colour for protan, deutan and tritan modes. Per-client setting. |
| ark_inhouse | Cyruz143 | GitHub | https://github.com/Cyruz143/ark_inhouse | NONE | 2026 | NVG overlay aimed at colourblind players. |
| A3-Accessibility (this project) | lErrorl404l | GitHub | https://github.com/lErrorl404l/A3-Accessibility | GPL-2.0 | 2026 | Five CVD modes over engine surfaces, written as profile variables and read by config. No filter, no post-process effect. |

Note. A Steam Workshop search for "colorblind" returns 3 items, and none is a
colour-vision-deficiency mod. Source:
https://steamcommunity.com/workshop/browse/?appid=107410&searchtext=colorblind&browsesort=textsearch

## 2. Technique by group

### Config override

UMMC defines every vanilla `CfgMarkerColors` class and adds new ones. Source:
`class CfgMarkerColors` in the repo tree, https://github.com/Tek191/UMMC, and
the README note that `ColorRed` and all standard colours stay defined.
GX, More Map Colors and ATLAS use the same route. Community mods add marker
classes the same way, for example
`acemod/ACE3:addons/map/CfgMarkers.hpp` and
`FridayNightFight/FNF:client_mod_optional/fnf_mapMarkers/config.cpp`.

### Profile-variable expression

The engine's own UI config reads profile variables. `defineCommonColors.inc`
ships `#define Map_OPFOR_R "(profilenamespace getvariable ['Map_OPFOR_R',0])"`
and the `IGUI_*` set. Source:
`TMF3/TMF:include/a3/ui_f/hpp/defineCommonColors.inc` lines 6 to 101, and
`R3voA3/3den-Enhanced:include/a3/3den/ui/macros.inc` line 44. ACE and AGM read
`IGUI_TEXT_RGB_*` in their own titles. Source:
`KoffeinFlummi/AGM:AGM_NameTags/RscTitles.hpp`.

### Runtime setter, engine profile variable

The Altis Life "Maverick" navigation writes the engine's own `Map_*` variables.
Source: `VindictiveA3/vdic:.../maverick/navigation/gui/script_guiNavigationSettings.sqf`
lines 165 to 167:

```
profileNamespace setVariable ["Map_Unknown_R", MAVV(color) param [0] ];
profileNamespace setVariable ["Map_Unknown_G", MAVV(color) param [1] ];
profileNamespace setVariable ["Map_Unknown_B", MAVV(color) param [2] ];
```

diwako_dui writes `igui_*` profile variables that its own config reads. Source:
`diwako/diwako_dui:addons/main/XEH_preInit.sqf`.

### Runtime setter, marker command

AGM sets a marker colour from a config name, not a literal. Source:
`KoffeinFlummi/AGM:AGM_Markers/functions/fn_setMarker.sqf`:
`(_this select 0) setMarkerColorLocal (_this select 1)`. Altis Life, liberation
and ALiVE use the same command with `ColorOPFOR` and `ColorRed`.

### Post-process effect

TrueColor, ReColor and Extra Post-Process Themes apply a colour grade through
`ppEffectCreate`. TrueColor requires CBA_A3 and states the effect is client
side. Source: id=3726750329. A forum thread on colour-correction themes for
colourblindness is cited by
`holy-evening-chillers/MissionTemplate:root/initPlayerLocal.sqf`.

### Something else, runtime colour resolver

ACM-Extended does not ship a second palette and does not use a filter. It
transforms each colour at the point of use. Source:
`hesherson/ACM-Extended:addons/acm_extended/functions/fn_cbColor.sqf`:
"a colorblind-aware color resolver ... a transform applied at the point of use
cannot be forgotten". WaldosMissionPack stores a profile id and applies it
through its own UI functions. Source:
`AdamWaldie/WaldosMissionPack:MissionScripts/MissionFlowAndUi/Accessibility/uiColourVisionApplyLocal.sqf`.

## 3. Precedent for the profile variable approach

Yes. The technique has precedent in two independent places.

1. The engine itself ships it. Arma 3 config defines `Map_*` and `IGUI_*` as
   `profilenamespace getvariable` expressions, so a colour is read from the
   profile at load. Source:
   `TMF3/TMF:include/a3/ui_f/hpp/defineCommonColors.inc` and
   `R3voA3/3den-Enhanced:include/a3/3den/ui/macros.inc`.
2. A mod writes the engine's own variable. The Maverick navigation writes
   `Map_Unknown_R`, `Map_Unknown_G` and `Map_Unknown_B` to `profileNamespace`,
   then saves. Source: `VindictiveA3/vdic` script above, line 173
   `saveProfileNamespace;`.

What has no precedent found. No mod was found that writes the full `Map_*` and
`IGUI_*` colour set for a colour-vision-deficiency palette, nor a mod that adds
its own `A3ACC_Surf_*` style variables for surfaces the engine does not expose.
The Maverick code writes only the `Map_Unknown_*` triple. This part is
UNVERIFIED as prior art.

## 4. Pitfalls recorded by other authors

1. Overwriting vanilla colour names breaks scripts that name them. UMMC
   "redefines the standard ingame colours" and must keep the originals as
   `ColorVanillaNAME`. GX "renames some of the existing ones". Source:
   https://github.com/Tek191/UMMC README, and id=2116771393 comments.
2. `setMarkerColorLocal` consumes `CfgMarkerColors` names, not RGBA literals.
   Source: `ALiVEOS/ALiVE.OS:addons/mil_c2istar/cop/README.md`. A raw colour
   value cannot reach a marker through that command.
3. Post-process effects collide on priority. "If there is another effect using
   the same priority, creation will fail." Source:
   https://community.bistudio.com/wiki/ppEffectCreate. TrueColor asks reporters
   to name "any other mods or missions that also control post-process effects".
   Source: id=3726750329.
4. A surface can silently ignore an accessibility setting. TroubleInArmaville
   records that scoreboard "colours silently ignored the colourblind-accessibility
   setting". Source:
   `AdamWaldie/TroubleInArmaville:functions/ui/fn_scoreboard.sqf`. This is the
   same class of fault as an evaluation moment that a mode change misses.
5. Config inheritance goes wrong easily. Source:
   https://community.bistudio.com/wiki/Class_Inheritance, "Inheriting classes
   within the config is a concept that can easily go wrong". This addon already
   guards a cleared vanilla base class in its harness.
6. Namespace write ordering. Authors write the variable, then save, then read
   the result in the same session. Sources: Maverick `saveProfileNamespace;`
   line 173, and
   `AdamWaldie/WaldosMissionPack:.../uiColourVisionApplyLocal.sqf` lines 26 to
   28, which write `profileNamespace`, call `saveProfileNamespace`, then set a
   `missionNamespace` mirror for immediate use.
7. Marker icon lost by a `CfgMarkers` override. A class that drops the `icon`
   or `texture` key loses its symbol. UNVERIFIED. No source found.

## 5. Where this addon differs

Choices with precedent:

- Config reads profile variables as per-channel expressions. This is the
  engine's own pattern. Precedent in `defineCommonColors.inc`.
- A script writes the engine's own `Map_*` variables. Precedent in the
  Maverick navigation.
- A client colour mode stored in `profileNamespace` and applied live.
  Precedent in WaldosMissionPack, TroubleInArmaville and ACM-Extended.
- No screen filter. ACM-Extended states its modes are "not filters", for the
  same reason. Precedent.
- Per-client setting, so two players differ. Precedent in ACM-Extended.

Choices with no precedent found:

- A complete CVD palette driven through the engine's own `Map_*` and `IGUI_*`
  variables across every listed surface. Other mods use a post-process filter
  or a runtime transform, not the engine variable set.
- Own `A3ACC_Surf_*` variables for surfaces the engine does not expose.
- Shipping no post-process effect at all while covering the whole HUD. Most
  colour mods found use a post-process effect.
- A machine contrast gate at 3:1 over the palette. No mod found gates its
  palette this way.
- Restoring the player's own values on Off. No mod found does this.

The nearest neighbour in technique is ACM-Extended. It reaches the same goal
with a runtime transform instead of profile variables. Its author records that
a transform at the point of use cannot be forgotten, which is the trade this
addon makes in the other direction.

## 6. Limits of this report

- Steam Workshop pages are author-written. The behaviour stated may differ from
  the code. The open-source rows are the code-verified rows.
- `websearch` failed on several calls. Some findings rest on GitHub search and
  page fetches.
- The community.bistudio.com wiki returned HTTP 403 on fetch. Its text is
  quoted from the search result snippet, not from a direct fetch.
- No licence is shown for many Workshop mods. Those rows read NONE stated.
