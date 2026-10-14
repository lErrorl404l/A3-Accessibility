#!/usr/bin/env python3
"""Offline gate for the colour-blind palette.

This reads the real pure palette function and:

1. Checks the function returns 24 well-formed RGBA entries (4 modes x 6 classes).
2. Recomputes the WCAG 2.2 relative-luminance contrast for every gated pair and
   asserts it meets the 3:1 floor.

The config side is now dynamic: every converted surface reads a profile
variable, so the config carries no palette values. The expression form and the
variable names are gated by tests/verify_surface.py.

It needs no game and no SQF interpreter. Exit code 0 means all gates pass.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FUNCTION = ROOT / "addons" / "colourblind" / "functions" / "fnc_paletteForMode.sqf"

CLASSES = ["friendly", "enemy", "neutral", "unknown", "civilian", "objective"]
MODES = {1: "Protan", 2: "Deutan", 3: "Tritan", 4: "Achromatopsia"}

MAPPER = ROOT / "addons" / "colourblind" / "functions" / "fnc_colourForRole.sqf"

# The mapper's domain is the four roles the fence can declare. `civilian` and
# `objective` are outside it: `civilian` is reached by the kept config paths, and
# `objective` has no producer on any path, so a call with either returns [].
MAPPER_ROLES = ["enemy", "friendly", "neutral", "unknown"]
OUT_OF_DOMAIN = ["civilian", "objective"]

ROLE_BEGIN = "ROLE_TABLE_BEGIN"
ROLE_END = "ROLE_TABLE_END"
ROLE_RE = re.compile(r"^ROLE\s+([a-z]+)\s+CLASS\s+([a-z]+)$")
BODY_PAIR_RE = re.compile(r'\[\s*"([a-z]+)"\s*,\s*"([a-z]+)"\s*\]')
BAND_RE = re.compile(r"\bband\b", re.IGNORECASE)
PARAM_NAME_RE = re.compile(r'"(_[a-z]+)"')
ROLE_GUARD_RE = re.compile(
    r"if\s*!\(\s*_role\s+in\s+_roleToClass\s*\)\s*exitWith\s*\{\s*\[\]\s*\}"
)

GATED_PAIRS = {
    "Protan": [
        ("friendly", "enemy"),
        ("neutral", "civilian"),
        ("enemy", "civilian"),
        ("friendly", "unknown"),
    ],
    "Deutan": [
        ("friendly", "enemy"),
        ("neutral", "civilian"),
        ("enemy", "civilian"),
        ("friendly", "unknown"),
    ],
    "Tritan": [
        ("friendly", "enemy"),
        ("neutral", "civilian"),
        ("objective", "friendly"),
        ("enemy", "civilian"),
    ],
    "Achromatopsia": [
        ("friendly", "enemy"),
        ("friendly", "neutral"),
        ("enemy", "neutral"),
        ("objective", "enemy"),
        ("objective", "neutral"),
    ],
}

MIN_RATIO = 3.0

RGBA_RE = re.compile(
    r"\[\s*([0-9.]+)\s*,\s*([0-9.]+)\s*,\s*([0-9.]+)\s*,\s*([0-9.]+)\s*\]"
)


def luminance(rgba: tuple[float, float, float, float]) -> float:
    def channel(c: float) -> float:
        return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4

    r, g, b = (channel(c) for c in rgba[:3])
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast(
    a: tuple[float, float, float, float], b: tuple[float, float, float, float]
) -> float:
    la, lb = luminance(a), luminance(b)
    hi, lo = max(la, lb), min(la, lb)
    return (hi + 0.05) / (lo + 0.05)


def parse_function() -> dict[int, dict[str, tuple[float, float, float, float]]]:
    text = FUNCTION.read_text(encoding="utf-8")
    entries = [tuple(float(x) for x in m) for m in RGBA_RE.findall(text)]
    if len(entries) != 24:
        raise SystemExit(
            f"FAIL: expected 24 palette entries in the function, found {len(entries)}"
        )

    table: dict[int, dict[str, tuple[float, float, float, float]]] = {}
    i = 0
    for mode in sorted(MODES):
        table[mode] = {}
        for cls in CLASSES:
            table[mode][cls] = entries[i]
            i += 1
    return table


def parse_role_table(text: str) -> dict[str, str]:
    """Parse the machine-read role table out of the mapper header."""
    if ROLE_BEGIN not in text or ROLE_END not in text:
        raise SystemExit(f"FAIL: {MAPPER.name} has no {ROLE_BEGIN}..{ROLE_END} block")
    block = text.split(ROLE_BEGIN, 1)[1].split(ROLE_END, 1)[0]

    routes: dict[str, str] = {}
    for raw in block.splitlines():
        line = raw.strip().lstrip("*").strip()
        match = ROLE_RE.match(line)
        if match:
            routes[match.group(1)] = match.group(2)
    return routes


def parse_body_routes(text: str) -> dict[str, str]:
    """Parse the routing table the mapper body carries, to catch header drift."""
    if "_roleToClass" not in text:
        raise SystemExit(f"FAIL: {MAPPER.name} carries no _roleToClass table")
    block = text.split("_roleToClass", 1)[1].split("];", 1)[0]
    return {role: cls for role, cls in BODY_PAIR_RE.findall(block)}


def band_references(text: str) -> int:
    """Count the `band` tokens after the header comment block, which must be 0."""
    if "*/" not in text:
        raise SystemExit(f"FAIL: {MAPPER.name} has no header comment block")
    return len(BAND_RE.findall(text.split("*/", 1)[1]))


def params_line_of(text: str) -> str:
    """Return the mapper's params line, so the declared names can be checked."""
    for line in text.split("*/", 1)[1].splitlines():
        if line.strip().startswith("params"):
            return line
    return ""


def main() -> int:
    table = parse_function()
    failures: list[str] = []

    # Gate 1: well-formed entries.
    for mode, classes in table.items():
        for cls, rgba in classes.items():
            if len(rgba) != 4:
                failures.append(f"mode {mode} class {cls}: not four values")
            if not all(0.0 <= c <= 1.0 for c in rgba):
                failures.append(f"mode {mode} class {cls}: value out of range 0..1")
            if rgba[3] != 1:
                failures.append(f"mode {mode} class {cls}: alpha is not 1")

    # Gate 2: gated pairs meet the 3:1 floor.
    print("Gated contrast pairs (WCAG 2.2 relative luminance):")
    for mode_index, mode_name in MODES.items():
        for a, b in GATED_PAIRS[mode_name]:
            ratio = contrast(table[mode_index][a], table[mode_index][b])
            verdict = "ok" if ratio >= MIN_RATIO else "FAIL"
            print(f"  {mode_name:14s} {a:9s} vs {b:9s} {ratio:5.2f}:1  {verdict}")
            if ratio < MIN_RATIO:
                failures.append(
                    f"{mode_name} {a} vs {b} = {ratio:.2f}:1, below {MIN_RATIO}:1"
                )

    # Gate 3: the mapper, over the four fence roles only.
    mapper_text = MAPPER.read_text(encoding="utf-8")
    routes = parse_role_table(mapper_text)
    body_routes = parse_body_routes(mapper_text)

    if set(routes) != set(MAPPER_ROLES):
        failures.append(
            f"{MAPPER.name} routes {sorted(routes)}, expected exactly "
            f"{sorted(MAPPER_ROLES)}"
        )
    if routes != body_routes:
        failures.append(
            f"{MAPPER.name}: the role table {routes} and the body table "
            f"{body_routes} disagree"
        )

    rejected = 0
    for role in OUT_OF_DOMAIN:
        if role in routes or role in body_routes:
            failures.append(
                f"{MAPPER.name}: {role} is inside the mapper domain, so a call "
                "with it returns a colour instead of an empty array"
            )
        else:
            rejected += 1
    if not ROLE_GUARD_RE.search(mapper_text):
        failures.append(
            f"{MAPPER.name}: no guard returns [] for a role absent from the table"
        )

    param_names = PARAM_NAME_RE.findall(params_line_of(mapper_text))
    if param_names != ["_mode", "_role"]:
        failures.append(
            f"{MAPPER.name}: params {param_names}, expected ['_mode', '_role'] "
            "and no band parameter"
        )

    band_hits = band_references(mapper_text)
    if band_hits != 0:
        failures.append(
            f"{MAPPER.name}: the body reads {band_hits} band reference(s), so "
            "the mapper is not brightness-invariant"
        )

    mapper_counts: dict[int, int] = {}
    for mode in sorted(MODES):
        mapper_counts[mode] = 0
        for role in MAPPER_ROLES:
            cls = routes.get(role)
            if cls not in CLASSES:
                failures.append(
                    f"{MAPPER.name}: role {role} maps to an unknown class {cls}"
                )
                continue
            rgba = table[mode][cls]
            mapper_counts[mode] += 1
            if len(rgba) != 4:
                failures.append(f"mapper mode {mode} role {role}: not four values")
            if not all(0.0 <= c <= 1.0 for c in rgba):
                failures.append(
                    f"mapper mode {mode} role {role}: value out of range 0..1"
                )
            if rgba[3] != 1:
                failures.append(f"mapper mode {mode} role {role}: alpha is not 1")
        if mapper_counts[mode] != 4:
            failures.append(
                f"mapper mode {mode}: {mapper_counts[mode]} entries, expected four"
            )

    mapper_total = sum(mapper_counts.values())
    if mapper_total != 16:
        failures.append(f"the mapper resolves {mapper_total} entries, expected 16")
    print("\nMapper entries, four roles per mode:")
    for mode_index, mode_name in MODES.items():
        print(f"  {mode_name:14s} {mapper_counts[mode_index]} entries")
    print(f"  {'Off':14s} 0 entries, the palette carries no mode 0")
    print(f"  band references after the header: {band_hits}")
    print(f"  out-of-domain roles rejected: {rejected} ({', '.join(OUT_OF_DOMAIN)})")

    if failures:
        print("\nFAILURES:")
        for f in failures:
            print(f"  - {f}")
        return 1

    palette_total = sum(len(classes) for classes in table.values())
    print(
        f"\n[verify_palette] PASS: {palette_total} palette entries, "
        f"{mapper_total} mapper entries, {band_hits} band references "
        "(source-level band invariance), "
        f"civilian and objective out of domain ({rejected} of "
        f"{len(OUT_OF_DOMAIN)} rejected), every gated pair clears 3:1"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
