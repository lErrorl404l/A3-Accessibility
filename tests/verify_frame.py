#!/usr/bin/env python3
"""Offline gate for the frame parameter table.

The table in `addons/colourblind/functions/fnc_frameParams.sqf` returns the six
`ppEffectAdjust` values one colour-correction mode applies to the whole rendered
frame. This gate parses that table out of the SQF, with no game and no SQF
interpreter, and asserts:

1. Five modes, each returning EXACTLY SIX elements, in the documented order:
   brightness, contrast, offset, the four-element blend array, the four-element
   colorize array and the four-element luminance-weights array.
2. The shapes are Number, Number, Number, four-element Array, four-element
   Array, four-element Array. No seventh element appears, and no element is a
   numeric array of ten or more numbers.
3. Mode 0 is the identity, and element six is the documented luminance default
   0.299, 0.587, 0.114, 0 in every mode.
4. Every value is inside its documented range. The wiki gives brightness 0 to 2,
   the array channels 0 to 1, and the weight channels 0 to 1. The wiki leaves the
   contrast and offset upper bounds open, so this addon bounds the contrast at 4
   and the offset at plus or minus 1, and states that bound here.

The scripting API also accepts a SEVEN-element form, whose seventh array is an
optional radial ellipse for Arma 3. This addon uses the six-element form
deliberately, because the seventh element's semantics are undocumented and are
probed in todo 15. This gate fails on a seventh element.

It needs no game and no SQF interpreter. Exit code 0 means all gates pass.
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FUNCTION = ROOT / "addons" / "colourblind" / "functions" / "fnc_frameParams.sqf"
PREP = ROOT / "addons" / "colourblind" / "XEH_PREP.hpp"

MODES = ["Off", "Protan", "Deutan", "Tritan", "Achromatopsia"]
ELEMENT_COUNT = 6
ARRAY_ELEMENT_INDEXES = (3, 4, 5)

BRIGHTNESS_RANGE = (0.0, 2.0)
CONTRAST_RANGE = (0.0, 4.0)
OFFSET_RANGE = (-1.0, 1.0)
CHANNEL_RANGE = (0.0, 1.0)

WEIGHTS_DEFAULT = [0.299, 0.587, 0.114, 0.0]
IDENTITY = [1.0, 1.0, 0.0, [0.0, 0.0, 0.0, 0.0], [1.0, 1.0, 1.0, 1.0], WEIGHTS_DEFAULT]

TABLE_MARKER = "private _table = ["


class SqfArrays:
    """A reader for a nested SQF array of numbers, comments removed."""

    def __init__(self, text: str, index: int) -> None:
        self.text = text
        self.index = index

    def value(self) -> object:
        self._skip_space()
        if self.text[self.index] == "[":
            return self.array()
        return self._number()

    def array(self) -> list[object]:
        if self.text[self.index] != "[":
            raise ValueError(f"expected '[' at offset {self.index}")
        self.index += 1
        items: list[object] = []
        self._skip_space()
        if self.text[self.index] == "]":
            self.index += 1
            return items
        while True:
            items.append(self.value())
            self._skip_space()
            char = self.text[self.index]
            if char == ",":
                self.index += 1
                continue
            if char == "]":
                self.index += 1
                return items
            raise ValueError(f"unexpected {char!r} at offset {self.index}")

    def _number(self) -> float:
        start = self.index
        while (
            self.index < len(self.text) and self.text[self.index] in "0123456789.+-eE"
        ):
            self.index += 1
        if self.index == start:
            raise ValueError(f"expected a number at offset {self.index}")
        return float(self.text[start : self.index])

    def _skip_space(self) -> None:
        while self.index < len(self.text) and self.text[self.index] in " \t\r\n":
            self.index += 1


def without_comments(text: str) -> str:
    return "\n".join(line.split("//", 1)[0] for line in text.splitlines())


def parse_table() -> list[list[object]]:
    text = without_comments(FUNCTION.read_text(encoding="utf-8"))
    if TABLE_MARKER not in text:
        raise SystemExit(f"FAIL: {FUNCTION.name} has no {TABLE_MARKER!r}")
    start = text.index("[", text.index(TABLE_MARKER))
    table = SqfArrays(text, start).array()
    if len(table) != len(MODES):
        raise SystemExit(
            f"FAIL: expected {len(MODES)} mode rows in {FUNCTION.name}, found {len(table)}"
        )
    return table


def is_number(value: object) -> bool:
    return isinstance(value, (int, float)) and not isinstance(value, bool)


def numeric_arrays(value: object) -> list[list[object]]:
    """Return every numeric array nested anywhere inside value."""
    found: list[list[object]] = []
    if isinstance(value, list):
        found.append(value)
        for item in value:
            found.extend(numeric_arrays(item))
    return found


def in_range(value: float, bounds: tuple[float, float]) -> bool:
    return bounds[0] <= value <= bounds[1]


def check_registered(failures: list[str]) -> None:
    if not PREP.is_file():
        failures.append(f"{PREP.name} is missing")
        return
    if "PREP(frameParams)" not in PREP.read_text(encoding="utf-8"):
        failures.append(f"{PREP.name} does not register PREP(frameParams)")


def main() -> int:
    failures: list[str] = []
    table = parse_table()

    for mode, row in enumerate(table):
        name = MODES[mode]

        if len(row) != ELEMENT_COUNT:
            failures.append(
                f"mode {mode} {name}: {len(row)} elements, expected exactly {ELEMENT_COUNT}"
            )
            continue

        for index in (0, 1, 2):
            if not is_number(row[index]):
                failures.append(f"mode {mode} {name}: element {index} is not a Number")
        for index in ARRAY_ELEMENT_INDEXES:
            if not isinstance(row[index], list) or len(row[index]) != 4:
                failures.append(
                    f"mode {mode} {name}: element {index} is not a four-element Array"
                )

        if not all(is_number(row[index]) for index in (0, 1, 2)):
            continue
        if not all(
            isinstance(row[index], list) and len(row[index]) == 4
            for index in ARRAY_ELEMENT_INDEXES
        ):
            continue

        if not in_range(row[0], BRIGHTNESS_RANGE):
            failures.append(
                f"mode {mode} {name}: brightness {row[0]} outside {BRIGHTNESS_RANGE}"
            )
        if not in_range(row[1], CONTRAST_RANGE):
            failures.append(
                f"mode {mode} {name}: contrast {row[1]} outside {CONTRAST_RANGE}"
            )
        if not in_range(row[2], OFFSET_RANGE):
            failures.append(
                f"mode {mode} {name}: offset {row[2]} outside {OFFSET_RANGE}"
            )

        for index in ARRAY_ELEMENT_INDEXES:
            for channel, value in enumerate(row[index]):
                if not is_number(value):
                    failures.append(
                        f"mode {mode} {name}: element {index} channel {channel} is not a Number"
                    )
                elif not in_range(value, CHANNEL_RANGE):
                    failures.append(
                        f"mode {mode} {name}: element {index} channel {channel} "
                        f"value {value} outside {CHANNEL_RANGE}"
                    )

        if row[ARRAY_ELEMENT_INDEXES[-1]] != WEIGHTS_DEFAULT:
            failures.append(
                f"mode {mode} {name}: element 5 weights {row[5]} are not the documented "
                f"default {WEIGHTS_DEFAULT}"
            )

    for mode, row in enumerate(table):
        for array in numeric_arrays(row):
            if len(array) >= 10:
                failures.append(
                    f"mode {mode} {MODES[mode]}: a numeric array of {len(array)} "
                    "numbers appears. No element may hold ten or more"
                )

    if table and table[0] != IDENTITY:
        failures.append(f"mode 0 Off is not the identity. Got {table[0]}")

    check_registered(failures)

    print("Frame parameters (six documented ppEffectAdjust values per mode):")
    for mode, row in enumerate(table):
        if len(row) == ELEMENT_COUNT:
            print(
                f"  mode {mode} {MODES[mode]:14s} brightness {row[0]:>5} contrast "
                f"{row[1]:>5} offset {row[2]:>5} blend {row[3]} colorize {row[4]} "
                f"weights {row[5]}"
            )
        else:
            print(f"  mode {mode} {MODES[mode]:14s} {len(row)} elements")
    print(
        f"  identity check (mode 0): {'ok' if table and table[0] == IDENTITY else 'FAIL'}"
    )

    if failures:
        print("\nFAILURES:")
        for failure in failures:
            print(f"  - {failure}")
        return 1

    print(
        f"\n[verify_frame] PASS: {len(table)} modes, exactly {ELEMENT_COUNT} elements each, "
        "mode 0 is the identity, every value inside its documented range, no seventh element"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
