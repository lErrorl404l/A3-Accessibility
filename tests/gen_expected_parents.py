#!/usr/bin/env python3
"""Regenerate tests/expected_parents.json from the extracted shipped configs.

tests/verify_surface.py gates the parent of every class path in every
CONFIG_FILES file against the parent the shipped game config states. That gate
runs in CI with no game install, so the expected parents live in a committed
map, tests/expected_parents.json. This script rebuilds that map.

Extract the game PBOs that define the roots the addon touches, then run:

    extractpbo -P "<install>/Addons/ui_f.pbo" /tmp/opencode/vanilla/ui_f
    extractpbo -P "<install>/Curator/Addons/ui_f_curator.pbo" /tmp/opencode/gamepbo/ui_f_curator
    python3 tests/gen_expected_parents.py

The base game is read first (BASE), then the DLC and Curator folders (DLC), so
the first definition found is the one the base game loads. Pass two other
directories as arguments to read a different extraction.

Every class path in every CONFIG_FILES file must appear in the map. A class
path the shipped config does not define is an error: this addon reopens shipped
classes, so an unknown path means the map is stale or the addon added a class.

The script prints the class count it wrote. It writes nothing when it fails.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from verify_surface import CONFIG_FILES, class_declarations  # noqa: E402

BASE = Path("/tmp/opencode/vanilla")  # base game
DLC = Path("/tmp/opencode/gamepbo")  # DLC, Curator and mod PBOs
OUT = Path(__file__).resolve().parent / "expected_parents.json"


def shipped_parents(base: Path, dlc: Path) -> dict[str, str | None]:
    """Return {class path: shipped parent or None} for every shipped class.

    The base game is read first, so the first definition of a class path wins.
    """
    seen: dict[str, str | None] = {}
    configs = sorted(base.rglob("config.cpp")) + sorted(dlc.rglob("config.cpp"))
    for path in configs:
        text = path.read_text(encoding="utf-8", errors="replace")
        for cls_path, parent in class_declarations(text).items():
            seen.setdefault(cls_path, parent)
    return seen


def main(argv: list[str]) -> int:
    base = Path(argv[1]) if len(argv) > 1 else BASE
    dlc = Path(argv[2]) if len(argv) > 2 else DLC
    if not base.is_dir() or not dlc.is_dir():
        print(f"FAIL: {base} and {dlc} must both hold extracted configs")
        return 1

    shipped = shipped_parents(base, dlc)
    if not shipped:
        print(f"FAIL: no config.cpp found under {base} or {dlc}")
        return 1

    expected: dict[str, dict[str, str | None]] = {}
    unknown: list[str] = []
    for path in CONFIG_FILES:
        declared = class_declarations(path.read_text(encoding="utf-8"))
        by_path: dict[str, str | None] = {}
        for cls_path in declared:
            if cls_path not in shipped:
                unknown.append(f"{path.name} {cls_path}")
                continue
            by_path[cls_path] = shipped[cls_path]
        expected[path.name] = dict(sorted(by_path.items()))
    if unknown:
        print("FAIL: these addon class paths are not in the shipped config:")
        for entry in unknown:
            print(f"  - {entry}")
        return 1

    OUT.write_text(
        json.dumps(expected, indent=2, sort_keys=False) + "\n", encoding="utf-8"
    )
    total = sum(len(by_path) for by_path in expected.values())
    parented = sum(
        1 for by_path in expected.values() for parent in by_path.values() if parent
    )
    print(
        f"[gen_expected_parents] wrote {OUT.name}: {total} class paths across "
        f"{len(expected)} files, {parented} with a parent, {total - parented} bare"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
