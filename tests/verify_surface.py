#!/usr/bin/env python3
"""Offline gate for the dynamic surface expressions.

The colour engine writes profile variables and the config reads them back as
per-channel expressions. This gate reads the real writer and the real config
headers, then:

1. Checks every converted colour is a three-expression triple plus an alpha.
2. Checks the config variable names and the writer table are the same set.
3. Checks the engine variables the writer owns, and the ones it must not touch.
4. Checks the deleted override files are gone and unreferenced.
5. Checks every class path states the parent the shipped config states.
6. Checks every forward declaration is one the generator checked against the game.

It needs no game and no SQF interpreter. Exit code 0 means all gates pass.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ADDON = ROOT / "addons" / "colourblind"
APPLY_VARS = ADDON / "functions" / "fnc_applyVars.sqf"
CONFIG = ADDON / "config.cpp"

CONFIG_FILES = [
    ADDON / "CfgInGameUI.hpp",
    ADDON / "CfgWrapperUI.hpp",
    ADDON / "CfgCurator.hpp",
    ADDON / "CfgRscInGameUI.hpp",
    ADDON / "Cfg3DEN.hpp",
    ADDON / "CfgNotifications.hpp",
    ADDON / "CfgSideIdentity.hpp",
    ADDON / "RscSideDisplays.hpp",
]

DELETED_FILES = [
    ADDON / "CfgMarkerColors.hpp",
    ADDON / "CfgMarkers.hpp",
    ADDON / "CfgGroupIcons.hpp",
    ADDON / "CfgLocationTypes.hpp",
]

# The engine variables the writer owns. Alpha is left to the player.
ENGINE_VARS = [
    "Map_BLUFOR",
    "Map_OPFOR",
    "Map_Independent",
    "Map_Civilian",
    "Map_Unknown",
    "IGUI_ERROR_RGB",
    "IGUI_WARNING_RGB",
    "IGUI_TACTPING_RGB",
]

# The engine variables the writer must not touch.
FORBIDDEN_VARS = ["IGUI_TEXT_RGB", "IGUI_BCG_RGB", "GUI_BCG_RGB"]

# The expected parent for every class path in every CONFIG_FILES file. The map
# is generated from the shipped game config by tests/gen_expected_parents.py
# and committed at tests/expected_parents.json, so this gate needs no game
# install at run time. Regenerate it after a config change or a game update:
#
#     python3 tests/gen_expected_parents.py
#
# A null value means the shipped config states no parent, so the reopen must
# state none either. The map is keyed by the full class path, not by class
# name, because leaf names collide: 2D, 3D, controls and Controls each appear
# under many parents.
EXPECTED_PARENTS_FILE = Path(__file__).resolve().parent / "expected_parents.json"


# A class block opener, by indentation, so the class path can be rebuilt.
CLASS_PATH_OPEN = re.compile(
    r"^([ \t]*)class\s+([A-Za-z0-9_]+)\s*(?::\s*([A-Za-z0-9_]+))?\s*(?:\{|$)"
)

# A forward declaration, `class X;`. It names a class defined elsewhere and has
# no body, so it opens no scope and states no parent. CLASS_PATH_OPEN does not
# match it, because the line ends in a semicolon. It still has to be checked: a
# misspelled name here is invisible to every other gate.
CLASS_FORWARD = re.compile(r"^([ \t]*)class\s+([A-Za-z0-9_]+)\s*;\s*$")


def forward_declarations(text: str) -> list[str]:
    """Return the forward-declared class names, in file order, without repeats."""
    names: list[str] = []
    for line in text.splitlines():
        match = CLASS_FORWARD.match(line)
        if match and match.group(2) not in names:
            names.append(match.group(2))
    return names


def class_declarations(text: str) -> dict[str, str | None]:
    """Return {class path: declared parent or None} for every class block."""
    stack: list[tuple[int, str]] = []
    found: dict[str, str | None] = {}
    for line in text.splitlines():
        match = CLASS_PATH_OPEN.match(line)
        if match:
            indent = len(match.group(1))
            while stack and stack[-1][0] >= indent:
                stack.pop()
            stack.append((indent, match.group(2)))
            found["/".join(name for _, name in stack)] = match.group(3)
    return found


# A per-channel expression over an addon surface variable, in either namespace.
EXPR_RE = re.compile(
    r"\"\((profilenamespace|missionnamespace) getvariable "
    r"\['A3ACC_Surf_([A-Za-z0-9_]+)_([RGB])',([0-9.]+)\]\)\""
)
TABLE_RE = re.compile(r'^\s*\["([A-Za-z0-9_]+)", "([A-Za-z]+)"\],?\s*$', re.M)


def table_block(text: str, marker: str) -> str:
    split = text.split(marker, 1)
    if len(split) != 2:
        return ""
    return split[1].split("];", 1)[0]


def main() -> int:
    failures: list[str] = []

    # Gate 1 and 2: the config triples and the writer tables are the same set,
    # per namespace.
    apply_text = APPLY_VARS.read_text(encoding="utf-8")
    profile_table = {
        m.group(1)
        for m in TABLE_RE.finditer(table_block(apply_text, "private _surfaceVars = ["))
    }
    mission_table = {
        m.group(1)
        for m in TABLE_RE.finditer(table_block(apply_text, "private _missionVars = ["))
    }
    if not profile_table:
        failures.append("fnc_applyVars.sqf: the _surfaceVars table is empty")
    if not mission_table:
        failures.append("fnc_applyVars.sqf: the _missionVars table is empty")

    config_profile: set[str] = set()
    config_mission: set[str] = set()
    channels: dict[str, set[str]] = {}
    for path in CONFIG_FILES:
        text = path.read_text(encoding="utf-8")
        for match in EXPR_RE.finditer(text):
            namespace, name, channel, _default = match.groups()
            (config_profile if namespace == "profilenamespace" else config_mission).add(
                name
            )
            channels.setdefault(name, set()).add(channel)

    for name in sorted(config_profile - profile_table):
        failures.append(
            f"config reads profile variable {name} but the writer has no such variable"
        )
    for name in sorted(profile_table - config_profile):
        failures.append(
            f"the writer writes profile variable {name} but no config reads it"
        )
    for name in sorted(config_mission - mission_table):
        failures.append(
            f"config reads mission variable {name} but the writer has no such variable"
        )
    for name in sorted(mission_table - config_mission):
        failures.append(
            f"the writer writes mission variable {name} but no config reads it"
        )

    # The engine evaluates CfgInGameUI/MPTable before the profile namespace
    # exists. A profile expression there fails the startup with "Trying to get
    # namespace profile but world is not initialized yet" and then "Application
    # terminated intentionally", so the gate refuses one. The mission namespace
    # holds no value that early, so the expression resolves to its default
    # rather than terminating the game.
    ingameui = CONFIG_FILES[0].read_text(encoding="utf-8")
    for block in re.findall(r"class MPTable \{(.*?)\n    \};", ingameui, re.S):
        if "profilenamespace" in block:
            failures.append(
                "CfgInGameUI.hpp class MPTable reads the profile namespace, "
                "which terminates the game at startup"
            )
        if "missionnamespace" not in block:
            failures.append(
                "CfgInGameUI.hpp class MPTable does not read the mission namespace"
            )

    # Gate 3: every surface colour is a triple.
    for name, found in sorted(channels.items()):
        if found != {"R", "G", "B"}:
            failures.append(f"{name}: channels {sorted(found)}, expected R, G, B")

    # Gate 4: the engine variables, owned and forbidden.
    for var in ENGINE_VARS:
        if f'"{var}"' not in apply_text:
            failures.append(f"fnc_applyVars.sqf does not write {var}")
    for var in FORBIDDEN_VARS:
        if var in apply_text:
            failures.append(f"fnc_applyVars.sqf must not touch {var}")

    # Gate 5: the deleted files are gone and unreferenced.
    config_text = CONFIG.read_text(encoding="utf-8")
    for path in DELETED_FILES:
        if path.exists():
            failures.append(f"{path.name} still exists")
        if path.name in config_text:
            failures.append(f"config.cpp still includes {path.name}")

    # Gate 6: every class path states exactly the parent the shipped config
    # states. Equality catches both faults: a dropped restatement, and a parent
    # the game does not have.
    expected = json.loads(EXPECTED_PARENTS_FILE.read_text(encoding="utf-8"))
    texts = {path.name: path.read_text(encoding="utf-8") for path in CONFIG_FILES}
    gated = 0
    gated_decls = 0
    for filename, entry in expected.items():
        by_path = entry["classes"]
        declared = class_declarations(texts[filename])
        for cls_path, parent in by_path.items():
            gated += 1
            if cls_path not in declared:
                failures.append(f"{filename} {cls_path}: class not found")
            elif declared[cls_path] != parent:
                failures.append(
                    f"{filename} {cls_path}: parent is {declared[cls_path]!r}, "
                    f"expected {parent!r}"
                )
        for cls_path in declared:
            if cls_path not in by_path:
                failures.append(
                    f"{filename} {cls_path}: not in the expected parent map, "
                    "regenerate tests/expected_parents.json"
                )

        # Gate 7: the forward declarations are the ones the generator recorded.
        # The generator runs with the game extracted and refuses a name the game
        # does not define, so a recorded name is a checked name. A new or changed
        # declaration fails here until the generator has checked it.
        names = forward_declarations(texts[filename])
        gated_decls += len(names)
        if names != entry["declarations"]:
            failures.append(
                f"{filename}: forward declarations are {names}, "
                f"expected {entry['declarations']}. "
                "Run python3 tests/gen_expected_parents.py to check them."
            )

    if failures:
        print("FAILURES:")
        for failure in failures:
            print(f"  - {failure}")
        return 1

    print(
        f"[verify_surface] PASS: {len(config_profile)} profile and {len(config_mission)} mission "
        f"surface variables in the config and the writer, {len(ENGINE_VARS)} engine variables owned, "
        "no forbidden variable, no deleted override, "
        f"{gated} class paths restate the parent the shipped config states, "
        f"{gated_decls} forward declarations match the checked list"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
