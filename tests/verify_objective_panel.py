#!/usr/bin/env python3
"""Offline gate for the objective panel's shape.

The panel is built by `addons/cognitive/functions/fnc_objectiveHud.sqf` and drawn
by `addons/cognitive/functions/fnc_objectiveHudRefresh.sqf`. Both are
client-local: a dedicated server has no player, so `isNull player` exits before
any panel code runs. No server test can observe the panel, so this gate proves
the SHAPE the fix rests on, with no game and no SQF interpreter.

The assertions:

1. THE EMPTY STATE SHOWS NOTHING. The literal `"No active task"` is absent from
   the panel code. The owner's defect was an empty dark box, and the fix removes
   the placeholder text rather than drawing it.
2. THE RESOURCE IS CUT ONLY BEHIND THE GUARD. Every `cutRsc` call in the refresh
   sits inside `if (isNil "A3ACC_objectivePFH") then { ... }`. The frame handler
   exists only while the panel is cut, so the guard keeps the two in step.
3. THE EMPTY BRANCH REMOVES THE HANDLER AND CLEARS THE CUT. The
   `_task isEqualTo ""` branch calls `CBA_fnc_removePerFrameHandler` and
   `cutText ["", "PLAIN"]`.
4. THE FUNCTION STILL EXITS ON `isNull player`. The panel is client-local, so the
   guard must stay.
5. THE PLAYER EVENT HANDLER IS SYMMETRIC. The unit handler is added in the
   enabled branch with `CBA_fnc_addPlayerEventHandler` on the `"unit"` event and
   removed in the else branch with `CBA_fnc_removePlayerEventHandler`, so a
   respawn re-arms the panel and a disable leaves no handler behind.

It proves SHAPE ONLY. The panel itself needs a client: only a real interface can
show that the box is absent and the task text is present. Exit code 0 means every
shape assertion passes.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FUNCTION = ROOT / "addons" / "cognitive" / "functions" / "fnc_objectiveHud.sqf"
REFRESH = ROOT / "addons" / "cognitive" / "functions" / "fnc_objectiveHudRefresh.sqf"

# The placeholder the empty state must not draw.
PLACEHOLDER = "No active task"

# The guard around the cut, and the cut itself.
CUT_GUARD_RE = re.compile(
    r'if\s*\(\s*isNil\s+"A3ACC_objectivePFH"\s*\)\s*then\s*\{(.*?)\}\s*;',
    re.DOTALL,
)
CUT_RE = re.compile(r"cutRsc\s*\[")

# The empty branch, and the two calls it must make.
EMPTY_BRANCH_RE = re.compile(
    r'if\s*\(\s*_task\s+isEqualTo\s+""\s*\)\s*exitWith\s*\{(.*?)\}\s*;',
    re.DOTALL,
)
REMOVE_PFH_RE = re.compile(r"\bCBA_fnc_removePerFrameHandler\b")
CLEAR_CUT_RE = re.compile(r'cutText\s*\[\s*""\s*,\s*"PLAIN"\s*\]')

# The client-local guard, and the symmetric player event handler pair.
PLAYER_GUARD_RE = re.compile(r"if\s*\(\s*isNull\s+player\s*\)\s*exitWith")
PLAYER_ADD_RE = re.compile(r"\bCBA_fnc_addPlayerEventHandler\b")
PLAYER_REMOVE_RE = re.compile(r"\bCBA_fnc_removePlayerEventHandler\b")
UNIT_EVENT_RE = re.compile(r'\[\s*"unit"\s*,')


def branch_pair(text: str) -> tuple[str, str]:
    """Split the `if (_enabled) then { ... } else { ... }` branches."""
    marker = "} else {"
    if "if (_enabled) then {" not in text or marker not in text:
        raise SystemExit(
            f"FAIL: {FUNCTION.name} has no `if (_enabled) then .. else` pair"
        )
    # The enabled block holds an inner `} else {`, so take the last pair, which is
    # the setting branch.
    then_branch, rest = text.split("if (_enabled) then {", 1)[1].rsplit(marker, 1)
    return then_branch, rest


def main() -> int:
    failures: list[str] = []
    hud = FUNCTION.read_text(encoding="utf-8")
    refresh = REFRESH.read_text(encoding="utf-8")

    # 1. The empty state shows nothing.
    if PLACEHOLDER in refresh or PLACEHOLDER in hud:
        failures.append(
            f"the placeholder {PLACEHOLDER!r} is present, so the empty state draws a box"
        )

    # 2. Every cut sits behind the frame-handler guard.
    total_cuts = len(CUT_RE.findall(refresh))
    guarded_cuts = sum(
        len(CUT_RE.findall(block)) for block in CUT_GUARD_RE.findall(refresh)
    )
    if total_cuts == 0:
        failures.append("the refresh cuts no resource, so the panel is never shown")
    if total_cuts != guarded_cuts:
        failures.append(
            f"{total_cuts} cutRsc calls, only {guarded_cuts} behind the "
            '`isNil "A3ACC_objectivePFH"` guard, so a cut can run while the '
            "frame handler is live"
        )

    # 3. The empty branch removes the frame handler and clears the cut.
    empty = EMPTY_BRANCH_RE.search(refresh)
    if empty is None:
        failures.append('the refresh has no `_task isEqualTo ""` exitWith branch')
    else:
        body = empty.group(1)
        if REMOVE_PFH_RE.search(body) is None:
            failures.append(
                "the empty branch does not call CBA_fnc_removePerFrameHandler, "
                "so the frame handler keeps running with no task"
            )
        if CLEAR_CUT_RE.search(body) is None:
            failures.append(
                'the empty branch does not clear the cut with cutText ["", "PLAIN"], '
                "so the last panel stays on screen"
            )

    # 4. The client-local guard stays.
    if PLAYER_GUARD_RE.search(hud) is None:
        failures.append(
            "the panel does not exit on `isNull player`, so it runs on a server"
        )

    # 5. The player event handler is symmetric.
    then_branch, else_branch = branch_pair(hud)
    add_count = len(PLAYER_ADD_RE.findall(hud))
    remove_count = len(PLAYER_REMOVE_RE.findall(hud))
    if PLAYER_ADD_RE.search(then_branch) is None:
        failures.append("the enabled branch does not add the player event handler")
    if UNIT_EVENT_RE.search(then_branch) is None:
        failures.append('the added player event handler is not on the "unit" event')
    if PLAYER_REMOVE_RE.search(else_branch) is None:
        failures.append("the disable branch does not remove the player event handler")
    if add_count != 1 or remove_count != 1:
        failures.append(
            f"the player event handler is added {add_count} times and removed "
            f"{remove_count} times, so the pair is not symmetric"
        )

    print(f"Function: {FUNCTION.relative_to(ROOT)}")
    print(f"Refresh: {REFRESH.relative_to(ROOT)}")
    print(
        f"Placeholder {PLACEHOLDER!r} present: {PLACEHOLDER in refresh or PLACEHOLDER in hud}"
    )
    print(f"cutRsc calls: {total_cuts} ({guarded_cuts} behind the guard)")
    print(
        f"Empty branch removes the frame handler: {empty is not None and REMOVE_PFH_RE.search(empty.group(1)) is not None}"
    )
    print(
        f"Empty branch clears the cut: {empty is not None and CLEAR_CUT_RE.search(empty.group(1)) is not None}"
    )
    print(f"isNull player guard present: {PLAYER_GUARD_RE.search(hud) is not None}")
    print(f'Player event handler: add {add_count} on "unit", remove {remove_count}')

    if failures:
        print("\nFAILURES:")
        for failure in failures:
            print(f"  - {failure}")
        return 1

    print(
        "\n[verify_objective_panel] PASS: the placeholder is absent, every cut is "
        "behind the frame-handler guard, the empty branch removes the handler and "
        "clears the cut, the panel still exits on isNull player, and the player "
        "event handler is added and removed symmetrically. SHAPE ONLY: the panel "
        "itself needs a client."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
