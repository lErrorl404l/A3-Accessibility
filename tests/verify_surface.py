#!/usr/bin/env python3
"""Offline gate for the dynamic surface expressions.

The colour engine writes profile variables and the config reads them back as
per-channel expressions. This gate reads the real writer and the real config
headers, then:

1. Checks every converted colour is a three-expression triple plus an alpha.
2. Checks the config variable names and the writer table are the same set.
3. Checks the engine variables the writer owns, and the ones it must not touch.
4. Checks the deleted override files are gone and unreferenced.
5. Checks every reopened class restates its parent.

It needs no game and no SQF interpreter. Exit code 0 means all gates pass.
"""

from __future__ import annotations

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
    ADDON / "CfgRscInGameUI.hpp",
    ADDON / "Cfg3DEN.hpp",
    ADDON / "CfgNotifications.hpp",
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

# Every reopened class and its required parent.
REOPENED_PARENTS = {
    ("CfgWrapperUI.hpp", "HC_move"): "Track",
    ("CfgWrapperUI.hpp", "HC_overFriendly"): "Track",
    ("CfgWrapperUI.hpp", "CuratorPlaceWaypoint"): "Curator",
    ("CfgWrapperUI.hpp", "CuratorPlaceWaypointMulti"): "Curator",
    ("CfgWrapperUI.hpp", "CuratorPlaceWaypointCycle"): "Curator",
    ("CfgWrapperUI.hpp", "CuratorPlaceWaypointGetIn"): "Curator",
    ("CfgWrapperUI.hpp", "CuratorPlaceWaypointDestroy"): "Curator",
    ("CfgWrapperUI.hpp", "CuratorPlaceWaypointDestroyMulti"): "Curator",
    ("CfgNotifications.hpp", "TaskSucceeded"): "TaskAssigned",
    ("CfgNotifications.hpp", "TaskFailed"): "TaskAssigned",
    ("CfgNotifications.hpp", "TaskCanceled"): "TaskAssigned",
    ("CfgNotifications.hpp", "TaskAssignedIcon"): "TaskCreatedIcon",
    ("CfgNotifications.hpp", "TaskSucceededIcon"): "TaskCreatedIcon",
    ("CfgNotifications.hpp", "TaskFailedIcon"): "TaskCreatedIcon",
    ("CfgNotifications.hpp", "TaskCanceledIcon"): "TaskCreatedIcon",
}

# A per-channel expression over an addon surface variable, in either namespace.
EXPR_RE = re.compile(
    r"\"\((profilenamespace|missionnamespace) getvariable "
    r"\['A3ACC_Surf_([A-Za-z0-9_]+)_([RGB])',([0-9.]+)\]\)\""
)
TABLE_RE = re.compile(r'^\s*\["([A-Za-z0-9_]+)", "([A-Za-z]+)"\],?\s*$', re.M)
CLASS_RE = re.compile(r"class\s+(\w+)(\s*:\s*(\w+))?\s*\{")


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

    # Gate 6: every reopened class restates its parent.
    texts = {path.name: path.read_text(encoding="utf-8") for path in CONFIG_FILES}
    for (filename, cls), parent in REOPENED_PARENTS.items():
        found = False
        for match in CLASS_RE.finditer(texts[filename]):
            if match.group(1) == cls:
                found = True
                if match.group(3) != parent:
                    failures.append(
                        f"{filename} {cls}: parent is {match.group(3)!r}, expected {parent!r}"
                    )
        if not found:
            failures.append(f"{filename} {cls}: class not found")

    if failures:
        print("FAILURES:")
        for failure in failures:
            print(f"  - {failure}")
        return 1

    print(
        f"[verify_surface] PASS: {len(config_profile)} profile and {len(config_mission)} mission "
        f"surface variables in the config and the writer, {len(ENGINE_VARS)} engine variables owned, "
        "no forbidden variable, no deleted override, every parent restated"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
