# Prior art: AEE colour/UI override surface and in-engine probe harness

`/ext/Development/AEE` is an existing workspace mod that already overrides the colour-related
engine config classes and runs a Docker headless-server probe suite. Reuse this surface and test
method rather than reinvent them.

## 1. CfgMarkerColors override

`/ext/Development/AEE/addons/symbology/config.cpp:81-90`

```cpp
class CfgMarkerColors {
    // The vanilla Default parent is in ui_f; restate it so name and scope survive.
    class Default;
    class ColorAEE: Default { scope = 1; color[] = {1, 1, 1, 1}; };
    class ColorWEST: Default { color[] = {0, 1, 1, 1}; };
    class ColorEAST: Default { color[] = {1, 0, 0, 1}; };
    class ColorGUER: Default { color[] = {0, 1, 0, 1}; };
    class ColorCIV: Default { color[] = {1, 0, 1, 1}; };
    class ColorUNKNOWN: Default { color[] = {1, 1, 0, 1}; };
};
```

Rules:

- Forward-declare the engine base (`class Default;`) and inherit it (`: Default`). A child that
  names `: Default` keeps the engine's inherited `scope`, so the marker-colour picker builds.
- Only `scope` and `color[]` (4-element RGBA) are set. No `name`, `side`, `aiRgbValue`.
- Alpha is element index 3.

## 2. RscStructuredText / map tooltip override

`/ext/Development/AEE/addons/cartography/config.cpp:81-105`

```cpp
class RscControlsGroupNoScrollbars;
class RscText;
class RscStructuredText;
class RscMapControlTooltip: RscControlsGroupNoScrollbars {
    class Controls {
        class Background: RscText { colorBackground[] = {0, 0, 0, 0}; };
        class InfoBackground: RscStructuredText { colorBackground[] = {0, 0, 0, 0}; };
        class Info: RscStructuredText { colorText[] = {0, 0, 0, 0}; };
        class AssetsBackground: RscStructuredText { colorBackground[] = {0, 0, 0, 0}; };
        class Assets: RscStructuredText { colorText[] = {0, 0, 0, 0}; };
        class PictureBackground: RscText { colorBackground[] = {0, 0, 0, 0}; };
    };
};
```

The engine draws the cursor tooltip in closed C++ after the map Draw event, so scripting loses
the race; neutralise its colours at config instead. Also in that file: `RscMapControl` sets
`colorGrid[]`/`colorGridMap[]` and `sizeExGrid`.

## 3. Engine override rules (from AEE's engine docs)

`/ext/Development/AEE/docs/engine/engine-override-surface.md` and `engine-config-surface.md`.

- `class X : Y` is the only way to override a vanilla class and keep inherited fields.
- **Bare-reopen trap:** `class X { ... }` with no `: Y` makes the engine log
  `Updating base class '<parent>'->''` and X loses `scope`, `size`, `drawStyle`, `markerClass`,
  `texture`. Restate the real parent. Inverse: parentless vanilla classes must be reopened bare.
- **Forward declaration** must sit at the same scope as the user. A file-root forward declaration
  creates an empty class and re-parents existing entries onto it (HEMTT `L-C03`/`L-C04`).
- Last-loaded-wins, per property not per class. Over an undeclared mod, mod-list order decides.
  Class names are case-insensitive. Parent must precede child within a file.
- Ceilings: no hypsometric tint ramp, no renderer/post-process hook, marker texture aspect not
  preserved (T170754), `drawStyle` is a fixed enum, satellite raster baked per world.

Relevant reachable classes: `CfgMarkerColors` (`color[], name, scope`, ceiling none),
`CfgMarkers` (`name, icon, texture, color[], size, shadow, scope, markerClass,
showEditorMarkerColor`), `CfgMarkerClasses` (grouping only), `RscMapControl` (all map palette
fields), `CfgLocationTypes`, `CfgFontFamilies` (asset-gated on `.fxy`/`.paa` glyphs).

## 4. In-engine probe harness (Docker, headless)

`/ext/Development/AEE/tests/docker/` runs the Arma 3 Linux dedicated server:

- Image `ghcr.io/brettmayson/arma3server/arma3server:v3`, `network_mode: host`,
  params `-autoInit -noBattlEye -mod=mods/@aee;mods/@cba_a3`.
- `mission = "aee_test.Stratis"` from `config.toml`.
- Each `missions/<world>/` has `mission.sqm`, `description.ext`, `init.sqf`, ~80 `*_probe.sqf`.
- `init.sqf` runs phases then `execVM`s each probe under `CBA_fnc_waitAndExecute`, ending with
  `diag_log text "[AEE-TEST] DONE";` after a delay. `execVM` not `exec` (preprocesses + compiles).
- `verify.py` parses the server log: matches `[PHASE\d+] [PASS|FAIL]`, requires `[AEE-TEST] DONE`,
  fails on any `Error`/`Warning` outside a benign allowlist, and explicitly requires each probe's
  `[Pnnn] [PASS]` and forbids its `[Pn] [FAIL]`. Exit 0 only when clean.
- `tools/docker_test.sh` builds PBOs with `hemtt build`, assembles `@aee`, fetches CBA v3.19.0,
  runs `docker compose`.

Probe pattern (copy-ready), asserting against the live merged config:

```sqf
private _pass = 0; private _fail = 0; private _notes = [];
private _scope = getNumber (configFile >> "CfgMarkerColors" >> _x >> "scope");
if (_scope > 0) then { _pass = _pass + 1; } else { _fail = _fail + 1; };
private _rstColor = getArray (configFile >> "RscStructuredText" >> "colorText");
if ((count _rstColor) >= 4) then { /* ... */ };
if (_fail == 0) then {
    diag_log text format ["[P124] [PASS] ... (%1 checks)", _pass];
} else {
    diag_log text format ["[P124] [FAIL] ...: %1 passed, %2 failed: %3", _pass, _fail, str _notes];
};
```

`(count _arr) >= 4` also catches the file-root forward-declaration trap.

## 5. CI wiring

AEE's `.github/workflows/ci.yml` `build` job uses `arma-actions/hemtt@v1` and runs
`tools/hemtt.sh check -p -e`, `build`, `release`. `.github/workflows/docker-test.yml` runs the
Docker suite on a **self-hosted** runner, triggered by `schedule` and `workflow_dispatch` only
(never push/PR: a public repo must not run untrusted code on a self-hosted runner).

## 6. What to adopt

1. Copy the `CfgMarkerColors` block (forward-declare `Default`, inherit, set only `scope`+`color[]`).
2. Copy the `RscMapControlTooltip` / `RscStructuredText` override, mindful of the forward-decl
   scope trap.
3. Copy the probe pattern (`_pass`/`_fail`/`_notes`, `configFile` queries, alpha at index 3,
   terminal `[Pnnn] [PASS|FAIL]`).
4. Reuse the Docker headless harness shape (`init.sqf` + probes + `verify.py` + `docker_test.sh`).
5. Wire CI: `hemtt check -p -e` on push; Docker suite on a scheduled self-hosted job.

Note: AEE's harness needs an Arma 3 dedicated server root and Docker; adapt rather than copy
wholesale. This project will start with CBA `CBA_fnc_test` (no Docker) and add the Docker soak
harness later if needed. See `docs/research/03-testing.md`.
