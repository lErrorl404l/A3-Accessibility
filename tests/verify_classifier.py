#!/usr/bin/env python3
"""Offline gate for the pure colour classifier.

The classifier in `addons/colourblind/functions/fnc_classifyColour.sqf` states
its tolerances in a machine-read table. This gate parses that table instead of
restating the numbers by hand, mirrors the classification in Python, and runs
the mirror over the hand-labelled fixture `tests/fixtures/colour_literals.json`.

The fixture is the ground truth. It is authored and labelled by hand, and each
entry names the shipped config property it was read from. The gate fails when
the mirror disagrees with a label, so the declared tolerances and the fixture
cannot drift apart.

The gate also records two facts the plan depends on:

1. The classifier declares no `CIVILIAN` family. Vanilla ships one grey for the
   neutral and the civilian surface, so no window can separate the two roles.
2. The `objective` palette entry has no producer in the writer or in the
   surface function.

It needs no game and no SQF interpreter. Exit code 0 means all gates pass.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from typing import NamedTuple

ROOT = Path(__file__).resolve().parent.parent
FUNCTION = ROOT / "addons" / "colourblind" / "functions" / "fnc_classifyColour.sqf"
FIXTURE = Path(__file__).resolve().parent / "fixtures" / "colour_literals.json"
APPLY_VARS = ROOT / "addons" / "colourblind" / "functions" / "fnc_applyVars.sqf"
SURFACE_COLOUR = (
    ROOT / "addons" / "colourblind" / "functions" / "fnc_surfaceColourFor.sqf"
)

TABLE_BEGIN = "TOLERANCE_TABLE_BEGIN"
TABLE_END = "TOLERANCE_TABLE_END"

# A family row, for example `FAMILY RED HUE 0 25 SAT 0.35 VAL 0.20`. GREY has
# no hue window, and the file writes it as a pair of dashes.
FAMILY_RE = re.compile(
    r"^FAMILY\s+([A-Z]+)\s+HUE\s+(-|[\d.]+)\s+(-|[\d.]+)\s+SAT\s+([\d.]+)\s+VAL\s+([\d.]+)$"
)
BAND_RE = re.compile(r"^BAND\s+([a-z]+)\s+VAL\s+([\d.]+)\s+([\d.]+)$")

# The test order in the SQF body. GREY runs first because a low-saturation
# colour is grey at any hue, then the three hue windows in the file's order.
HUE_FAMILIES = ("RED", "AMBER", "GREEN")
REQUIRED_FAMILIES = ("RED", "AMBER", "GREEN", "GREY")

# The four shipped families. A CIVILIAN family is forbidden: vanilla ships one
# grey for both neutral and civilian, so no window can separate them.
FORBIDDEN_FAMILY = "CIVILIAN"


class Family(NamedTuple):
    hue_min: float | None
    hue_max: float | None
    sat_min: float
    val_min: float


def parse_tolerances(
    text: str,
) -> tuple[dict[str, Family], dict[str, tuple[float, float]]]:
    """Parse the machine-read tolerance table out of the SQF file."""
    if TABLE_BEGIN not in text or TABLE_END not in text:
        raise SystemExit(
            f"FAIL: {FUNCTION.name} has no {TABLE_BEGIN}..{TABLE_END} block"
        )
    block = text.split(TABLE_BEGIN, 1)[1].split(TABLE_END, 1)[0]

    families: dict[str, Family] = {}
    bands: dict[str, tuple[float, float]] = {}
    for raw in block.splitlines():
        line = raw.strip().lstrip("*").strip()
        family = FAMILY_RE.match(line)
        if family:
            name, hue_lo, hue_hi, sat, val = family.groups()
            families[name] = Family(
                None if hue_lo == "-" else float(hue_lo),
                None if hue_hi == "-" else float(hue_hi),
                float(sat),
                float(val),
            )
            continue
        band = BAND_RE.match(line)
        if band:
            name, lo, hi = band.groups()
            bands[name] = (float(lo), float(hi))

    if families.keys() != set(REQUIRED_FAMILIES):
        raise SystemExit(
            f"FAIL: parsed families {sorted(families)} in {FUNCTION.name}, "
            f"expected {sorted(REQUIRED_FAMILIES)}"
        )
    for name, family in families.items():
        if family.hue_min is not None:
            if not 0 <= family.hue_min <= family.hue_max <= 360:
                raise SystemExit(f"FAIL: {name} hue window is not inside 0 to 360")
        if not 0 <= family.sat_min <= 1 or not 0 <= family.val_min <= 1:
            raise SystemExit(f"FAIL: {name} floors are not inside 0 to 1")
    for name in ("dark", "mid", "bright"):
        if name not in bands:
            raise SystemExit(f"FAIL: no BAND {name} row in {FUNCTION.name}")
    return families, bands


def hsv(rgba: list[float]) -> tuple[float | None, float, float]:
    """Return (hue, saturation, value), mirroring the SQF body.

    A hue of None matches the SQF sentinel minus one: an achromatic colour has
    no hue, so no hue window matches it. The sector constants are 60 degrees to
    a sector, and the channel offsets are 0 for red, 2 for green and 4 for blue.
    """
    r, g, b = rgba[0], rgba[1], rgba[2]
    max_c = max(r, g, b)
    min_c = min(r, g, b)
    chroma = max_c - min_c
    value = max_c
    saturation = 0.0 if value <= 0 else chroma / value

    hue: float | None = None
    if chroma > 0:
        if max_c == r:
            sector = ((g - b) / chroma) % 6
        elif max_c == g:
            sector = ((b - r) / chroma) + 2
        else:
            sector = ((r - g) / chroma) + 4
        hue = 60 * sector
        if hue < 0:
            hue += 360
    return hue, saturation, value


def band_of(value: float, bands: dict[str, tuple[float, float]]) -> str:
    """Return the brightness band, mirroring the SQF body's strict compares."""
    dark_hi = bands["dark"][1]
    bright_lo = bands["bright"][0]
    if value < dark_hi:
        return "dark"
    if value > bright_lo:
        return "bright"
    return "mid"


def classify(
    rgba: list[float],
    families: dict[str, Family],
    bands: dict[str, tuple[float, float]],
) -> tuple[str, str] | None:
    """Mirror `FUNC(classifyColour)`. Return (family, band), or None for []."""
    if len(rgba) < 3:
        return None
    hue, saturation, value = hsv(rgba)

    grey = families["GREY"]
    if saturation < grey.sat_min and value >= grey.val_min:
        return ("GREY", band_of(value, bands))

    for name in HUE_FAMILIES:
        family = families[name]
        if (
            hue is not None
            and family.hue_min <= hue <= family.hue_max
            and saturation >= family.sat_min
            and value >= family.val_min
        ):
            return (name, band_of(value, bands))
    return None


def main() -> int:
    failures: list[str] = []
    families, bands = parse_tolerances(FUNCTION.read_text(encoding="utf-8"))

    if FORBIDDEN_FAMILY in families:
        failures.append(
            f"the classifier declares a {FORBIDDEN_FAMILY} family. Vanilla ships "
            "colorNeutral and colorCivilian as one grey, so no window can "
            "separate the two roles, and a Civilian window matches no shipped "
            "literal."
        )

    print("Parsed tolerances:")
    for name in REQUIRED_FAMILIES:
        family = families[name]
        window = (
            "no hue window"
            if family.hue_min is None
            else f"hue {family.hue_min:g} to {family.hue_max:g}"
        )
        print(
            f"  family {name:5s} {window:18s} "
            f"sat at least {family.sat_min:g}  val at least {family.val_min:g}"
        )
    for name in ("dark", "mid", "bright"):
        lo, hi = bands[name]
        print(f"  band   {name:6s} val {lo:g} to {hi:g}")

    fixture = json.loads(FIXTURE.read_text(encoding="utf-8"))
    literals = fixture["literals"]
    if not literals:
        failures.append(f"{FIXTURE.name} holds no literals")

    for entry in literals:
        rgba = entry["rgba"]
        expected = entry["family"]
        source = (
            f"{entry['source_file']}:{entry['source_line']} {entry['source_class']}"
        )
        got = classify(rgba, families, bands)

        if expected is None:
            if got is not None:
                failures.append(
                    f"{rgba} from {source}: classifier returns {got[0]}, "
                    "the fixture labels it as no family this addon owns"
                )
            continue

        if got is None:
            failures.append(
                f"{rgba} from {source}: classifier returns no family, "
                f"the fixture labels it {expected}"
            )
        elif got[0] != expected:
            failures.append(
                f"{rgba} from {source}: classifier returns {got[0]}, "
                f"the fixture labels it {expected}"
            )

    # The objective palette entry has no producer on any path. A producer that
    # appears later makes the recorded residual stale, so the gate fails.
    for path in (APPLY_VARS, SURFACE_COLOUR):
        for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if "objective" in line.lower():
                failures.append(
                    f"{path.name}:{number} mentions the objective palette entry, "
                    "which has no producer on any path"
                )

    if failures:
        print("\nFAILURES:")
        for failure in failures:
            print(f"  - {failure}")
        return 1

    print(
        f"\n[verify_classifier] PASS: {len(literals)} hand-labelled fixture literals, "
        f"every family matches the tolerances parsed from {FUNCTION.name}, "
        "no CIVILIAN family, the objective palette entry has no producer"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
