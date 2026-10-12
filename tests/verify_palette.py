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

    if failures:
        print("\nFAILURES:")
        for f in failures:
            print(f"  - {f}")
        return 1

    print("\n[verify_palette] PASS: 24 function entries, every gated pair clears 3:1")
    return 0


if __name__ == "__main__":
    sys.exit(main())
