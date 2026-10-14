#!/usr/bin/env python3
"""Offline gate for the gunfire sound cue's respawn shape.

The cue is built by `addons/hearing/functions/fnc_soundCue.sqf` and enabled by
the `A3ACC_SoundCues` setting in `addons/hearing/initSettings.inc.sqf`. The cue
is client-local: a dedicated server has no player, so `isNull player` exits
before any cue code runs. No server test can observe the cue, so this gate
proves the SHAPE the respawn fix rests on, with no game and no SQF interpreter.

The defect this gate closes: the `FiredNear` handler was added on the player
unit and its id was kept in one global, `A3ACC_soundCueHandle`. A respawn
replaces the unit and drops its handlers, but the global stayed set, so the
`isNil` guard blocked a re-add and the disable path removed a stale id from the
new unit. The cue stopped working after a respawn with no error.

The assertions:

1. THE CLIENT GUARD STAYS. The function still exits on `isNull player`.
2. NO STALE GLOBAL HANDLE. `A3ACC_soundCueHandle` is gone.
3. THE HANDLE LIVES ON THE UNIT. The `FiredNear` id is stored per unit in
   `A3ACC_soundCueEH`, so a respawn cannot leave it stale.
4. THE PLAYER EVENT HANDLER IS SYMMETRIC. It is added in the enabled branch with
   `CBA_fnc_addPlayerEventHandler` on the `"unit"` event and removed in the else
   branch with `CBA_fnc_removePlayerEventHandler`.
5. THE HANDLER MOVES FROM THE OLD UNIT. The unit handler removes the `FiredNear`
   handler from `_oldPlayer`.
6. THE NEW UNIT IS ARMED ONCE. The unit handler adds the `FiredNear` handler to
   `_newPlayer` behind the per-unit `isEqualTo -1` guard.
7. THE RE-ENABLE GUARD IS NOT STALE. The enabled guard tests the player event
   handler, not a handle that survives the unit.
8. THE DISABLE PATH REMOVES FROM THE HOLDER. It reads the id from `player` and
   removes it from `player`, the unit that holds it after a respawn.
9. THE FRAME HANDLER IS SYMMETRIC. It is added once and removed once, and the
   remove clears the id.
10. THE CUE ITSELF IS UNCHANGED. The label, the two-second life and the cap of
    twelve are the shipped ones.
11. THE SETTING IS UNCHANGED. The name, the type and the default are the shipped
    ones, and the callback still calls `FUNC(soundCue)`.

Every property above carries mutation evidence. Run with `--self-test` and the
gate mutates the source for each check, then asserts the check fails. A check
that cannot fail is caught here rather than in the field.

It proves SHAPE ONLY. The cue itself needs a client: only a real interface can
show that a shot draws a cue, and only a respawn can show that it still does.
Exit code 0 means every shape assertion passes.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path
from typing import Callable

ROOT = Path(__file__).resolve().parent.parent
FUNCTION = ROOT / "addons" / "hearing" / "functions" / "fnc_soundCue.sqf"
SETTINGS = ROOT / "addons" / "hearing" / "initSettings.inc.sqf"

# The client-local guard.
PLAYER_GUARD_RE = re.compile(r"if\s*\(\s*isNull\s+player\s*\)\s*exitWith")

# The symmetric player event handler pair, and its event.
PLAYER_ADD_RE = re.compile(r"\bCBA_fnc_addPlayerEventHandler\b")
PLAYER_REMOVE_RE = re.compile(r"\bCBA_fnc_removePlayerEventHandler\b")
UNIT_EVENT_RE = re.compile(r'\[\s*"unit"\s*,')

# The enabled guard. It must test the player event handler, never a handle that
# survives the unit.
REENABLE_GUARD_RE = re.compile(r'if\s*\(\s*isNil\s+"A3ACC_soundCuePlayerEH"\s*\)')

# The stale global the defect left behind, and the per-unit handle that replaces
# it.
STALE_HANDLE = "A3ACC_soundCueHandle"
UNIT_HANDLE = '"A3ACC_soundCueEH"'

# The frame handler pair.
PFH_ADD_RE = re.compile(r"\bCBA_fnc_addPerFrameHandler\b")
PFH_REMOVE_RE = re.compile(r"\bCBA_fnc_removePerFrameHandler\b")

# The shipped cue body.
CUE_LABEL = '"GUNFIRE %1 m"'
CUE_LIFE = "diag_tickTime + 2"
CUE_CAP = "> 12"

Texts = dict[str, str]


def branch_pair(text: str) -> tuple[str, str]:
    """Split the `if (_enabled) then { ... } else { ... }` branches.

    The enabled block holds no inner `} else {`, so the setting pair is the only
    one. Return two empty strings when the pair is absent, so a structural
    mutation is reported by the checks rather than aborting the run.
    """
    marker = "} else {"
    if "if (_enabled) then {" not in text or marker not in text:
        return "", ""
    then_branch, rest = text.split("if (_enabled) then {", 1)[1].rsplit(marker, 1)
    return then_branch, rest


def check_client_guard(texts: Texts) -> list[str]:
    if PLAYER_GUARD_RE.search(texts["fn"]) is None:
        return ["the cue does not exit on `isNull player`, so it runs on a server"]
    return []


def check_no_stale_handle(texts: Texts) -> list[str]:
    if STALE_HANDLE in texts["fn"]:
        return [
            f"the stale global {STALE_HANDLE} is present, so a respawn leaves it "
            "set and the guard blocks a re-add"
        ]
    return []


def check_handle_on_unit(texts: Texts) -> list[str]:
    fn = texts["fn"]
    failures: list[str] = []
    if f"setVariable [{UNIT_HANDLE}" not in fn:
        failures.append(
            f"the FiredNear id is not stored on the unit with setVariable {UNIT_HANDLE}"
        )
    if f"getVariable [{UNIT_HANDLE}" not in fn:
        failures.append(
            f"the FiredNear id is not read from the unit with getVariable {UNIT_HANDLE}"
        )
    return failures


def check_player_eh_symmetric(texts: Texts) -> list[str]:
    fn = texts["fn"]
    then_branch, else_branch = branch_pair(fn)
    failures: list[str] = []
    add_count = len(PLAYER_ADD_RE.findall(fn))
    remove_count = len(PLAYER_REMOVE_RE.findall(fn))
    if PLAYER_ADD_RE.search(then_branch) is None:
        failures.append("the enabled branch does not add the player event handler")
    if PLAYER_REMOVE_RE.search(else_branch) is None:
        failures.append("the disable branch does not remove the player event handler")
    if add_count != 1 or remove_count != 1:
        failures.append(
            f"the player event handler is added {add_count} times and removed "
            f"{remove_count} times, so the pair is not symmetric"
        )
    return failures


def check_unit_event(texts: Texts) -> list[str]:
    then_branch, _ = branch_pair(texts["fn"])
    if UNIT_EVENT_RE.search(then_branch) is None:
        return ['the added player event handler is not on the "unit" event']
    return []


def check_moves_from_old_unit(texts: Texts) -> list[str]:
    then_branch, _ = branch_pair(texts["fn"])
    if '_oldPlayer removeEventHandler ["FiredNear"' not in then_branch:
        return [
            "the unit handler does not remove the FiredNear handler from the old unit"
        ]
    return []


def check_arms_new_unit(texts: Texts) -> list[str]:
    then_branch, _ = branch_pair(texts["fn"])
    failures: list[str] = []
    if '_newPlayer addEventHandler ["FiredNear"' not in then_branch:
        failures.append(
            "the unit handler does not add the FiredNear handler to the new unit"
        )
    if (
        re.search(
            r'\(_newPlayer getVariable \["A3ACC_soundCueEH", -1\]\) isEqualTo -1',
            then_branch,
        )
        is None
    ):
        failures.append(
            "the new unit is not armed behind the per-unit `isEqualTo -1` guard"
        )
    return failures


def check_reenable_guard(texts: Texts) -> list[str]:
    if REENABLE_GUARD_RE.search(texts["fn"]) is None:
        return [
            "the enabled guard does not test `isNil A3ACC_soundCuePlayerEH`, so a "
            "value that survives the unit can block a re-add"
        ]
    return []


def check_disable_removes_from_holder(texts: Texts) -> list[str]:
    _, else_branch = branch_pair(texts["fn"])
    failures: list[str] = []
    if 'player getVariable ["A3ACC_soundCueEH", -1]' not in else_branch:
        failures.append(
            "the disable branch does not read the FiredNear id from the player"
        )
    if 'player removeEventHandler ["FiredNear", _handler]' not in else_branch:
        failures.append(
            "the disable branch does not remove the FiredNear handler from the player"
        )
    return failures


def check_pfh_symmetric(texts: Texts) -> list[str]:
    fn = texts["fn"]
    _, else_branch = branch_pair(fn)
    failures: list[str] = []
    add_count = len(PFH_ADD_RE.findall(fn))
    remove_count = len(PFH_REMOVE_RE.findall(fn))
    if add_count != 1 or remove_count != 1:
        failures.append(
            f"the frame handler is added {add_count} times and removed {remove_count} times"
        )
    if "A3ACC_soundCuePFH = nil" not in else_branch:
        failures.append("the disable branch does not clear the frame handler id")
    return failures


def check_cue_body(texts: Texts) -> list[str]:
    fn = texts["fn"]
    failures: list[str] = []
    if CUE_LABEL not in fn:
        failures.append("the cue label is not the shipped `GUNFIRE %1 m`")
    if CUE_LIFE not in fn:
        failures.append("the cue life is not the shipped two seconds")
    if CUE_CAP not in fn:
        failures.append("the cue list cap is not the shipped twelve")
    return failures


def setting_block(settings: str) -> str:
    """Return the body of the `A3ACC_SoundCues` setting, up to its registration."""
    marker = '"A3ACC_SoundCues"'
    if marker not in settings:
        return ""
    return settings.split(marker, 1)[1].split("call CBA_fnc_addSetting;", 1)[0]


def check_setting(texts: Texts) -> list[str]:
    block = setting_block(texts["settings"])
    if not block:
        return ["the A3ACC_SoundCues setting is absent from initSettings.inc.sqf"]
    failures: list[str] = []
    if '"CHECKBOX"' not in block:
        failures.append("the sound cue setting is no longer a CHECKBOX")
    if re.search(r"^\s*false,\s*$", block, re.M) is None:
        failures.append("the sound cue setting default is no longer false")
    if "FUNC(soundCue)" not in block:
        failures.append("the sound cue setting no longer calls FUNC(soundCue)")
    return failures


CHECKS: list[tuple[str, Callable[[Texts], list[str]]]] = [
    ("client_guard", check_client_guard),
    ("no_stale_handle", check_no_stale_handle),
    ("handle_on_unit", check_handle_on_unit),
    ("player_eh_symmetric", check_player_eh_symmetric),
    ("unit_event", check_unit_event),
    ("moves_from_old_unit", check_moves_from_old_unit),
    ("arms_new_unit", check_arms_new_unit),
    ("reenable_guard", check_reenable_guard),
    ("disable_removes_from_holder", check_disable_removes_from_holder),
    ("pfh_symmetric", check_pfh_symmetric),
    ("cue_body", check_cue_body),
    ("setting", check_setting),
]


def run_checks(texts: Texts) -> dict[str, list[str]]:
    return {name: check(texts) for name, check in CHECKS}


def mutate(key: str, old: str, new: str) -> Callable[[Texts], Texts]:
    """Return a mutation that rewrites one fragment of one source file."""

    def apply(texts: Texts) -> Texts:
        if old not in texts[key]:
            raise SystemExit(f"FAIL: mutation anchor {old!r} is absent from {key}")
        return {**texts, key: texts[key].replace(old, new)}

    return apply


# One mutation per assertion. Each removes or corrupts exactly the fact its
# check rests on. `--self-test` applies each and asserts its check then fails.
MUTATIONS: list[tuple[str, Callable[[Texts], Texts]]] = [
    ("client_guard", mutate("fn", "if (isNull player) exitWith {};", "")),
    (
        "no_stale_handle",
        mutate(
            "fn",
            'if (isNil "A3ACC_soundCuePlayerEH") then {',
            'A3ACC_soundCueHandle = 0;\n    if (isNil "A3ACC_soundCuePlayerEH") then {',
        ),
    ),
    (
        "handle_on_unit",
        mutate(
            "fn",
            'setVariable ["A3ACC_soundCueEH"',
            'setVariable ["A3ACC_soundCueUnitEH"',
        ),
    ),
    (
        "player_eh_symmetric",
        mutate(
            "fn",
            '["unit", A3ACC_soundCuePlayerEH] call CBA_fnc_removePlayerEventHandler;',
            "",
        ),
    ),
    (
        "unit_event",
        mutate(
            "fn",
            'A3ACC_soundCuePlayerEH = ["unit", {',
            'A3ACC_soundCuePlayerEH = ["weapon", {',
        ),
    ),
    (
        "moves_from_old_unit",
        mutate("fn", '_oldPlayer removeEventHandler ["FiredNear", _stale];', ""),
    ),
    (
        "arms_new_unit",
        mutate(
            "fn",
            '_newPlayer addEventHandler ["FiredNear", {',
            'player addEventHandler ["FiredNear", {',
        ),
    ),
    (
        "reenable_guard",
        mutate(
            "fn",
            'if (isNil "A3ACC_soundCuePlayerEH") then {',
            'if (isNil "A3ACC_soundCueStaleGuard") then {',
        ),
    ),
    (
        "disable_removes_from_holder",
        mutate(
            "fn",
            'private _handler = player getVariable ["A3ACC_soundCueEH", -1];',
            'private _handler = objNull getVariable ["A3ACC_soundCueEH", -1];',
        ),
    ),
    (
        "pfh_symmetric",
        mutate("fn", "[A3ACC_soundCuePFH] call CBA_fnc_removePerFrameHandler;", ""),
    ),
    ("cue_body", mutate("fn", CUE_CAP, "> 13")),
    ("setting", mutate("settings", '"A3ACC_SoundCues"', '"A3ACC_SoundCue"')),
]


def load_texts() -> Texts:
    return {
        "fn": FUNCTION.read_text(encoding="utf-8"),
        "settings": SETTINGS.read_text(encoding="utf-8"),
    }


def self_test(texts: Texts) -> int:
    """Prove every check can fail: mutate each fact and assert its check fires."""
    failures: list[str] = []
    print("Mutation evidence (each property must fail under its mutation):")
    for name, apply in MUTATIONS:
        mutated = apply(texts)
        results = run_checks(mutated)
        caught = bool(results[name])
        first = results[name][0] if results[name] else ""
        status = "caught" if caught else "MISSED"
        print(f"  {name:28s} {status}" + (f": {first}" if caught else ""))
        if not caught:
            failures.append(f"mutation {name!r} was not caught by its own check")

    if failures:
        print("\nFAILURES:")
        for failure in failures:
            print(f"  - {failure}")
        return 1
    print(
        f"\n[verify_sound_cue] SELF-TEST PASS: all {len(MUTATIONS)} mutations are "
        "caught, so every asserted property can fail"
    )
    return 0


def main() -> int:
    texts = load_texts()
    if "--self-test" in sys.argv[1:]:
        return self_test(texts)

    failures: list[str] = []
    results = run_checks(texts)
    for name, check_failures in results.items():
        failures.extend(check_failures)

    then_branch, else_branch = branch_pair(texts["fn"])
    print(f"Function: {FUNCTION.relative_to(ROOT)}")
    print(f"Setting:  {SETTINGS.relative_to(ROOT)}")
    print(
        f"isNull player guard present: {PLAYER_GUARD_RE.search(texts['fn']) is not None}"
    )
    print(f"Stale global {STALE_HANDLE} absent: {STALE_HANDLE not in texts['fn']}")
    print(f"Per-unit handle {UNIT_HANDLE} used: {UNIT_HANDLE in texts['fn']}")
    print(
        "Player event handler: add "
        f'{len(PLAYER_ADD_RE.findall(texts["fn"]))} on "unit", remove '
        f"{len(PLAYER_REMOVE_RE.findall(texts['fn']))}"
    )
    print(
        "Old-unit teardown and new-unit arm: "
        f"{'_oldPlayer removeEventHandler ["FiredNear"' in then_branch} / "
        f"{'_newPlayer addEventHandler ["FiredNear"' in then_branch}"
    )
    print(
        "Disable removes from the holder: "
        f"{'player removeEventHandler ["FiredNear", _handler]' in else_branch}"
    )
    print(
        f"Frame handler: add {len(PFH_ADD_RE.findall(texts['fn']))}, "
        f"remove {len(PFH_REMOVE_RE.findall(texts['fn']))}"
    )

    if failures:
        print("\nFAILURES:")
        for failure in failures:
            print(f"  - {failure}")
        return 1

    print(
        "\n[verify_sound_cue] PASS: the cue still exits on isNull player, the stale "
        "global is gone, the FiredNear id lives on the unit, the player event "
        'handler is added on "unit" and removed symmetrically, the handler moves '
        "from the old unit and arms the new one once, the enabled guard cannot go "
        "stale, the disable path removes from the holder, the frame handler is "
        "symmetric, the cue body and the setting are unchanged. SHAPE ONLY: the cue "
        "itself needs a client."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
