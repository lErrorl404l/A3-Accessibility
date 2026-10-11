# A3 Accessibility

An Arma 3 addon that helps colour-blind players. The first feature is a set of selectable
colour-vision-deficiency (CVD) modes that recolour the game's load-bearing UI colours -
map markers, map icons, HUD and structured-text panels - so friend, foe and objective
colours stay distinguishable without relying on the red-green axis.

The scope is deliberately wider than colour: the project is the home for accessibility
features that are achievable through the config and scripting layer (see
`docs/research/`), with colour-blind support built and tested first.

## Status

Scaffolded and building. Research complete for CVD types and the CBA/build toolchain;
Arma 3 config-surface, broader accessibility, and test strategy research in progress.
No colour logic implemented yet.

## Requirements

- Arma 3 2.12 or later (`REQUIRED_VERSION` in `addons/main/script_mod.hpp`).
- CBA_A3 (Workshop ID `450814997`). Declared in `.hemtt/project.toml` and in the feature
  component's `requiredAddons[]`.

## Build

HEMTT is the build tool (`/home/matt/.local/bin/hemtt`).

```
hemtt check     # lint + config validation
hemtt build     # unsigned build into .hemttout/build
hemtt release   # signed release into releases/
hemtt launch    # build and launch Arma 3 with CBA loaded
```

## Layout

```
addons/
  main/           shared macros, version, CfgMods
  colourblind/    CVD feature component: the mode setting and colour remap
docs/
  research/       the evidence base for every design decision
include/          CBA + a3 include stubs so `hemtt check` resolves offline
```

Tag `A3ACC`. PBO prefix `z\a3acc`. Addon class names `A3ACC_main`, `A3ACC_colourblind`.

## Design rules

- Remap UI colours per mode. Never ship a filter that simulates CVD - simulation makes
  the problem worse for the player who has it.
- Do not let hue carry meaning alone. Pair every colour with a distinct icon shape and,
  where possible, a text tag.
- Separate colours by perceived luminance first (target 3:1 against adjacent colours),
  then by hue. WCAG 2.2 SC 1.4.1, 1.4.3 and 1.4.11 are the reference thresholds.
- Offer distinct modes (protan, deutan, tritan, achromatopsia). One palette cannot serve
  both the red-green and the blue-yellow axes.

## Research index

| Doc | Covers |
|---|---|
| `docs/research/01-cvd-types.md` | CVD types, prevalence, confusion pairs, palette strategy, industry precedent |
| `docs/research/02-cba-and-tooling.md` | CBA_A3 settings/events/XEH, HEMTT toolchain, project conventions |

Further docs (Arma 3 config surface, broader accessibility catalogue, test strategy) are
added as their research completes.
