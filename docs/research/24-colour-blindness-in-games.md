# Colour-vision deficiency in games: accepted practice, prior art and the UI boundary

This report answers three questions. What do the recognised accessibility
guidelines say a game should do for colour-vision deficiency? How do other
games implement it? Does a colour correction normally cover the interface as
well as the 3D world?

Evidence rule: every claim cites a URL. Where a source is a requirement and
where it is only a recommendation, the text says which. Where the evidence is
thin, the text says so. No design proposal appears here. This file holds the
evidence and the practice only.

## 1. The accepted practice

### WCAG 1.4.1 Use of Color (Level A, normative)

The success criterion text requires that colour is "not used as the only visual
means of conveying information".

This is the requirement. The Understanding page is informative. It adds that a
second cue, such as shape or text, conveys the meaning. Its intent: colour
differences in an image may be invisible to a user with a colour deficiency,
so another visual means lets that user perceive the information.

https://www.w3.org/WAI/WCAG21/Understanding/use-of-color.html

### WCAG 1.4.11 Non-text Contrast (Level AA, normative)

User interface components and graphical objects must keep a contrast ratio of
at least 3:1 against adjacent colours.

The page links the two criteria. A hue change alone to convey state likely
fails the Use of Color criterion, not this one.

https://www.w3.org/WAI/WCAG21/Understanding/non-text-contrast.html

### Xbox Accessibility Guidelines (XAG). Best practice, not compliance

The introduction states that the XAGs are not a compliance checklist. They aim
to make the user experience in a game enjoyable and playable for everyone.

https://learn.microsoft.com/en-us/xbox/accessibility/guidelines

The colour guidance sits in XAG 103 (Additional channels for visual and audio
cues). Two rules carry the weight. No key game element should rely on colour
alone. If colour reliance is unavoidable, let the player assign a colour to
each element.

XAG 103 also states that a simulation filter is an internal tool only, never a
replacement for testing with real players who have colour blindness.

https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/103

XAG 102 (Contrast) covers the numeric side. Standard text and meaningful
non-text sit at 4.5:1, large text and inactive elements at 3:1, and a high
contrast mode at 7:1. It notes that red and green targeting icons can be hard
for some players, and points to XAG 103 for the colour rule.

https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/102

### Game Accessibility Guidelines (GAG). Recommendation, tiered Basic

The Basic-tier entry: "no essential information ... by a fixed colour alone."
It sits in the Vision group.

It advises using colour as a back-up for another means such as text, a symbol,
a pattern or a shape, by default or as a setting.

On filters, GAG warns that shifting the whole palette can be tempting and can
suit a case such as Madden, with its licencing restrictions on team kit
colours. But other solutions usually come first. A filter is harder to apply
well than it looks, and colorblind gamers often reject it. GAG calls it "a
blunt instrument" that can change colours that need no change and introduce
new clashes.

https://gameaccessibilityguidelines.com/ensure-no-essential-information-is-conveyed-by-a-fixed-colour-alone/

### IGDA Game Accessibility SIG. Recommendation

Title: "Do not implement colorblind filters."

"The idea of a single universal visual filter to solve colorblindness is a
tempting one, but it does not work."

IGDA says developers should implement colorblind support, not the system. They
should first reduce colour reliance with extra signifiers such as a symbol or
a shape. If that is not possible, they should adjust individual elements such
as team colours, and ideally offer a free colour choice to reach every edge
case.

It adds that filters have improved, but they still cannot reach those edge
cases, and colorblind gamers consistently say they are not what they want.

https://igda-gasig.org/how/platform-level-accessibility-recommendations/do-not-implement-colorblind-filters/

### Can I Play That? guide. Recommendation

The guide says do not use colour alone for information. Add sound, shapes and
animation.

It says the best modes let the player choose the colour of the most important
element. In a team game, the player should set the colours for their team and
the opposing team.

https://caniplaythat.com/2020/01/29/color-blindness-accessibility-guide/

### What the sources agree on

All sources agree on the order of practice. Reduce colour reliance first. Add
a second signifier such as a shape, a symbol or a text label. If colour must
stay, allow the player to choose the colour of an individual element. A
full-screen filter is the last resort, and the guidelines and the specialist
organisations contest it.

## 2. How other games actually do it

### Fortnite. A global filter with an intensity control

Fortnite has a global colour-blind mode (Protanope, Deuteranope, Tritanope)
plus a separate strength slider, commonly set between 1 and 10. This is the
named example of a game with a strength control on its colour-blind setting.

https://dotesports.com/fortnite/news/the-best-colorblind-settings-for-fortnite

https://rgblind.com/blog/color-blind-gaming-guide

### Overwatch and Overwatch 2. Per-element customisation

The player sets separate colours for enemy, ally and crosshair, and for
ability colours. This is the named example of per-element customisation.

https://us.forums.blizzard.com/en/overwatch/t/expanded-hud-ui-color-customization-options/1028767

### Destiny and Destiny 2. Per-element UI palette presets

GAG records that Destiny offers "alternative palette options for UI elements",
covering protanopia, deuteranopia and tritanopia, with a preview of the new
colours.

https://gameaccessibilityguidelines.com/destiny-colorblind-modes/

IGDA contrasts it with a filter. Destiny uses manually designed preset colour
combinations for important UI elements, and leaves all other visuals intact.

https://igda-gasig.org/how/platform-level-accessibility-recommendations/do-not-implement-colorblind-filters/

### Hue. Redundancy by symbols

GAG records: "Symbols added to coloured areas."

https://gameaccessibilityguidelines.com/hue-colorblind-mode/

### Tekken 8. Redundancy by pattern

Tekken 8 "offers an option to replace character models with patterned
silhouettes for easier differentiation."

https://access-ability.uk/2025/01/10/the-biggest-mistake-game-devs-make-with-colour-blind-accessibility/

### Madden. A whole-palette filter

GAG cites Madden as the case where a whole-palette filter can be the right
option, because of "licencing restrictions on team kit colours".

https://gameaccessibilityguidelines.com/ensure-no-essential-information-is-conveyed-by-a-fixed-colour-alone/

### Games criticised in public

**Overwatch.** The IGDA SIG page shows "Player feedback on the filter-based
colorblind modes in Overwatch." The criticism is that a filter changes colours
that did not need to change.

https://igda-gasig.org/how/platform-level-accessibility-recommendations/do-not-implement-colorblind-filters/

**Atomic Heart.** Access-Ability reports that Atomic Heart made this mistake
in the summer of 2024. It offered a colourblind filter set that simulated
colour blindness types rather than countering their effects. The criticism is
that the filters "might make red and green elements look the same to a non
colourblind player, rather than shifting one of those two colours into a more
detectable range for those who struggle to differentiate them."

https://access-ability.uk/2025/01/10/the-biggest-mistake-game-devs-make-with-colour-blind-accessibility/

## 3. Does a correction normally cover the UI?

The short answer: for a scene post-process, not covering the 2D interface is
the normal, expected default. A scene filter that tints the 3D world and
leaves the interface unchanged is the common case, not an unusual one. Whether
a shipped mode covers the HUD depends on its construction.

A scene post-process runs on the rendered 3D scene. The interface composites
after it.

### Unity

A Screen Space - Overlay canvas is "scaled to fit the screen and then rendered
directly without reference to the scene or a camera". The UI draws over other
graphics such as the camera view.

https://docs.unity3d.com/6000.0/Documentation/Manual/class-Canvas.html

The HDRP UI guidance states: "Render your menu in a Canvas with its Render
Mode set to Screen Space - Overlay. Using this render mode means HDRP does not
apply post-processing to the canvas."

https://docs.unity3d.com/Packages/com.unity.render-pipelines.high-definition@10.2/manual/UI-Best-Practices.html

To make post-processing reach the UI, developers switch the canvas render mode
from Screen Space - Overlay to Screen Space - Camera and point the render
camera at the post-processing effect.

https://stackoverflow.com/questions/45402927/unity-apply-post-processing-effects-to-all-ui-elements

### Unreal Engine

A post-process material applies to scene colour.

https://dev.epicgames.com/documentation/en-us/unreal-engine/post-process-materials-in-unreal-engine

Unreal has a separate, experimental mechanism to reach the UI. Slate
postbuffers sample the game scene for UI materials, in the same way that
postprocess materials use SceneColor. They let you create effects that apply
to both the game world and the user interface.

A dedicated feature exists, so the default post-process does not cover UMG and
Slate.

https://dev.epicgames.com/documentation/en-us/unreal-engine/using-slate-postbuffers-in-unreal-engine

### The three ways a correction reaches the interface

1. A final full-screen pass after UI composition. OS-level filters work this
   way. The Windows 10 and 11 colour filters cover the whole screen, including
   the interface.

2. A per-element palette remap. UI elements reference named colours that the
   mode changes. Destiny and Overwatch do this.

3. An engine UI-postprocess path. Unity Screen Space - Camera and Unreal Slate
   postbuffers are examples.

Sources for the OS-level filter: https://www.pcgamingwiki.com/wiki/Glossary:Color_blind_mode

### Where the evidence is thin

No survey states what share of shipped colour-blind modes cover the HUD. The
engine documentation is the strong evidence for the mechanism. The guideline
language (XAG 103, GAG, IGDA) treats the interface as a target in its own
right. A mode that fixes the 3D world and leaves the HUD unchanged therefore
does not meet the intent, even though the mechanism is normal.

## 4. Simulation versus correction

Access-Ability (Laura Dale), 2025, reports a clear published criticism. The
report says some developers "accidentally implement filters that simulate
colourblindness rather than countering its effects". It adds that the filters
act like simulation tools. A non colourblind player then sees the game through
colourblind eyes, while the colourblind player gets no support.

XAG 103 gives the same rule. A simulation is an internal tool for development,
never a shipped feature or a replacement for testing with real players.

https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/103

A correction shifts problem colours into a range the player can tell apart. A
simulation reproduces the deficiency and makes the problem worse for the
player it claims to help. Access-Ability calls this error "more common than it
should be."

https://access-ability.uk/2025/01/10/the-biggest-mistake-game-devs-make-with-colour-blind-accessibility/

## 5. Redundancy

The root rule is WCAG 1.4.1. The Understanding page gives the substitutes:
"information in addition to color, such as shape or text, to convey meaning."

Its examples: a required field marked with red text and an icon, and a diagram
labelled by colour and by a number next to each element.

The sufficient techniques include G14 (text), G182 (additional visual cues),
G205 (text cue for coloured form labels), and G111 (colour and pattern).

https://www.w3.org/WAI/WCAG21/Understanding/use-of-color.html

- XAG 103: colour alone should never "represent information". It recommends
  "Text or text labels", "Symbols and shapes", and on-screen elements.
  https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/103

- GAG: "use colour as a back-up for another means of communicating the
  information, such as text or a symbol, pattern or shape."
  https://gameaccessibilityguidelines.com/ensure-no-essential-information-is-conveyed-by-a-fixed-colour-alone/

- Can I Play That?: "Consider using sound, shapes and animations to support the
  information." And "another visual element present to inform the player, such
  as an icon, image or border."
  https://caniplaythat.com/2020/01/29/color-blindness-accessibility-guide/

The recommended redundancy set: shape, icon or symbol, pattern or texture, text
label, position or spatial location, animation, and audio. IGDA and GAG both
put redundancy first and colour customisation second.

## Conclusions

1. The accepted order of practice puts reducing colour reliance and adding a
   second signifier ahead of a full-screen filter. Every source in section 1
   agrees on that order. A full-screen filter is a contested last resort, not
   the target. The order is: reduce colour reliance, add a second signifier,
   then allow a per-element colour choice.

2. A scene post-process is expected not to cover the interface, because the
   interface composites after it in the mainstream engines. Unity Screen Space
   - Overlay canvases and Unreal UMG and Slate both draw after post-processing.
   A developer who wants the interface covered must add a full-screen pass
   after composition, remap interface colours per element, or use an engine
   interface-postprocess path.

## Limits of this report

- No survey states what share of shipped colour-blind modes cover the HUD. The
  engine documentation is the strong evidence for the mechanism.

- WCAG is a web standard and the XAG is a console guideline. Neither binds a
  game addon. They are the best available measure, not a compliance claim.

- The game examples in section 2 rest on vendor settings pages and on the GAG
  and IGDA SIG write-ups. They are not code-verified.

- The criticism in section 2 and section 4 is published opinion from
  accessibility specialists. This report gives it as criticism, not as
  measurement.
