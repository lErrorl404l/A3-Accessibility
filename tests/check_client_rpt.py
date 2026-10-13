#!/usr/bin/env python3
"""Check a live client RPT for this addon.

The in-engine tier runs on a dedicated server, which has no renderer. The client
is the only place a rendered result can be seen, and the client RPT is the only
machine-readable record of it. This reads that RPT and reports:

1. whether the addon was loaded, and from where;
2. any vanilla parent this addon cleared, which drops the inherited properties;
3. any missing entry under a config root this addon overrides;
4. any script error that names this addon;
5. the addon's own diagnostic lines, so a probe result can be read back.

Usage:
    python3 tests/check_client_rpt.py [rpt file]
    python3 tests/check_client_rpt.py            # newest RPT in the default folder

Exit code 0 means nothing was found that this addon caused. A rendered claim
still needs a human to look at the screen.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

DEFAULT_DIR = Path(
    "/ext/SteamLibrary/steamapps/compatdata/107410/pfx/drive_c/users/steamuser"
    "/AppData/Local/Arma 3"
)

OURS = "a3acc"

# A vanilla parent this addon cleared. The engine reports it as 'X'->''.
CLEARED_PARENT = re.compile(r"Updating base class '[^']*'->''")

# Config roots this addon overrides. A missing entry under one is our defect.
OUR_ROOTS = (
    "CfgMarkers",
    "CfgGroupIcons",
    "CfgLocationTypes",
    "CfgMarkerColors",
    "CfgNotifications",
    "CfgInGameUI",
    "RscInGameUI",
    "CfgWrapperUI",
    "Cfg3DEN",
    "CfgCurator",
    "CfgORBATDefault",
    "RscChatListDefault",
    "RscCustomInfoAirborneMiniMap",
    "RscCustomInfoSensors",
    "RscDisplayCurator",
    "RscDisplayMultiplayer",
    "RscDisplayMultiplayerSetup",
    "RscHorizontalCompass",
)

# Engine noise that no addon change can remove.
BENIGN = (
    "not lowercase",
    "looped for animation",
    "Cannot open object",
    "No geometry and no visual shape",
    "is dependent on downloadable content",
)


def newest_rpt(directory: Path) -> Path | None:
    files = sorted(directory.glob("*.rpt"), key=lambda p: p.stat().st_mtime)
    return files[-1] if files else None


def main() -> int:
    if len(sys.argv) > 1:
        path = Path(sys.argv[1])
    else:
        found = newest_rpt(DEFAULT_DIR)
        if found is None:
            print(f"FAIL: no .rpt file under {DEFAULT_DIR}")
            print("Pass the path to an RPT file instead.")
            return 1
        path = found

    if not path.is_file():
        print(f"FAIL: {path} is not a file")
        return 1

    text = path.read_text(encoding="utf-8", errors="replace")
    lines = text.splitlines()

    loaded = [line for line in lines if OURS in line.lower() and "-mod=" in line]
    our_lines = [line for line in lines if OURS in line.lower()]
    cleared = [
        line for line in lines if CLEARED_PARENT.search(line) and OURS in line.lower()
    ]
    missing = [
        line
        for line in lines
        if "No entry '" in line and any(root in line for root in OUR_ROOTS)
    ]
    errors = [
        line
        for line in lines
        if re.search(r"\bError\b", line)
        and OURS in line.lower()
        and not any(b in line for b in BENIGN)
    ]
    probe = [line for line in lines if "[A3ACC" in line]

    print(f"file: {path.name}")
    print(f"lines: {len(lines)}")
    print(f"lines naming this addon: {len(our_lines)}")

    if not our_lines:
        print(
            "\nFAIL: no line in this RPT names this addon, so the run proves "
            "nothing. Load the addon, run the game again, and re-check."
        )
        return 1

    for line in loaded[:1]:
        print(f"launch line: {line.strip()[:160]}")

    if probe:
        print(f"\naddon diagnostic lines ({len(probe)}):")
        for line in probe[:20]:
            print("  " + line.strip()[:160])

    failures = 0
    if cleared:
        failures += 1
        print(f"\nFAIL: {len(cleared)} cleared vanilla parent(s)")
        for line in cleared[:10]:
            print("  " + line.strip()[:160])
    if missing:
        failures += 1
        print(f"\nFAIL: {len(missing)} missing config entry line(s) under our roots")
        for line in missing[:10]:
            print("  " + line.strip()[:160])
    if errors:
        failures += 1
        print(f"\nFAIL: {len(errors)} script error(s) naming this addon")
        for line in errors[:10]:
            print("  " + line.strip()[:160])

    if failures:
        return 1

    print(
        "\n[check_client_rpt] PASS: the addon loaded, cleared no vanilla parent, "
        "and produced no error under its own roots"
    )
    print("A rendered claim still needs a human to look at the screen.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
