#!/usr/bin/env python3
"""Verify the A3ACC in-engine test log.

Reads a captured docker server log, requires the DONE marker and the pass line,
and fails on any suite failure or server error. Exits 0 only on a clean pass.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

LOG = sys.argv[1] if len(sys.argv) > 1 else "tests/ingame/run.log"

# Engine noise that no addon change can remove.
BENIGN = (
    "not lowercase",
    "is dependent on downloadable content",
    "looped for animation",
    "Cannot open object",
    "Size: '/' not an array",
    "No geometry and no visual shape",
    "'/' is not a value",
)


# Config roots this addon overrides, read from the config headers so the list
# cannot go stale as components are added or removed. A missing entry under one
# of these is our defect, not engine noise.
def our_roots() -> tuple[str, ...]:
    root = Path(__file__).resolve().parent.parent.parent
    roots: list[str] = []
    headers = sorted(root.glob("addons/*/Cfg*.hpp")) + sorted(
        root.glob("addons/*/Rsc*.hpp")
    )
    for path in headers:
        for line in path.read_text(encoding="utf-8").splitlines():
            stripped = line.rstrip()
            if not stripped.startswith("class ") or stripped.endswith(";"):
                continue  # not a root class, or a forward declaration
            name = stripped[len("class ") :].split(":")[0].split(" ")[0].strip()
            if name and name not in roots:
                roots.append(name)
    return tuple(roots)


OUR_ROOTS = our_roots()

# A config expression that read the profile namespace before the engine had one.
# The engine logs the first line, then terminates. Proven, and refused in the
# offline gate too: see addons/colourblind/CfgInGameUI.hpp.
FATAL_STARTUP = re.compile(
    r"Trying to get namespace profile|Application terminated intentionally"
)

# A cleared vanilla parent. The engine reports it as "Updating base class 'X'->''".
CLEARED_PARENT = re.compile(r"Updating base class '[^']*'->''")


def main() -> int:
    with open(LOG, encoding="utf-8", errors="replace") as handle:
        text = handle.read()

    done = "[A3ACC-TEST] DONE" in text
    passed = "[A3ACC] all tests passed" in text
    suite_fails = [
        line
        for line in text.splitlines()
        if "[A3ACC]" in line and "failed" in line.lower()
    ]
    fatal = [line for line in text.splitlines() if FATAL_STARTUP.search(line)]
    errors = [
        line
        for line in text.splitlines()
        if re.search(r"\bError", line) and not any(b in line for b in BENIGN)
    ]

    # Our overrides must preserve the vanilla parent chain. A redeclared class
    # without its parent clears the inheritance and is reported by name.
    cleared = [
        line
        for line in text.splitlines()
        if "a3acc" in line.lower() and CLEARED_PARENT.search(line)
    ]
    missing = [
        line
        for line in text.splitlines()
        if "No entry '" in line and any(root in line for root in OUR_ROOTS)
    ]

    if fatal:
        print("FAIL: the engine terminated at startup")
        for line in fatal[:5]:
            print("  " + line.strip())
        return 1
    if not done:
        print("FAIL: the test did not finish ([A3ACC-TEST] DONE is missing)")
        return 1
    if not passed:
        print("FAIL: the test suite did not pass")
        for line in suite_fails:
            print("  " + line.strip())
        return 1
    if errors:
        print("FAIL: the server log has errors")
        for line in errors[:20]:
            print("  " + line.strip())
        return 1
    if cleared:
        print("FAIL: an override cleared a vanilla base class")
        for line in cleared[:20]:
            print("  " + line.strip())
        return 1
    if missing:
        print("FAIL: a config root is missing an entry")
        for line in missing[:20]:
            print("  " + line.strip())
        return 1

    print(
        "[verify_ingame] PASS: the in-engine suite passed and the server log is clean"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
