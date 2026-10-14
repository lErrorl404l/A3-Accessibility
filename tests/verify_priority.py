#!/usr/bin/env python3
"""Offline gate for the effect priority collision.

The frame transform creates one `colorCorrections` post-process effect at a
pinned priority. `ppEffectCreate` returns -1 when another effect already holds
that priority, and this addon treats -1 as a hard failure that leaves the
picture unchanged. The priority therefore must collide with nothing.

This gate reads the priority out of
`addons/colourblind/functions/fnc_applyFrame.sqf` and asserts three things:

1. The priority is a named constant, and no bare literal sits in the create
   call. One place owns the number.
2. The value is absent from the committed fixture
   `tests/fixtures/pp_priorities.json`, which `tests/gen_pp_priorities.py`
   measures from the cited trees.
3. The literal appears exactly once across the addon, so a second copy cannot
   drift from the constant.

It needs no game and no SQF interpreter. Exit code 0 means all gates pass.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FUNCTION = ROOT / "addons" / "colourblind" / "functions" / "fnc_applyFrame.sqf"
FIXTURE = Path(__file__).resolve().parent / "fixtures" / "pp_priorities.json"
ADDON = ROOT / "addons"
SOURCE_SUFFIXES = (".sqf", ".hpp", ".cpp", ".inc")

EFFECT = "colorcorrections"

CREATE = re.compile(
    r'ppEffectCreate\s*\[\s*"([^"]+)"\s*,\s*([A-Za-z_][A-Za-z0-9_]*|\d+)\s*\]',
    re.IGNORECASE,
)
DEFINE = re.compile(r"^\s*#define\s+([A-Za-z_][A-Za-z0-9_]*)\s+(\d+)\s*$", re.MULTILINE)


def read_priority() -> tuple[str, int, str]:
    """Return (constant name, value, effect name) from the frame function."""
    text = FUNCTION.read_text(encoding="utf-8")
    calls = CREATE.findall(text)

    if len(calls) != 1:
        raise SystemExit(
            f"FAIL: {FUNCTION.name} holds {len(calls)} ppEffectCreate calls, "
            "expected exactly one"
        )

    effect, argument = calls[0]
    if argument.isdigit():
        raise SystemExit(
            f"FAIL: the create call uses the bare literal {argument}. The "
            "priority must be a named constant, so one place owns it"
        )

    defines = dict(DEFINE.findall(text))
    if argument not in defines:
        raise SystemExit(
            f"FAIL: {argument} is used in the create call but has no #define "
            f"in {FUNCTION.name}"
        )

    return argument, int(defines[argument]), effect


def literal_occurrences(value: int) -> list[str]:
    """Return every addon file and line that holds the value as a whole number."""
    pattern = re.compile(rf"(?<!\d){value}(?!\d)")
    found: list[str] = []
    for path in sorted(ADDON.rglob("*")):
        if not path.is_file() or path.suffix.lower() not in SOURCE_SUFFIXES:
            continue
        text = path.read_text(encoding="utf-8", errors="ignore")
        for number, line in enumerate(text.splitlines(), 1):
            if pattern.search(line):
                found.append(f"{path.relative_to(ROOT)}:{number}")
    return found


def wrap(values: list[str], width: int = 74) -> str:
    """Join values into wrapped lines of fixed width."""
    lines: list[str] = []
    current = ""
    for value in values:
        piece = value if not current else f" {value}"
        if len(current) + len(piece) > width:
            lines.append(current)
            current = value
        else:
            current += piece
    if current:
        lines.append(current)
    return "\n".join(f"  {line}" for line in lines)


def main() -> int:
    failures: list[str] = []
    name, value, effect = read_priority()

    if effect.lower() != EFFECT:
        failures.append(f"the create call uses the effect {effect}, expected {EFFECT}")

    fixture = json.loads(FIXTURE.read_text(encoding="utf-8"))
    used = {int(key): sources for key, sources in fixture["priorities"].items()}
    if not used:
        failures.append(f"{FIXTURE.name} holds no priority at all")

    if value in used:
        failures.append(
            f"the priority {value} ({name}) is already used at {used[value]}. "
            "ppEffectCreate returns -1 on that collision and the picture stays "
            "unchanged"
        )

    occurrences = literal_occurrences(value)
    if len(occurrences) != 1:
        failures.append(
            f"the literal {value} appears {len(occurrences)} times in the addon, "
            f"expected exactly once: {occurrences}"
        )

    absent = value not in used
    unique = len(occurrences) == 1

    print(f"Priority constant: {name} = {value} (from {FUNCTION.relative_to(ROOT)})")
    print(f"Effect: {effect}")
    print(
        f"Used set scanned: {len(used)} priorities from {len(fixture['trees'])} trees"
    )
    print(wrap([str(number) for number in sorted(used)]))
    print(
        f"The constant {value} is absent from the used set: "
        f"{'ok' if absent else 'FAIL'}"
    )
    print(
        f"The literal {value} appears once in the addon: {'ok' if unique else 'FAIL'}"
    )

    if failures:
        print("\nFAILURES:")
        for failure in failures:
            print(f"  - {failure}")
        return 1

    print(
        f"\n[verify_priority] PASS: the priority {value} is a named constant, it "
        "collides with none of the scanned priorities, and it appears once"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
