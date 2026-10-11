# Example mods: A3SQL and DISP

Reference for structure, tests and QA from two real Arma 3 mods by the same author.

## A3SQL: a small mod done seriously

- HEMTT, single version source via `.hemtt/project.toml` `[version] path = "addons/main/script_version.hpp"`
  with `git_hash = 0`. `[files] include` carries `mod.cpp`, `meta.cpp`, `LICENSE`, `logo_*.paa`.
  `$PBOPREFIX$` files are `z\a3sql\addons\<name>`. `CfgPatches.requiredAddons[] = {"cba_main","cba_xeh"}`.
- 11 addons, the standard CBA shape per addon: `$PBOPREFIX$`, `config.cpp`, `script_component.hpp`,
  `CfgEventHandlers.hpp`, `XEH_PREP.hpp`, `XEH_preStart/PreInit/PostInit.sqf`, `functions/fnc_*.sqf`,
  plus `initSettings.inc.sqf` and `stringtable.xml` where settings exist.
- Shared macro layer in `addons/main/`: `script_{component,macros,mod,version}.hpp`.

### Tests: four levels

1. In-engine assertion smoke test `tests/a3sql_smoke_test.sqf`: `_pass`/`_fail`, a `_test` code block
   that runs the function and compares the return code, `diag_log text format ["[A3SQL] OK ..."]`.
2. Debug-console script at `.hemtt/missions/test.VR/a3sql_test.sqf`, run by the HEMTT launch profile.
3. Per-addon dev probes `tests/dev/test_*.sqf` (log only, no assertions).
4. Headless Docker end-to-end: `tests/docker/` with `docker-compose.yml`, `entrypoint.sh`, a mission,
   and `verify.py` that greps `[PHASE\d+]`, `[FAIL]`, a `TEST END` marker and `Error in expression`,
   exiting non-zero on any failure.

Plus Rust tests for its extension (not relevant to us).

### QA/CI

- `.github/workflows/ci.yml`: core Rust job via an org reusable workflow, Linux/Windows extension builds,
  `build-addon` that installs HEMTT, caches `~/.hemtt/cache`, and builds.
- `lint.yml`: `cargo-deny`, `cargo-machete`. `test.yml`: `cargo miri test`.
- `docker-test.yml`: `workflow_dispatch` only (needs an Arma 3 server install).
- `release-drafter.yml` + `.github/release-drafter.yml`, `CODEOWNERS`, `dependabot.yml`, `sbom.yml`.
- `.githooks/pre-commit` (`cargo fmt --check`, doc check, clippy, `hemtt check`); `.githooks/pre-push`
  (`cargo test`, `cargo build --release`). `CONTRIBUTING.md` sets `core.hooksPath .githooks`.
- `PULL_REQUEST_TEMPLATE.md` lists the exact commands a contributor must run.
- `tools/`: `sqf_validator.py`, `config_style_checker.py` (both ACE3-derived), `sqfvmChecker.py`,
  `search_privates.py`, `search_unused_privates.py`, `check_docs_static.py`.
- Release: publish a GitHub release -> `release` job runs `hemtt release`, uploads `releases/*.zip`;
  `sbom.yml` attaches `a3sql.cdx.json` (cites Def Stan 05-138). Signing via HEMTT with ephemeral CI keys.

## DISP: an honest minimum patch mod

A patch mod ships no feature of its own; it loads after a third-party addon and replaces behaviour
from outside. DISP does this three ways: `requiredAddons[]` forces load order;
`class CfgFunctions { class DIS { class incog { class mainLoop { recompile = 1; }; }; }; }` takes over
the parent function name and forces recompile; `XEH_postInit.sqf` watches and repairs the parent's
`addAction`.

- 2 addons (`main`, `compat`), no shared macro layer, no `script_component.hpp`, function named
  `fn_mainLoop.sqf` declared inline in `CfgFunctions`.
- No tests at all (no `tests/`, no `.hemtt/missions/`). CI is one reusable-workflow job with
  `sqf-validate/config-validate/hemtt-check/bom-check` flags. `PULL_REQUEST_TEMPLATE.md` asks for
  "Tested in-game".
- `.hemtt/scripts/check_prefixes.rhai` checks every addon has a `$PBOPREFIX$`.
- Version duplication (project.toml, `VERSION`, `script_version.hpp`, hardcoded in `config.cpp`);
  unsigned `.pbo`-only releases. Do not copy either.

## What to copy for A3-Accessibility

1. `.hemtt/project.toml` with `[version] path = "addons/main/script_version.hpp"` (one version source)
   and `[files] include` for `mod.cpp` and `meta.cpp`.
2. `.hemtt/lints.toml`: `config.cfgpatches_scope`, `sqf.undefined`, `sqf.shadowed`, `sqf.not_private`,
   and a release-only `sqf.banned_macros` list (`DEBUG_MODE_FULL`, `DISABLE_COMPILE_CACHE`,
   `ENABLE_PERFORMANCE_COUNTERS`).
3. `.hemtt/launch.toml` with a `default` profile (mission, parameters `-world=VR -skipIntro -noSplash
   -showScriptErrors`, `file_patching = true`, CBA workshop id `450814997`).
4. A tests mission plus an assertion script in the A3SQL style (`_pass`/`_fail`, `diag_log` verdicts).
   Highest-value item for a small mod.
5. `.githooks/pre-commit` (fast: validators + `hemtt check`) and `pre-push` (full build), plus the
   `core.hooksPath` line in `CONTRIBUTING.md`.
6. `tools/sqf_validator.py` and `tools/config_style_checker.py` (reuse the house copies).
7. `PULL_REQUEST_TEMPLATE.md` with a command checklist; issue templates with an environment block.
8. `release-drafter.yml` for label-driven release notes.
9. `.hemtt/scripts/check_prefixes.rhai` (from DISP) wired into CI - catches missing `$PBOPREFIX$`.
10. `dependabot.yml` for `github-actions` so pinned action SHAs stay current.

Do not copy: DISP's version duplication and unsigned `.pbo`-only releases; DISP's `CONTRIBUTORS`
file that names an agent (tool provenance must never be committed); A3SQL's `codeql.yml` placed
outside `.github/workflows/`.
