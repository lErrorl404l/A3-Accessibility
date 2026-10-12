#!/usr/bin/env python3
"""Offline gate for the no-filter promise.

The mod remaps colours. It never simulates a colour vision deficiency and never
applies a screen filter. A simulation needs a post-process effect or a colour
matrix. This gate fails if either appears anywhere in the addon source.

Exit code 0 means the promise holds. It needs no game.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE_DIR = ROOT / "addons"
SOURCE_GLOBS = ["*.sqf", "*.hpp", "*.cpp", "*.inc"]

# A post-process handle, a colour-matrix effect, or a brightness lever.
FORBIDDEN = [
    "ppEffectCreate",
    "ppEffectAdjust",
    "ppEffectEnable",
    "ppEffectCommit",
    "ppEffectDestroy",
    "ColorCorrections",
    "setAperture",
    "setApertureNew",
]

# A colour matrix is ten or more numbers in one array, with nothing else in it.
# The body must hold only numbers, commas and whitespace, so a code block that
# happens to contain ten numbers is not a match.
ARRAY = re.compile(r"[\{\[][^\{\}\[\]]*[\}\]]")
NUMBER = re.compile(r"-?\d+(?:\.\d+)?")
NUMERIC_BODY = re.compile(r"^[\s\d.,\-+]+$")


def matrix_arrays(text: str) -> list[str]:
    found = []
    for match in ARRAY.finditer(text):
        body = match.group(0)[1:-1]
        if not NUMERIC_BODY.match(body):
            continue
        if len(NUMBER.findall(body)) >= 10:
            found.append(match.group(0))
    return found


def main() -> int:
    files: list[Path] = []
    for glob in SOURCE_GLOBS:
        files.extend(sorted(SOURCE_DIR.rglob(glob)))

    failures: list[str] = []
    for path in files:
        text = path.read_text(encoding="utf-8", errors="replace")
        rel = path.relative_to(ROOT)
        for token in FORBIDDEN:
            if token in text:
                failures.append(f"{rel}: contains {token}")
        for array in matrix_arrays(text):
            failures.append(f"{rel}: colour matrix {array[:60]}")

    if failures:
        print("FAILURES:")
        for failure in failures:
            print(f"  - {failure}")
        return 1

    print(
        f"[verify_no_filter] PASS: {len(files)} source files, "
        "no post-process effect and no colour matrix"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
