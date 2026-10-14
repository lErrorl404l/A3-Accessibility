#!/usr/bin/env python3
"""Offline gate for the walk's fence table.

The walk in `addons/colourblind/functions/fnc_recolourControls.sqf` holds one
fence table and one getter table. The fence maps `[display class, control class,
property]` to a role. The getter table bridges the config property names the fence
stores to the `ctrl*` commands the walk calls. This gate parses both tables and
asserts the facts the design rests on.

The assertions:

1. Every fence role is one of the four the mapper admits (`enemy`, `friendly`,
   `neutral`, `unknown`). No entry uses the addon's older surface keys.
2. Every entry names a display class, a control class and a property.
3. THE KEY IS UNIQUE. No two entries share `[display class, control class,
   property]` with different roles. This is the assertion the whole design rests
   on: without it a collision such as the optics `CA_VisionMode` pair passes every
   other check and the walk applies whichever entry it finds first.
4. No entry uses a display class the registration event reports ambiguously:
   `RscUnitInfo`, `RscStanceInfo`, `RscStaminaBar` or `RscCustomInfoMiniMap`.
5. Every fence property is a key in the getter table. The fence stores CONFIG
   property names and the walk holds COMMAND names, so that table is the only
   bridge between the two.
6. EVERY SHIPPED DEFAULT THE FENCE RELIES ON IS IN THE CURATED FIXTURE. For each
   entry the shipped default of that control's property must appear in
   `tests/fixtures/colour_literals.json` with a family, not a null label. Without
   this, a fenced control whose literal is missing from the fixture classifies to
   nothing, the walk skips it, and its override is retired anyway.
7. THE ROLE MUST MATCH THE SHIPPED MEANING. For every entry whose control class
   has the form `Side<KEY>`, the role must equal the palette class the addon
   already assigns that side key in the `_keyToClass` table of
   `fnc_surfaceColourFor.sqf`, and that class must be one of the four roles. The
   mapping is parsed from that file, never restated here. Without this, flipping
   the curator `SideIndependent` role from `neutral` to `enemy` passes every gate,
   and the walk repaints the Independent row with the enemy colour.
8. THE FENCE'S REQUIRED COVERAGE. The fence's set of
   `(display class, control class, property)` triples must equal
   `REQUIRED_COVERAGE`, the two `RscDisplayCurator` colour overrides the addon
   ships and retires. The list is written once, here, and imported by the
   retirement gate, so coverage and retirement cannot drift apart.

It needs no game and no SQF interpreter. Exit code 0 means all assertions pass.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FUNCTION = ROOT / "addons" / "colourblind" / "functions" / "fnc_recolourControls.sqf"
FIXTURE = Path(__file__).resolve().parent / "fixtures" / "colour_literals.json"
SURFACE_FUNCTION = (
    ROOT / "addons" / "colourblind" / "functions" / "fnc_surfaceColourFor.sqf"
)

TABLE_BEGIN = "GETTER_TABLE_BEGIN"
TABLE_END = "GETTER_TABLE_END"
GETTER_RE = re.compile(r"^GETTER\s+(\S+)\s+SETTER\s+(\S+)\s+PROPERTY\s+(\S+)$")

# A `Side<KEY>` control class, and one pair inside `_keyToClass`.
SIDE_CONTROL_RE = re.compile(r"^Side([A-Za-z]+)$")
KEY_TO_CLASS_PAIR_RE = re.compile(r'\[\s*"([A-Za-z]+)"\s*,\s*"([a-z]+)"\s*\]')

# The fence literal, and one four-string tuple inside it.
FENCE_BLOCK_RE = re.compile(r"_fence\s*=\s*\[(.*?)\]\s*;", re.DOTALL)
FENCE_ROW_RE = re.compile(
    r'\[\s*"([^"]*)"\s*,\s*"([^"]*)"\s*,\s*"([^"]*)"\s*,\s*"([^"]*)"\s*\]'
)

# The four roles the mapper admits. The older surface keys are forbidden here,
# because FUNC(colourForRole) takes the palette class names and returns nothing for
# OPFOR, BLUFOR or Independent.
ROLES = ("enemy", "friendly", "neutral", "unknown")
OLD_VOCABULARY = ("OPFOR", "BLUFOR", "Independent", "Civilian")

# The display classes the registration event reports for more than one surface, so
# a fence entry under one of them is an ambiguous key by construction.
SHARED_REGISTRATION_CLASSES = (
    "RscUnitInfo",
    "RscStanceInfo",
    "RscStaminaBar",
    "RscCustomInfoMiniMap",
)

# The fence's required coverage. It is exactly the two RscDisplayCurator colour
# overrides the addon ships in colourblind_curator/CfgCuratorColours.hpp and
# retires in todo 11, so this list and the retirement set are ONE list. The
# retirement gate imports it rather than restating the two surfaces.
REQUIRED_COVERAGE = (
    ("RscDisplayCurator", "SideOPFOR", "colorText"),
    ("RscDisplayCurator", "SideIndependent", "colorText"),
)


def parse_fence(text: str) -> list[tuple[str, str, str, str]]:
    """Parse the four-string tuples out of the `_fence` literal."""
    block = FENCE_BLOCK_RE.search(text)
    if block is None:
        raise SystemExit(f"FAIL: {FUNCTION.name} has no `_fence = [ ... ];` block")
    rows = FENCE_ROW_RE.findall(block.group(1))
    if not rows:
        raise SystemExit(f"FAIL: the fence in {FUNCTION.name} holds no entries")
    return [(a, b, c, d) for a, b, c, d in rows]


def parse_getters(text: str) -> dict[str, tuple[str, str]]:
    """Parse the machine-read getter table into property -> (getter, setter)."""
    if TABLE_BEGIN not in text or TABLE_END not in text:
        raise SystemExit(
            f"FAIL: {FUNCTION.name} has no {TABLE_BEGIN}..{TABLE_END} block"
        )
    block = text.split(TABLE_BEGIN, 1)[1].split(TABLE_END, 1)[0]
    getters: dict[str, tuple[str, str]] = {}
    for raw in block.splitlines():
        line = raw.strip().lstrip("*").strip()
        match = GETTER_RE.match(line)
        if match:
            getter, setter, prop = match.groups()
            getters[prop] = (getter, setter)
    if not getters:
        raise SystemExit(f"FAIL: the getter table in {FUNCTION.name} holds no rows")
    return getters


def parse_side_classes(text: str) -> dict[str, str]:
    """Parse `_keyToClass` from the surface function into side key -> class.

    The gate never holds a second copy of the side-key mapping, because a second
    copy is what drifts from the addon.
    """
    if "_keyToClass" not in text:
        raise SystemExit(f"FAIL: {SURFACE_FUNCTION.name} carries no _keyToClass table")
    block = text.split("_keyToClass", 1)[1].split("];", 1)[0]
    return dict(KEY_TO_CLASS_PAIR_RE.findall(block))


def fixture_defaults() -> dict[str, str]:
    """Return the fixture's source_class -> family, dropping the art entries."""
    fixture = json.loads(FIXTURE.read_text(encoding="utf-8"))
    literals = fixture["literals"]
    if not literals:
        raise SystemExit(f"FAIL: {FIXTURE.name} holds no literals")
    defaults: dict[str, str] = {}
    for entry in literals:
        if entry["family"] is None:
            continue
        defaults[entry["source_class"]] = entry["family"]
    return defaults


def default_for(
    display_class: str, control: str, prop: str, defaults: dict[str, str]
) -> str | None:
    """Find the fixture default for one fence entry by its config path."""
    suffix = f"{control}/{prop}"
    for source_class, family in defaults.items():
        segments = source_class.split("/")
        if segments[0] == display_class and source_class.endswith(suffix):
            return family
    return None


def main() -> int:
    failures: list[str] = []
    text = FUNCTION.read_text(encoding="utf-8")
    fence = parse_fence(text)
    getters = parse_getters(text)
    defaults = fixture_defaults()
    side_classes = parse_side_classes(SURFACE_FUNCTION.read_text(encoding="utf-8"))

    print(f"Fence entries: {len(fence)}")
    print(f"Getter table keys: {len(getters)}")
    print(f"Shipped side classes parsed: {len(side_classes)}")
    print(f"Required coverage: {len(REQUIRED_COVERAGE)} surfaces")

    keys: dict[tuple[str, str, str], str] = {}
    for display_class, control, prop, role in fence:
        where = f"{display_class}/{control}/{prop}"

        if role not in ROLES:
            failures.append(f"{where}: role {role!r} is not one of the four {ROLES}")
        if role in OLD_VOCABULARY:
            failures.append(
                f"{where}: role {role!r} uses the addon's older surface vocabulary"
            )
        if not display_class or not control or not prop:
            failures.append(
                f"{where}: an entry names an empty display, control or property"
            )
            continue

        if display_class in SHARED_REGISTRATION_CLASSES:
            failures.append(
                f"{where}: display class {display_class!r} is a shared registration "
                "class, so the key is ambiguous by construction"
            )

        # A `Side<KEY>` control must carry the role the addon already assigns that
        # side key, so the fence cannot repaint a side with another side's colour.
        side = SIDE_CONTROL_RE.match(control)
        if side:
            key = side.group(1)
            shipped = side_classes.get(key)
            if shipped is None:
                failures.append(
                    f"{where}: control {control!r} names a side key {key!r} that "
                    f"{SURFACE_FUNCTION.name} assigns no class"
                )
            elif shipped not in ROLES:
                failures.append(
                    f"{where}: the shipped class for {key!r} is {shipped!r}, which "
                    f"is not one of the four roles {ROLES}"
                )
            elif role != shipped:
                failures.append(
                    f"{where}: role {role!r} does not match the shipped class "
                    f"{shipped!r} for {key!r}, so the walk repaints this surface "
                    "with the wrong colour"
                )

        key = (display_class, control, prop)
        if key in keys and keys[key] != role:
            failures.append(
                f"{where}: key {key} is used twice with roles {keys[key]!r} and "
                f"{role!r}. The key must be unique, or the walk applies whichever "
                "entry it finds first"
            )
        keys[key] = role

        if prop not in getters:
            failures.append(
                f"{where}: property {prop!r} is not a key in the getter table, so "
                "the walk cannot read or write it"
            )

        if default_for(display_class, control, prop, defaults) is None:
            failures.append(
                f"{where}: no shipped default for this control's property is in "
                f"{FIXTURE.name} with a family, so the walk would skip it"
            )

    roles_used = sorted({role for _, _, _, role in fence})
    print(f"Roles used: {roles_used}")
    print(f"Four-role domain: {ROLES}")

    # The fence's required coverage, and the retirement set, are one list.
    fence_keys = set(keys)
    required = set(REQUIRED_COVERAGE)
    for triple in sorted(required - fence_keys):
        failures.append(
            f"required coverage {triple} is absent from the fence, so its override "
            "is retired while the walk never recolours it"
        )
    for triple in sorted(fence_keys - required):
        failures.append(
            f"fence entry {triple} is not in REQUIRED_COVERAGE, so the fence and "
            "the retirement set disagree"
        )

    if failures:
        print("\nFAILURES:")
        for failure in failures:
            print(f"  - {failure}")
        return 1

    print(
        f"\n[verify_fence] PASS: {len(fence)} fence entries, every role in the "
        f"four-role domain {ROLES}, every key unique, every property getter-backed, "
        "every shipped default in the fixture, every side role matching the shipped "
        f"class, the fence covering exactly the {len(REQUIRED_COVERAGE)} required "
        "surfaces"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
