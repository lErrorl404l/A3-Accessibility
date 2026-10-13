#!/usr/bin/env python3
"""Build a diagnostic release whose colour fallbacks are a loud sentinel.

Every converted colour is an expression whose second argument is the shipped
value, which the engine uses when this addon has not written its own yet:

    "(missionnamespace getvariable ['A3ACC_Surf_SideColors_colorFriendly_R',0.709])"

If the engine reads a class before the addon's value exists, that expression
returns the fallback and nothing reports it. The engine only logs a read it
cannot evaluate at all, so a fallback is invisible in an RPT.

This script rewrites every fallback to magenta, builds a signed release, and
puts the config back. The result is a diagnostic build in which three outcomes
are distinguishable by eye:

    magenta        the class is converted, and the engine read it too early
    mode colour    the class is converted and the value reached the engine
    shipped colour the class is not converted at all

Set the mode to Deutan before looking, because Off deletes the addon's variables
and every converted surface then falls back.

    python3 tests/make_sentinel_build.py           write, build, restore
    python3 tests/make_sentinel_build.py --keep    leave the config written
"""

from __future__ import annotations

import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ADDON = ROOT / "addons" / "colourblind"
FILES = sorted(ADDON.glob("*.hpp")) + sorted(
    (ROOT / "addons").glob("colourblind_*/**/*.hpp")
)

EXPR = re.compile(
    r"(missionnamespace getvariable \['A3ACC_Surf_[A-Za-z0-9_]+_(R|G|B)',)([0-9.]+)(\]\))"
)
# Magenta: full red, no green, full blue. Nothing in the shipped palette is this.
SENTINEL = {"R": "1", "G": "0", "B": "1"}


def rewrite(path: Path) -> int:
    text = path.read_text(encoding="utf-8")
    count = 0

    def swap(match: re.Match[str]) -> str:
        nonlocal count
        count += 1
        return match.group(1) + SENTINEL[match.group(2)] + match.group(4)

    new = EXPR.sub(swap, text)
    if count:
        path.write_text(new, encoding="utf-8")
    return count


def main() -> int:
    keep = "--keep" in sys.argv
    backup = Path(tempfile.mkdtemp(prefix="a3acc-sentinel-"))
    total = 0
    written: list[Path] = []
    for path in FILES:
        if not path.exists():
            continue
        shutil.copy2(path, backup / path.name)
        count = rewrite(path)
        if count:
            written.append(path)
            total += count
    if not total:
        print("[sentinel] no fallback found: is the config already converted?")
        return 1
    print(
        f"[sentinel] rewrote {total} fallbacks to magenta across {len(written)} files"
    )

    try:
        result = subprocess.run(
            ["hemtt", "release"], cwd=ROOT, check=False, capture_output=True, text=True
        )
        if result.returncode != 0:
            print(result.stdout[-2000:])
            print(result.stderr[-2000:])
            print("[sentinel] hemtt release failed")
            return 1
        print("[sentinel] built releases/a3acc-latest.zip")
    finally:
        if not keep:
            for path in written:
                shutil.copy2(backup / path.name, path)
            print(f"[sentinel] config restored from {backup}")
        else:
            print(f"[sentinel] config left written, originals in {backup}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
