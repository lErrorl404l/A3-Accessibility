#!/usr/bin/env python3
"""Offline gate for the 2D interface surface table.

The table in `docs/research/25-2d-interface-coverage.md` is the specification
for the 2D coverage work. The later rows implement exactly the rows it marks
covered. This gate parses the table and asserts the facts the specification
rests on, so the table and the implementation cannot drift apart.

The assertions:

1. Every `covered` row's `surface key` is one of the five keys this plan admits.
2. Every `excluded` row carries a non-empty reason.
3. Every `covered` row's `mechanism` is `config override`.
4. No row's `mechanism` or `tier` names a display, a control, an idc or a fence
   triple.
5. The covered row count of each of the four surface sets equals the count the
   table records, and each set has at least one covered row.
6. Every `CONFIG_FILES` basename in `tests/verify_surface.py` appears in the
   include list of the `config.cpp` in its own parent directory.
7. The table holds rows, and the record file is not empty.

Two assertions are deliberately absent, because they arrive with the work they
gate. The override assertion `covered path has no override` belongs to the
override header row, and the client-step assertion `covered surface has no
client step` belongs to the client record row.

It needs no game and no SQF interpreter. Exit code 0 means all assertions pass.
"""

from __future__ import annotations

import importlib.util
import re
import sys
from pathlib import Path
from types import ModuleType

ROOT = Path(__file__).resolve().parent.parent
TESTS = Path(__file__).resolve().parent
RECORD = ROOT / "docs" / "research" / "25-2d-interface-coverage.md"
SURFACE_GATE = TESTS / "verify_surface.py"
FENCE_GATE = TESTS / "verify_fence.py"

TABLE_BEGIN = "<!-- SURFACE TABLE BEGIN -->"
TABLE_END = "<!-- SURFACE TABLE END -->"

# The table's columns, in order. The header row and the separator row carry the
# first of these, so the parser can tell them from a data row.
COLUMNS = (
    "class path",
    "property",
    "shipped value",
    "role",
    "surface key",
    "decision",
    "mechanism",
    "reason",
    "tier",
)

# The five surface keys this plan admits, from the writer's eight.
ADMITTED_KEYS = ("BLUFOR", "OPFOR", "Independent", "Civilian", "Unknown")

# The four surface sets, in the table's order.
SETS = ("MFD", "Optics", "IslandMap", "MissionEditor")

COVERED = "covered"
EXCLUDED = "excluded"
MECHANISM = "config override"

COUNT_RE = re.compile(r"^COVERED-COUNT\s+(\S+)\s+(\d+)\s*$", re.M)

# A named display or control class, and the literal `idc`. A mechanism or a
# tier that names one of these is a walk or a control write, not an override.
CLASS_RE = re.compile(r"\bRsc[A-Za-z0-9_]*\b")
IDC_RE = re.compile(r"\bidc\b", re.IGNORECASE)


def load_module(path: Path, name: str) -> ModuleType:
    """Load a sibling gate module so its tables are never restated here."""
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise SystemExit(f"FAIL: cannot load {path.name}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def table_rows(text: str) -> list[list[str]]:
    """Return the surface table's data rows, without the header or separator."""
    if TABLE_BEGIN not in text or TABLE_END not in text:
        raise SystemExit(f"FAIL: {RECORD.name} has no {TABLE_BEGIN}..{TABLE_END} block")
    block = text.split(TABLE_BEGIN, 1)[1].split(TABLE_END, 1)[0]
    rows: list[list[str]] = []
    for raw in block.splitlines():
        line = raw.strip()
        if not line.startswith("|"):
            continue
        cells = [cell.strip() for cell in line.strip("|").split("|")]
        if cells[0] == COLUMNS[0]:
            continue
        if all(set(cell) <= set("-: ") for cell in cells):
            continue
        rows.append(cells)
    return rows


def surface_set(class_path: str) -> str | None:
    """Return the surface set a class path belongs to, or None."""
    if class_path.startswith("CfgVehicles/") and "/MFD" in class_path:
        return "MFD"
    if class_path.startswith("RscInGameUI/"):
        return "Optics"
    if class_path == "CfgInGameUI/IslandMap":
        return "IslandMap"
    if class_path == "RscDisplayMissionEditor":
        return "MissionEditor"
    return None


def main() -> int:
    failures: list[str] = []

    text = RECORD.read_text(encoding="utf-8")
    if not text.strip():
        print("FAILURES:\n  - the record file is empty")
        return 1
    rows = table_rows(text)
    if not rows:
        failures.append("the surface table holds no rows")

    fence = load_module(FENCE_GATE, "verify_fence")
    fence_names = {part for triple in fence.REQUIRED_COVERAGE for part in triple}

    covered: list[list[str]] = []
    excluded: list[list[str]] = []
    for cells in rows:
        where = f"{cells[0]}/{cells[1]}"
        if len(cells) != len(COLUMNS):
            failures.append(
                f"{where}: a row does not have nine columns, it has {len(cells)}"
            )
            continue
        (
            _class_path,
            _property,
            _value,
            _role,
            key,
            decision,
            mechanism,
            reason,
            tier,
        ) = cells

        if decision == COVERED:
            covered.append(cells)
            if key not in ADMITTED_KEYS:
                failures.append(
                    f"surface key is not one of the five admitted keys: "
                    f"{where} names {key!r}"
                )
            if mechanism != MECHANISM:
                failures.append(
                    f"covered row is not an override: {where} names "
                    f"mechanism {mechanism!r}"
                )
        elif decision == EXCLUDED:
            excluded.append(cells)
            if not reason or reason == "-":
                failures.append(f"excluded row has no reason: {where}")
        else:
            failures.append(
                f"surface key is not one of the five admitted keys: {where} "
                f"names decision {decision!r}"
            )

        for field, value in (("mechanism", mechanism), ("tier", tier)):
            if IDC_RE.search(value) or CLASS_RE.search(value):
                failures.append(
                    f"a fence mechanism is named: {where} names {field} {value!r}"
                )
            elif any(name in value for name in fence_names):
                failures.append(
                    f"a fence mechanism is named: {where} names {field} {value!r}"
                )

    # The covered count of each set, against the count the table records.
    counted = {name: 0 for name in SETS}
    for cells in covered:
        name = surface_set(cells[0])
        if name is not None:
            counted[name] += 1
    recorded = {name: int(count) for name, count in COUNT_RE.findall(text)}
    for name in SETS:
        if name not in recorded:
            failures.append(
                f"covered count mismatch: the table records no count for the {name} set"
            )
        elif recorded[name] != counted[name]:
            failures.append(
                f"covered count mismatch: the {name} set has {counted[name]} "
                f"covered rows, the table records {recorded[name]}"
            )
        if counted[name] == 0:
            failures.append(
                f"covered count mismatch: the {name} set has no covered row"
            )

    # Every gated config header is included by the config in its own directory.
    surface = load_module(SURFACE_GATE, "verify_surface")
    for path in surface.CONFIG_FILES:
        config = path.parent / "config.cpp"
        if not config.exists():
            failures.append(f"header is not included: {config} does not exist")
            continue
        if f'#include "{path.name}"' not in config.read_text(encoding="utf-8"):
            failures.append(
                f"header is not included: {path.name} is not in {config.name} "
                f"under {path.parent.name}"
            )

    if failures:
        print("FAILURES:")
        for failure in failures:
            print(f"  - {failure}")
        return 1

    print(
        f"[verify_2d_coverage] PASS: {len(covered)} covered rows and "
        f"{len(excluded)} excluded rows; the five admitted keys; every excluded "
        f"row carries a reason; every covered row is a config override; no "
        f"fence mechanism named; "
        + ", ".join(f"{name} {counted[name]}" for name in SETS)
        + f"; {len(surface.CONFIG_FILES)} gated headers included"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
