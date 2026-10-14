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

# Check A applies to every addon. It bans the global screen effect, every
# post-process effect family other than the colour-corrections transform, and
# the capital-C class name as a guard. A matrix stays banned too, because a
# matrix is the shape of a colour simulation.
CHECK_A_TOKENS = [
    "setPiPEffect",
    "ColorCorrections",
    "filmGrain",
    "chromAberration",
    "wetDistortion",
    "dynamicBlur",
    "radialBlur",
]

# Check B applies to the colour component only. That component remaps colours,
# so it must be provably brightness-neutral and may not touch the aperture
# commands. The flash damping items live in a future component.
CHECK_B_TOKENS = ["setAperture", "setApertureNew"]
COLOUR_COMPONENT = ROOT / "addons" / "colourblind"

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


def scan(paths: list[Path], tokens: list[str], check: str) -> list[str]:
    failures: list[str] = []
    for path in paths:
        text = path.read_text(encoding="utf-8", errors="replace")
        rel = path.relative_to(ROOT)
        for token in tokens:
            if token in text:
                failures.append(f"{check}: {rel} contains {token}")
        for array in matrix_arrays(text):
            failures.append(f"{check}: {rel} colour matrix {array[:60]}")
    return failures


def main() -> int:
    files: list[Path] = []
    for glob in SOURCE_GLOBS:
        files.extend(sorted(SOURCE_DIR.rglob(glob)))
    colour_files = [p for p in files if COLOUR_COMPONENT in p.parents]

    failures = scan(files, CHECK_A_TOKENS, "A")
    failures += scan(colour_files, CHECK_B_TOKENS, "B")

    if failures:
        print("FAILURES:")
        for failure in failures:
            print(f"  - {failure}")
        return 1

    print(
        f"[verify_postprocess] PASS: check A over {len(files)} source files, "
        "no post-process effect and no colour matrix"
    )
    print(
        f"[verify_postprocess] PASS: check B over {len(colour_files)} colour files, "
        "the colour component is brightness-neutral"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
