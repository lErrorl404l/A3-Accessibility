# Arma 3 addon testing: tooling and strategy

Source of record for this project's test plan. Research date 2026-10-11.

## 1. The headline: CBA ships a unit-test framework

CBA_A3 contains `CBA_fnc_test`, which "Runs unit tests for an addon or component". It execs
`\x\<addon>\addons\<component>\test.sqf` and waits for completion.

```
[] call CBA_fnc_test;                     // whole addon
[nil, "colourblind"] call CBA_fnc_test;   // one component
```

Assertion macros live in CBA's `addons/main/script_macros_common.hpp` (already reachable via
our include stub): `TEST_SUCCESS`, `TEST_FAIL`, `TEST_TRUE`, `TEST_FALSE`, `TEST_OP(a,op,b,msg)`,
`TEST_DEFINED`, and the `ASSERT_*` variants; helpers `LOG`, `ERROR`. Results go to the RPT via
`diag_log` (`CBA_fnc_log` / `CBA_fnc_error`).

Per-component entry point pattern (CBA's own `addons/diagnostic/test.sqf`):

```sqf
#include "script_component.hpp"
#define TESTS ["assertions", "parameters"]
{
    private _test = execVM format ["\x\a3acc\addons\colourblind\test_%1.sqf", _x];
    waitUntil { scriptDone _test };
} forEach TESTS;
```

Config assertion pattern (CBA's `addons/common/test_config.sqf`):

```sqf
_class  = configFile >> "CfgMarkerColors" >> "A3ACC_ColorFriendly";
_value  = getArray (_class >> "color");
TEST_OP(str _value, ==, str [0,0.6,1,1], "friendly colour");
```

Because CBA is already a dependency, this test layer adds no new dependency, only test files.

Sources: <https://github.com/CBATeam/CBA_A3/blob/master/addons/diagnostic/fnc_test.sqf>,
<https://github.com/CBATeam/CBA_A3/blob/master/addons/common/test_config.sqf>

## 2. What is observable and testable

| Observable | Query | Proves |
|---|---|---|
| Setting value | `[_name] call CBA_settings_fnc_get` | Setting registered and holds expected value |
| Config array | `getArray (configFile >> ... >> "color")` | The override survived preprocess + rapify as intended |
| Palette global | `missionNamespace getVariable ["A3ACC_palette", []]` | Mode-to-colour mapping produced the right palette |
| Mapping function | call the pure function, assert return | The algorithm is correct for every mode |
| Log line | `diag_log` in the RPT | A code path ran |

Not observable: the rendered pixel colour. Assert the input that drives rendering (setting,
palette global, config array), not the output.

## 3. Layered strategy

| Layer | Runner | Proves | Does not prove |
|---|---|---|---|
| 1. Static lint | `hemtt check -p -e`, optional `sqflint` | Config/SQF parse; no missing files, invalid values, unknown commands/events, version mismatch, duplicate classes | Any runtime behaviour |
| 2. Config assertions | `hemtt check` + CBA `TEST_TRUE` on `configFile` queries | Config classes and values survive preprocessing and rapify | Game load; runtime palette correctness |
| 3a. Offline unit test | SQF-VM (`SQFvm/runtime`) on the pure mapping function | The mapping algorithm is right for all modes; runs in CI without the game | Anything engine-bound (settings, config, UI, events) |
| 3b. In-engine smoke | `CBA_fnc_test` with `test.sqf` | Setting registers, `CBA_settings_fnc_get` returns correct value, palette global and mapping correct inside the real engine | The rendered colour; user interaction with the dropdown |
| 4. Manual QA | `hemtt launch` / Eden; change setting in CBA menu; eyeball colours; check RPT | The UI works and colours render without error | Nothing; not repeatable |

Highest-value automated test: write the mode-to-colour mapping as a **pure function**
(mode + class -> RGBA array) so both SQF-VM (CI) and CBA `TEST_OP` (in-engine) can test it
directly.

## 4. HEMTT lints (the static layer)

`hemtt check` flags: `-p/--pedantic`, `-e/--error-on-all`, `-L/--lints`, `-t/--threads`, `-v`.
Lints are configured in `project.toml` `[lints]` or `.hemtt/lints.toml`; each can be disabled
or re-severitied; critical lints cannot be disabled. SQF lints `L-S01`..`L-S38`, config lints
`L-C01`..`L-C19`, preprocessor `PW1`..`PW3`. The `L-S17` all-caps warning we hit is
`var_all_caps` (undefined-macro suspect) - now resolved by defining the macros.

Sources: <https://hemtt.dev/commands/check.html>, <https://hemtt.dev/lints/sqf.html>,
<https://hemtt.dev/lints/config.html>, <https://hemtt.dev/configuration/lints.html>

## 5. CI

`arma-actions/hemtt@v1` installs HEMTT. ACE3's `arma.yml` runs `python3 tools/config_style_checker.py`,
`stringtable_validator.py`, `check_strings.py`, `arma-actions/bom-check@master`, then
`arma-actions/hemtt@v1` + `hemtt build` + `actions/upload-artifact`. No maintained action runs
the Arma 3 client in CI, so layers 3b and 4 stay manual; layers 1, 2 and 3a run in CI.

Sources: <https://github.com/arma-actions/hemtt>,
<https://github.com/acemod/ACE3/blob/master/.github/workflows/arma.yml>

## 6. Corrections and open items

- The CBA setting-changed event name was flagged UNVERIFIED here, but is confirmed as
  `CBA_SettingChanged` (singular) by `docs/research/02-cba-and-tooling.md`.
- ACE3 has no in-engine test framework (verified: no `tests/` folder, no `fnc_test`). CBA is
  the in-engine test host.
- `dedmen/arma-action` is NOT FOUND; `arma-actions/hemtt@v1` is the maintained action.
- SQF-VM exact CLI flags and its full unsupported-command list: UNVERIFIED until checked with
  `help__` against a built binary.

## 7. AEE's purpose-built SQF harness (a fourth option)

`/ext/Development/AEE/tools/tests/sqf_lite.py` is a minimal SQF interpreter written in Python.
It exists because a hand-transcribed Python mirror of the SQF "replicated the SQF's bugs AND
drifted from the source". Its stated rule: **if a test cannot execute the SQF, it is not testing
the mod.** It parses and evaluates a documented subset (assignments, `if/then/else`, `for`,
`params`, arithmetic, comparison, `&&`/`||`/`!`, `max`/`min`, `select`, `call`, `forEach`,
`findIf`, `while`, `parseSimpleArray`, `format`, `str`, `vector*`, `count`, `abs`, `floor`, `sqrt`,
trig) and injects engine commands through a `globals` dict.

This is the strongest option for testing the pure mode-to-colour mapping: write the mapping in
SQF, run the **actual file** under `sqf_lite.py` in CI, and also assert it in-engine with CBA's
`TEST_*` macros. No game required for the fast tier.

AEE also ships `tools/sqfvmChecker.py` (SQF-VM with virtual paths read from `.hemtt/project.toml`)
and uses Python validators `sqf_validator.py` / `config_style_checker.py`. `sqflint`
(LordGolias/sqf, PyPI `sqflint`) is the community linter; ACRE2 runs it with `continue-on-error`
because of false positives, so treat it as advisory.

Decision: our pure-function test tier will use `sqf_lite.py`-style harness execution of the real
SQF (adapt AEE's interpreter or vendor it), plus the in-engine CBA tier. SQF-VM is a fallback.
