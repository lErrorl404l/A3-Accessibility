# Accessibility requirements: UK, US and EU

Source of record for the accessibility statement and documentation. This is research, not legal
advice. It separates binding law from voluntary guidance.

## United Kingdom

- GOV.UK "Guidance and tools for digital accessibility" (GDS/CDDO, updated 2026-01-16): a signposting
  page for teams that must meet the Public Sector Bodies Accessibility Regulations.
  <https://www.gov.uk/guidance/guidance-and-tools-for-digital-accessibility>
- GOV.UK "Understanding accessibility requirements for public sector bodies" (updated 2024-09-30):
  the legal test is WCAG 2.2 AA plus a published accessibility statement. The regulations build on
  the Equality Act 2010.
  <https://www.gov.uk/guidance/accessibility-requirements-for-public-sector-websites-and-apps>
- Public Sector Bodies (Websites and Mobile Applications) (No. 2) Accessibility Regulations 2018,
  SI 2018/952: binds public sector bodies only. <https://www.legislation.gov.uk/uksi/2018/952/contents>
- Equality Act 2010: duty to make reasonable adjustments. <https://www.legislation.gov.uk/ukpga/2010/15/contents>
- GDS Service Standard point 5: mandatory for UK government services, not a general law.

Binding on this mod? Very unlikely. The 2018 Regulations bind public sector bodies. The mod is a
private open-source addon. Whether a free game mod is a "service to the public" under the Equality
Act is UNVERIFIED. WCAG is voluntary and has no direct force here. The author can adopt the same
target voluntarily.

## United States

- ADA Title III covers places of public accommodation. Whether a video game or mod is covered is
  UNVERIFIED; the DOJ has published no rule naming video games.
  <https://www.ada.gov/resources/title-iii-primer/>
- Section 508 of the Rehabilitation Act (29 U.S.C. 794d) binds US federal agencies, not private mods.
  The Revised 508 Standards reference WCAG (baseline WCAG 2.0 AA, guidance moving to 2.1 AA).
  <https://www.section508.gov/manage/laws-and-policies/section-508-law/>
- The Access Board lists 410 Color Coding: where colour conveys information, a non-colour means must
  exist. <https://www.access-board.gov/ict/>
- 21st Century Communications and Video Accessibility Act (CVAA, PL 111-260) covers advanced
  communications services and video programming. A colour-only mod does not engage it. UNVERIFIED
  against the FCC page (403).
- Xbox Accessibility Guidelines (XAG) v3.2 (2023-06-08): voluntary. XAG 103 states "Color alone
  should never be used to represent information", and warns that simulation filters do not replace
  testing with colour-blind players. This is the closest fit.
  <https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/103>

## European Union

- European Accessibility Act, Directive (EU) 2019/882. Covered products and services do not name
  video games; the mod is out of scope. Application date widely reported as 2025-06-28, UNVERIFIED
  against the directive text. <https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A32019L0882>
- Web Accessibility Directive, Directive (EU) 2016/2102: binds public sector bodies only.
- EN 301 549 v3.2.1 is the harmonised standard, based on WCAG 2.1 (Annex A). WCAG 2.2 is not yet
  referenced by a harmonised version.

## Mapping to the mod

| Criterion | Requirement | What this mod can do | What it cannot do |
|---|---|---|---|
| WCAG 2.2 SC 1.4.1 Use of Color | Colour is not the sole carrier of meaning | Remap hues and add a luminance difference, which the W3C counts as a second distinction at 3:1 | Add the shape or text cue where the game uses colour alone |
| WCAG 2.2 SC 1.4.3 Contrast (Minimum) | Text 4.5:1 | Meet it for text the mod draws | Change Arma 3's own text or guarantee contrast over a 3D background |
| WCAG 2.2 SC 1.4.11 Non-text Contrast | UI and meaningful graphics 3:1 | Meet it for the colours the mod sets | Change markers the mod does not override |

Core rule, from SC 1.4.1 and XAG 103: a colour palette is a mitigation, not a fix. The fix is a
second cue. The mod states this plainly and is addon-scoped, not game-wide.

## Concrete actions

1. Add `ACCESSIBILITY.md`, using the GOV.UK model as the structure.
2. State the scope limit once: the mod is addon-scoped and cannot change Arma 3 itself.
3. Document each mode: name, target deficiency, and a one-line description.
4. Publish the measured contrast ratios: 3:1 for the marker pairs, 4.5:1 for text.
5. State that the mod is not a compliance claim.
6. Name the voluntary standards used: WCAG 2.2 AA and Xbox Accessibility Guideline 103.
7. Add a "report an accessibility problem" route (a GitHub issue).

## UNVERIFIED

- EAA application date against the directive text.
- Whether a free game mod is a "service to the public" under the Equality Act 2010.
- Whether a video game or game chat is covered by ADA Title III or the CVAA.
- The exact WCAG version and level in the Revised Section 508 Standards (36 CFR 1194 Ch 7).
- The exact EN 301 549 v3.2.1 level letter (ETSI PDF).
- The FCC CVAA page content (403).
