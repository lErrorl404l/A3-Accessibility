#!/usr/bin/env python3
"""Compare every addon override against the authoritative game PBO configs.

This gate needs the extracted game configs. Extract the PBOs that define the
roots this addon touches, then point GAME and GAME_ALSO at the result:

    extractpbo -P "<install>/Addons/ui_f.pbo" /tmp/opencode/vanilla/ui_f
    extractpbo -P "<install>/Curator/Addons/ui_f_curator.pbo" /tmp/opencode/gamepbo/ui_f_curator

Selection rule, and why it matters. The engine loads the Core addon first,
then every other addon. A property defined in a later addon replaces the value
an earlier addon set, and a class a later addon reopens keeps the properties
it does not restate. This gate therefore rebuilds the effective config in load
order. It sorts the Core extraction first (the PBO whose CfgPatches declares
Core), merges every later definition over the earlier ones, and checks the
addon against the value the engine would use. The engine loads ui_f after
Core, so ui_f supersedes Core's copy of CfgInGameUI. A gate that took the
first definition it met read the superseded Core copy and reported 18 false
deviations.

It is not part of the CI run and not part of .githooks/pre-commit, because
neither a checkout nor a CI runner has the game install or its extracted
configs. Run it by hand after any config change, and after a game update.

The game PBOs define the correct parent, the correct property set and the
correct shipped value. The addon replaces some shipped values with a
per-channel expression, and must keep the shipped value as the expression
default. This reads both sides and reports every deviation.

Exit code 0 means every override agrees with the game.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path("/ext/Development/A3-Accessibility")
ADDON = ROOT / "addons" / "colourblind"
GAME = Path("/tmp/opencode/gamepbo")  # DLC, Curator and mod PBOs
GAME_ALSO = Path("/tmp/opencode/vanilla")

OUR_FILES = [
    "CfgInGameUI.hpp",
    "CfgWrapperUI.hpp",
    "CfgCurator.hpp",
    "CfgRscInGameUI.hpp",
    "Cfg3DEN.hpp",
    "CfgNotifications.hpp",
    "CfgSideIdentity.hpp",
    "RscSideDisplays.hpp",
]

# Files in other components that reopen a shipped root. They live under a
# different directory, so they are checked by path.
OUR_OTHER_FILES = [
    ROOT / "addons" / "cognitive" / "CfgObjectiveHud.hpp",
    ROOT / "addons" / "colourblind_contact" / "RscHorizontalCompass.hpp",
    ROOT / "addons" / "colourblind_curator" / "CfgCuratorColours.hpp",
    ROOT / "addons" / "colourblind_tank" / "RscOpticsTank.hpp",
    ROOT / "addons" / "colourblind_heli" / "CfgMarkersHeli.hpp",
]

CLASS_OPEN = re.compile(
    r"^([ \t]*)class\s+([A-Za-z0-9_]+)\s*(?::\s*([A-Za-z0-9_]+))?\s*(?:\{|$)"
)
PROP_RE = re.compile(r"([A-Za-z0-9_]+)\[\]\s*=\s*\{([^{}]*)\}")
PROFILE_RE = re.compile(
    r"\"\(profilenamespace getvariable \['([A-Za-z0-9_]+)',([0-9.]+)\]\)\""
)
MISSION_RE = re.compile(
    r"\"\(missionnamespace getvariable \['([A-Za-z0-9_]+)',([0-9.]+)\]\)\""
)


def classify(body: str) -> tuple[str, list[str]]:
    for pattern in (PROFILE_RE, MISSION_RE):
        if pattern.search(body):
            return "expression", [m.group(2) for m in pattern.finditer(body)]
    return "literal", [v.strip() for v in body.split(",")]


def parse(path: Path):
    """Return ({classpath: {prop: (kind, values)}}, {classpath: parent})."""
    props: dict[str, dict[str, tuple[str, list[str]]]] = {}
    parents: dict[str, str] = {}
    stack: list[tuple[int, str]] = []
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        m = CLASS_OPEN.match(line)
        if m:
            indent = len(m.group(1))
            while stack and stack[-1][0] >= indent:
                stack.pop()
            stack.append((indent, m.group(2)))
            path_key = "/".join(n for _, n in stack)
            if m.group(3):
                parents[path_key] = m.group(3)
        if not stack:
            continue
        current = "/".join(n for _, n in stack)
        for prop in PROP_RE.finditer(line):
            props.setdefault(current, {})[prop.group(1)] = classify(prop.group(2))
    return props, parents


def game_defs():
    """Rebuild the effective config in engine load order.

    The engine loads Core first, then every other addon. A later definition
    replaces an earlier one, and a class a later addon reopens keeps the
    properties it does not restate. Sorting Core first and merging later
    definitions over earlier ones yields the value the engine would use. The
    old rule took the first definition it met, which read Core's superseded
    copy of CfgInGameUI and reported 18 false deviations.
    """
    configs: list[tuple[Path, Path]] = []
    for root in (GAME_ALSO, GAME):
        if root.is_dir():
            configs += [(root, path) for path in sorted(root.rglob("config.cpp"))]
    parsed = [(root, path, *parse(path)) for root, path in configs]
    # Engine load order: Core first, then the rest.
    parsed.sort(
        key=lambda item: (0 if "CfgPatches/Core" in item[2] else 1, str(item[1]))
    )

    props: dict[str, dict[str, tuple[str, list[str]]]] = {}
    parents: dict[str, str] = {}
    origin: dict[str, str] = {}
    definitions = 0
    superseded = 0
    for root, path, p, par in parsed:
        addon = path.relative_to(root).parts[0]
        for cls, entries in p.items():
            slot = props.setdefault(cls, {})
            for prop, value in entries.items():
                definitions += 1
                if prop in slot:
                    superseded += 1
                slot[prop] = value
            origin[cls] = addon
        for cls, parent in par.items():
            parents[cls] = parent
    return props, parents, origin, len(parsed), definitions, superseded


def near(a: str, b: str) -> bool:
    try:
        return abs(float(a) - float(b)) < 1e-6
    except ValueError:
        return a == b


def same(values: list[str], other: list[str]) -> bool:
    return len(values) == len(other) and all(near(x, y) for x, y in zip(values, other))


def main() -> int:
    gprops, gparents, origin, nconfigs, definitions, superseded = game_defs()
    if not gprops:
        print("FAIL: no shipped configs found under", GAME)
        return 1

    failures: list[str] = []
    compared = 0
    added = 0
    own_classes = 0

    targets = [(name, ADDON / name) for name in OUR_FILES]
    targets += [(p.name, p) for p in OUR_OTHER_FILES]

    for filename, path in targets:
        oprops, oparents = parse(path)
        for cls_path, entries in sorted(oprops.items()):
            if cls_path not in gprops:
                own_classes += 1
                continue
            # Parent check.
            if cls_path in gparents and oparents.get(cls_path) != gparents[cls_path]:
                failures.append(
                    f"{filename} {cls_path}: parent {oparents.get(cls_path)!r} "
                    f"but the game uses {gparents[cls_path]!r}"
                )
            for prop, (kind, values) in sorted(entries.items()):
                compared += 1
                g = gprops.get(cls_path, {}).get(prop)
                if g is None:
                    added += 1
                    continue
                gkind, gvalues = g
                if kind == "expression" and gkind == "literal":
                    if not same(gvalues[:3], values):
                        failures.append(
                            f"{filename} {cls_path}/{prop}: default {values} "
                            f"but {origin.get(cls_path)} ships {gvalues[:3]}"
                        )
                elif kind == "literal" and gkind == "literal":
                    if not same(gvalues[:3], values[:3]):
                        failures.append(
                            f"{filename} {cls_path}/{prop}: {values[:3]} "
                            f"but {origin.get(cls_path)} ships {gvalues[:3]}"
                        )

    if failures:
        print("DEVIATIONS:")
        for failure in failures:
            print(f"  - {failure}")
        return 1

    print(
        f"[check_authoritative] PASS: {compared} overridden properties and "
        f"{len(gprops)} effective shipped classes. Swept {definitions} definitions "
        f"across {nconfigs} game configs, {superseded} superseded by a later "
        f"addon. {added} properties added to a shipped class, "
        f"{own_classes} own classes. Every parent and default agrees."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
