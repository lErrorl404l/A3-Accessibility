#!/usr/bin/env python3
"""Build the committed priority fixture from the cited trees.

`tests/verify_priority.py` asserts that the effect priority in
`addons/colourblind/functions/fnc_applyFrame.sqf` collides with no priority
another mod uses. `ppEffectCreate` returns -1 on a collision, and this addon
treats -1 as a hard failure that leaves the picture unchanged, so the collision
set must be measured and not guessed.

This script measures the set. It reads five cited trees and records, for each
integer priority, every file and line it was found on. The result is
`tests/fixtures/pp_priorities.json`, which is COMMITTED, because `/tmp` is not
durable and the gate must not depend on an extraction that a later run may not
repeat.

A priority counts when it matches one of three shapes:

1. The direct call `ppEffectCreate ["<name>", <number>]`, in any letter case
   and with the number bare or quoted.
2. An array led by an effect name and a number, for example
   `["ColorCorrections", 13502, [...]] call _fnc_createEffect`. ACE3 passes
   this shape to a local create helper, so the direct shape misses it.
3. A `priority = <number>;` key inside a file that names `CfgOpticsEffect`.
   CBA_A3 reads that key into `ppEffectCreate [_type, _priority]`, so its
   optics priorities are data and not literals.

The scan is deliberately generous. An extra value makes the collision gate
stricter, which fails closed. A missing value is the failure the gate exists to
prevent.

Every cited tree must exist. A missing tree stops the build, because a fixture
built from three trees while four were absent passes the gate for the wrong
reason.

    python3 tests/gen_pp_priorities.py
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from typing import NamedTuple

ROOT = Path(__file__).resolve().parent.parent
FIXTURE = Path(__file__).resolve().parent / "fixtures" / "pp_priorities.json"

# The cited trees. The plan names each one, and each one is a source of
# post-process priorities that can collide with this addon's effect.
TREES = [
    ("uiftest", Path("/tmp/opencode/uiftest"), "Arma 3 ui_f display scripts"),
    ("ft_full", Path("/tmp/opencode/ft_full"), "Arma 3 functions_f scripts"),
    ("ace3", Path("/tmp/opencode/repos/ace3"), "ACE3 addon sources"),
    ("acre2", Path("/tmp/opencode/repos/acre2"), "ACRE2 addon sources"),
    (
        "cba_a3",
        Path("/ext/Development/AEE/tests/docker/mods/@cba_a3"),
        "CBA_A3 addon sources, shipped as PBOs",
    ),
]

# `.pbo` is here because CBA_A3 ships compiled PBOs and no loose scripts. The
# PBO holds its config text uncompressed, so a byte scan of it still reads the
# optics priority.
SOURCE_SUFFIXES = {".sqf", ".fsm", ".hpp", ".cpp", ".inc", ".pbo"}

# The effect names that lead an array in the helper shape. The list holds every
# family the cited trees use. A name outside this list is not matched by shape
# 2, so the list is a floor and not a ceiling.
EFFECT_NAMES = (
    "colorcorrections",
    "filmgrain",
    "dynamicblur",
    "radialblur",
    "chromaberration",
    "wetdistortion",
)

DIRECT = re.compile(r'ppEffectCreate\s*\[\s*"([^"]+)"\s*,\s*"?(\d+)"?', re.IGNORECASE)
# The `(?://[^\n]*\s*)*` run lets a comment sit between the comma and the
# number. ACE3 writes `"RadialBlur", // reason` on one line and the number on
# the next, and the direct shape alone would miss it.
LED_ARRAY = re.compile(r'\[\s*"([^"]+)"\s*,\s*(?://[^\n]*\s*)*(\d+)\b', re.IGNORECASE)
OPTICS_PRIORITY = re.compile(r"\bpriority\s*=\s*(\d+)\s*;")
OPTICS_MARKER = "CfgOpticsEffect"


class Tree(NamedTuple):
    label: str
    root: Path
    contents: str


def line_of(text: str, offset: int) -> int:
    """Return the 1-based line number of a character offset."""
    return text.count("\n", 0, offset) + 1


def scan_text(text: str) -> list[tuple[int, int]]:
    """Return every (priority, line) pair the three shapes find in one file."""
    hits: list[tuple[int, int]] = []

    for match in DIRECT.finditer(text):
        hits.append((int(match.group(2)), line_of(text, match.start(2))))

    for match in LED_ARRAY.finditer(text):
        if match.group(1).lower() in EFFECT_NAMES:
            hits.append((int(match.group(2)), line_of(text, match.start(2))))

    if OPTICS_MARKER in text:
        for match in OPTICS_PRIORITY.finditer(text):
            hits.append((int(match.group(1)), line_of(text, match.start(1))))

    return hits


def scan_tree(
    tree: Tree,
    sources: dict[int, set[str]],
) -> tuple[int, set[int]]:
    """Scan one tree. Return (files scanned, priorities it contributed)."""
    files = 0
    contributed: set[int] = set()

    for path in sorted(tree.root.rglob("*")):
        if not path.is_file() or path.suffix.lower() not in SOURCE_SUFFIXES:
            continue
        files += 1
        text = path.read_text(encoding="utf-8", errors="ignore")
        relative = path.relative_to(tree.root).as_posix()
        for value, line in scan_text(text):
            sources.setdefault(value, set()).add(f"{tree.label}/{relative}:{line}")
            contributed.add(value)

    return files, contributed


def main() -> int:
    trees = [Tree(*entry) for entry in TREES]

    missing = [tree.label for tree in trees if not tree.root.is_dir()]
    if missing:
        print("FAIL: a cited tree is absent, so the fixture would be short:")
        for label in missing:
            root = next(tree.root for tree in trees if tree.label == label)
            print(f"  - {label}: {root}")
        print("Fix the extraction and run again. Do not commit a short fixture.")
        return 1

    sources: dict[int, set[str]] = {}
    summary: list[tuple[str, int, int]] = []
    for tree in trees:
        files, contributed = scan_tree(tree, sources)
        summary.append((tree.label, files, len(contributed)))

    if not sources:
        print("FAIL: the five trees are present but hold no priority at all.")
        return 1

    fixture = {
        "schema": 1,
        "description": (
            "Effect priorities in use across the cited trees. Each value lists "
            "every file and line it was found on, so a reader can re-derive the "
            "set. Built by tests/gen_pp_priorities.py and committed, because "
            "/tmp is not durable. tests/verify_priority.py is the consumer."
        ),
        "trees": [
            {
                "label": tree.label,
                "root": str(tree.root),
                "contents": tree.contents,
                "files_scanned": files,
                "priorities_contributed": contributed,
            }
            for tree, (_, files, contributed) in zip(trees, summary, strict=True)
        ],
        "priorities": {str(value): sorted(sources[value]) for value in sorted(sources)},
    }

    FIXTURE.parent.mkdir(parents=True, exist_ok=True)
    FIXTURE.write_text(json.dumps(fixture, indent=2) + "\n", encoding="utf-8")

    print("Scanned the cited trees:")
    for label, files, contributed in summary:
        print(f"  {label:8s} {files:6d} files  {contributed:3d} values")
    print(
        f"\nWrote {FIXTURE.relative_to(ROOT)}: {len(sources)} distinct priorities "
        f"from {sum(files for _, files, _ in summary)} files"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
