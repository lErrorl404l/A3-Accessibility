# A3 Accessibility

Accessibility modes for Arma 3, built for players with colour vision deficiency.

The first feature is a set of selectable colour-blind modes. Each mode remaps the key UI colours,
so map markers, map icons and structured-text panels stay distinguishable without relying on the
red-green axis.

The project is the home for accessibility features that the Arma 3 config and scripting layer can
support. Colour-blind support is built and tested first.

## Colour-blind modes

Select a mode in the CBA settings menu under "A3 Accessibility".

Modes: Off, Protan, Deutan, Tritan, Achromatopsia.

Each mode remaps the named marker colours. The addon does not apply a screen filter.

## Requirements

- Arma 3 2.12 or later.
- CBA_A3, Workshop ID 450814997.

## Build

HEMTT is the build tool.

```
hemtt check
hemtt build
hemtt release
hemtt launch
```

## Design rules

- Remap UI colours for each mode. Do not ship a filter that simulates colour vision deficiency.
- Do not let hue carry meaning alone. Pair each colour with a distinct icon shape.
- Separate colours by luminance first, then by hue. Target a 3:1 contrast against adjacent colours.
- Offer distinct modes. One palette cannot serve both the red-green and the blue-yellow axes.

## Project layout

```
addons/main/          shared macros and version
addons/colourblind/   the colour-blind feature
docs/research/        the evidence base for each decision
docs/PLAN.md          the implementation and test plan
include/              include stubs, so hemtt check resolves offline
```

## Status

In development. The colour-blind modes are the first feature. Further accessibility features are
recorded in the research.

## Research

- docs/research/01-cvd-types.md - colour vision deficiency types, prevalence and palettes.
- docs/research/02-cba-and-tooling.md - CBA_A3 settings and events, and the HEMTT toolchain.
- docs/research/03-testing.md - the test strategy.
- docs/research/04-accessibility-features.md - the wider accessibility catalogue and its feasibility.
- docs/research/05-aee-prior-art.md - working config-override and probe patterns.
- docs/research/06-arma3-colour-surface.md - which config classes can be overridden.
- docs/research/07-mod-quality-standards.md - the quality bar for a modern Arma 3 mod.
- docs/research/08-example-mods.md - structure and QA from example mods.
