# Modern Arma 3 mod quality standards (CBA_A3, ACE3, ACRE2)

Source of record for the quality bar this project aims at. Inspected `master` branches on
2026-10-11.

## Headline: none run SQF tests in CI

| | SQF tests | Native-ext tests | CI test job |
|---|---|---|---|
| CBA_A3 | per-component `test.sqf` + `CBA_fnc_test` | none | no |
| ACE3 | `ACE_Tests` config + `ace_common_fnc_runTests` | Rust via tarpaulin | **Rust only** |
| ACRE2 | `addons/api/fnc_tests.sqf` | C++ tests, not run | no |

So the shared floor for SQF is an in-engine runner invoked manually from the debug console. Adding
one CI-executed SQF tier would put us **above** all three. That is the intended target.

## In-engine runner idioms worth copying

- **Discovery list** so the runner needs no edits when a test is added:
  - CBA generates `TESTS [ ... ]` per component from `test_*.sqf` files.
  - ACE3 declares a config class and iterates it:
    ```cpp
    class ACE_Tests {
        vehicleTransportInventory = QPATHTOF(dev\test_vehicleInventory.sqf);
        mapConfigs = QPATHTOF(dev\test_mapConfigs.sqf);
        cfgPatches = QPATHTOF(dev\test_cfgPatches.sqf);
    };
    ```
- **`true`-on-pass return value**, aggregated into a `[passed / total]` count with a `Failed:` list.
- **Macro-based assertion helper** (`ASSERT_STRING`/`ASSERT_BOOL`/`ASSERT_TYPE`, or CBA's `TEST_*`).

We get CBA's runner for free. For a discovery list we will declare an `A3ACC_Tests` config class and
iterate it, matching the ACE3 shape.

## Consolidated checklist (what "modern" means)

**Build**
- `.hemtt/project.toml` with `name`, `prefix`, `mainprefix`, `author`, `[files] include`, `[version] git_hash = 0`.
- `hemtt build` on Linux in CI for PRs; Windows + Arma 3 Tools only for a binarised release build.
- Publish `.hemttout/@<mod>` as a CI artifact (`include-hidden-files: true`).
- `$PBOPREFIX$` per addon and an addon skeleton for new components.

**Lint**
- `.editorconfig`: lf, utf-8, 4-space indent, trim trailing whitespace (YAML `indent_size = 2`).
- `.hemtt/lints.toml`: enable `sqf.undefined` and `sqf.not_private`; release-only `sqf.banned_macros`
  for `DEBUG_MODE_FULL`, `DISABLE_COMPILE_CACHE`, `ENABLE_PERFORMANCE_COUNTERS`.
- `config_style_checker.py` + `sqf_validator.py` in CI; add `sqflint` as advisory only (ACRE2 runs
  it with `continue-on-error: true` because of false positives); `bom-check` and a stringtable validator.

**Tests**
- In-engine runner reachable from the debug console; test files return `true`/`false`.
- At least one CI-executed tier (we will add SQF-VM pure-function tests and config assertions).

**Docs**
- Function-header lint (`docs/tools/document_functions.py --debug` style) and a docs deploy job.
- `docs/wiki/development/`: coding guidelines, branching and release, modularity, merge process.

**Contribution**
- `.github/CONTRIBUTING.md`, `.github/PULL_REQUEST_TEMPLATE.md` with a title convention
  (`Component - Add|Fix|Improve|Change|Make|Remove {...}`) and a guidelines link.
- Merge gate: maintainer approval plus required CI checks.

**Release**
- Semver `MAJOR.MINOR.PATCH.BUILD`; a HEMTT version hook stamping `mod.cpp`/`script_version.hpp`;
  a `post_release` zip-rename hook; `release-drafter` for the changelog. Signing keys only where
  required (ACRE2 signs extensions for BattlEye; PBO signing keys absent in all three).

## What this project will adopt

1. `.editorconfig` and `.hemtt/lints.toml` with `sqf.undefined`, `sqf.not_private`, and release
   `sqf.banned_macros`.
2. CI: `arma-actions/hemtt@v1` + `hemtt check -p -e` + `hemtt build`, upload artifact.
3. In-engine `test.sqf` per component using CBA's `TEST_*` macros, plus an `A3ACC_Tests` config
   class as the discovery list.
4. Offline SQF-VM tests for the pure mode-to-colour mapping function (a tier none of the three has).
5. `CONTRIBUTING.md` and a PR template with the title convention.

## UNVERIFIED

- CBA "Submitting Content Guidelines" wiki content (404 at the raw wiki path).
- ACRE2 `release.yml` FTP publish tail (truncated).
- `acre2/acre2` repo (404); `IDI-Systems/acre2` is live.
