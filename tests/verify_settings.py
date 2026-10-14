#!/usr/bin/env python3
"""Offline gate for the registered CBA settings and the settings cycle table.

The in-engine cycle test at addons/main/test_settings.sqf names the settings it
cycles, so it can only ever see the settings it names. A setting added later
would run nowhere and fail nowhere. This gate closes that hole. It parses the
`CBA_fnc_addSetting` registrations out of every `addons/*/initSettings.inc.sqf`
and the machine-read cycle table out of `addons/main/test_settings.sqf`, then
asserts the two agree. It needs no game and no SQF interpreter.

The assertions:

1. BIJECTION. The set of registered setting names equals the set of names in
   the cycle table, in both directions. A registration with no row fails the
   gate, and a row naming an unregistered setting fails it too.
2. PER SETTING. The name matches `^A3ACC_[A-Za-z0-9]+$`, the type is `CHECKBOX`
   or `LIST`, the category is exactly `"A3 Accessibility"`, every `FUNC(...)`
   the callback calls resolves to `addons/<owning addon>/functions/fnc_<name>.sqf`
   with a `PREP(<name>)` line in that addon's `XEH_PREP.hpp`, `_isGlobal` is 0
   and `_needRestart` is false.
3. VALUES. A CHECKBOX admits exactly the two booleans. A LIST admits exactly the
   value list it declares, and the table row's default sits inside the admitted
   values.
4. NO SETTING CAN VANISH AT LOAD. No setting is registered in an addon whose
   `config.cpp` declares `skipWhenMissingDependencies = 1` or requires a DLC
   addon, because such a setting would not exist on the tier the cycle test runs
   on. The DLC addon names are read from the skip-scoped addons themselves, so
   the gate holds no second copy of them.
5. NO VACUOUS ASSERTION. Every row declares either an observable getter, taken
   from the curated list below and named by one of the setting's own callback
   functions, or an unobservable reason. A row with neither fails, and a row
   that claims an observable effect the setting's own code never reads fails.
6. NO GLOBAL SHADOWS A SETTING. No SQF global in any addon shares a name with a
   registered setting, case insensitively. CBA stores a setting's value in the
   missionNamespace under the setting name, and SQF global identifiers are not
   case sensitive, so a global that differs from a setting only in case is the
   SAME variable. The setting then holds whatever the addon writes, and the
   addon reads a value the setting owns. The defect this closes: the hearing
   addon kept its cue list in `A3ACC_soundCues`, one letter of case away from
   the `A3ACC_SoundCues` setting, so the list held a Bool and the `select` in
   `fnc_soundCue.sqf` failed on every shot.

   The gate parses both sides from source. The setting names come from the
   `CBA_fnc_addSetting` registrations. The globals come from a scan of every
   `.sqf` file under `addons/`. The scan skips strings and comments, then takes
   every identifier that does not begin with an underscore. SQF requires a local
   variable to begin with an underscore, so a bare identifier is a global, and
   the underscore prefix is what separates a global from a local. A name that
   appears only inside a string, such as the setting name in a `getVariable`
   call or a config class name, is not a global and is not reported.

Exit code 0 means all assertions pass.
"""

from __future__ import annotations

import re
import sys
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ADDONS = ROOT / "addons"
CYCLE_TEST = ADDONS / "main" / "test_settings.sqf"

TABLE_BEGIN = "A3ACC_SETTINGS_CYCLE_TABLE_BEGIN"
TABLE_END = "A3ACC_SETTINGS_CYCLE_TABLE_END"

NAME_RE = re.compile(r"^A3ACC_[A-Za-z0-9]+$")
FUNC_RE = re.compile(r"FUNC\(([A-Za-z0-9_]+)\)")
ADD_SETTING_RE = re.compile(r"CBA_fnc_addSetting")
SKIP_RE = re.compile(r"skipWhenMissingDependencies\s*=\s*1\b")
REQUIRED_RE = re.compile(r"requiredAddons\[\]\s*=\s*\{([^}]*)\}")
QUOTED_RE = re.compile(r'"([^"]+)"')

CATEGORY = "A3 Accessibility"
TYPES = ("CHECKBOX", "LIST")

# The curated getters a cycle-table row may name as its server-observable
# effect. Each one is a command or a variable the dedicated-server tier reads
# back. The gate also checks that one of the setting's own callback functions
# names the getter, so a row cannot claim an effect the setting's code never
# observes. The four settings whose callbacks read none of these are the four
# with no server-observable effect, and their rows must say so.
GETTERS = (
    "shownHUD",
    "groupIconsVisible",
    "sentencesEnabled",
    "shownSubtitles",
    "markerSize",
    "markerAlpha",
    "A3ACC_palette",
)


@dataclass(frozen=True)
class Registration:
    """One `CBA_fnc_addSetting` call, parsed from an initSettings file."""

    name: str
    kind: str
    category: str
    admitted: tuple[str, ...]
    default: str
    is_global: str
    need_restart: str
    callback: str
    functions: tuple[str, ...]
    addon: str
    source: Path


@dataclass(frozen=True)
class Row:
    """One row of the machine-read cycle table."""

    name: str
    kind: str
    values: tuple[str, ...]
    default: str
    observable: bool | None
    detail: str


def split_top_level(text: str) -> list[str]:
    """Split on commas at bracket depth 0, treating a string as one token."""
    parts: list[str] = []
    depth = 0
    in_string = False
    escaped = False
    current: list[str] = []
    for char in text:
        if in_string:
            current.append(char)
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False
            continue
        if char == '"':
            in_string = True
            current.append(char)
        elif char in "([{":
            depth += 1
            current.append(char)
        elif char in ")]}":
            depth -= 1
            current.append(char)
        elif char == "," and depth == 0:
            parts.append("".join(current).strip())
            current = []
        else:
            current.append(char)
    tail = "".join(current).strip()
    if tail:
        parts.append(tail)
    return parts


def registration_blocks(text: str) -> list[str]:
    """Return the `[ ... ]` argument of every `CBA_fnc_addSetting` call."""
    blocks: list[str] = []
    for match in ADD_SETTING_RE.finditer(text):
        close = text.rfind("]", 0, match.start())
        if close == -1:
            continue
        depth = 0
        index = close
        while index >= 0:
            char = text[index]
            if char == "]":
                depth += 1
            elif char == "[":
                depth -= 1
                if depth == 0:
                    break
            index -= 1
        if index >= 0:
            blocks.append(text[index : close + 1])
    return blocks


def unquote(token: str) -> str:
    """Strip one pair of surrounding double quotes."""
    token = token.strip()
    if len(token) >= 2 and token[0] == '"' and token[-1] == '"':
        return token[1:-1]
    return token


def parse_registrations(path: Path) -> list[Registration]:
    """Parse every registration out of one initSettings file."""
    text = path.read_text(encoding="utf-8")
    addon = path.parent.name
    registrations: list[Registration] = []
    for block in registration_blocks(text):
        fields = split_top_level(block.strip()[1:-1])
        if len(fields) != 8:
            raise SystemExit(
                f"FAIL: {path.name} has a CBA_fnc_addSetting call with "
                f"{len(fields)} fields, expected 8"
            )
        name = unquote(fields[0])
        kind = unquote(fields[1])
        category = unquote(fields[3])
        if kind == "LIST":
            parts = split_top_level(fields[4].strip()[1:-1])
            admitted = tuple(split_top_level(parts[0].strip()[1:-1]))
            default = parts[2].strip()
        else:
            admitted = ("false", "true")
            default = fields[4].strip()
        callback = fields[6].strip()
        registrations.append(
            Registration(
                name=name,
                kind=kind,
                category=category,
                admitted=admitted,
                default=default,
                is_global=fields[5].strip(),
                need_restart=fields[7].strip(),
                callback=callback,
                functions=tuple(FUNC_RE.findall(callback)),
                addon=addon,
                source=path,
            )
        )
    return registrations


def parse_table(text: str) -> list[Row]:
    """Parse the machine-read cycle table out of the cycle test."""
    if TABLE_BEGIN not in text or TABLE_END not in text:
        raise SystemExit(
            f"FAIL: {CYCLE_TEST.name} has no {TABLE_BEGIN}..{TABLE_END} block"
        )
    block = text.split(TABLE_BEGIN, 1)[1].split(TABLE_END, 1)[0]
    rows: list[Row] = []
    for raw in block.splitlines():
        line = raw.strip()
        if not line.startswith("//"):
            continue
        line = line[2:].strip()
        if not line:
            continue
        fields = [field.strip() for field in line.split("|")]
        if len(fields) != 5:
            raise SystemExit(
                f"FAIL: {CYCLE_TEST.name} row {line!r} has {len(fields)} fields, "
                "expected 5"
            )
        name, kind, values, default, classification = fields
        if classification.startswith("observable="):
            observable: bool | None = True
            detail = classification[len("observable=") :].strip()
        elif classification.startswith("unobservable="):
            observable = False
            detail = classification[len("unobservable=") :].strip()
        else:
            observable = None
            detail = classification
        rows.append(
            Row(
                name=name,
                kind=kind,
                values=tuple(part.strip() for part in values.split(",")),
                default=default,
                observable=observable,
                detail=detail,
            )
        )
    if not rows:
        raise SystemExit(f"FAIL: the cycle table in {CYCLE_TEST.name} holds no rows")
    return rows


def config_facts(addon_dir: Path) -> tuple[bool, tuple[str, ...]]:
    """Return (skipWhenMissingDependencies, requiredAddons) for one addon."""
    config = addon_dir / "config.cpp"
    if not config.exists():
        return False, ()
    text = config.read_text(encoding="utf-8")
    skip = bool(SKIP_RE.search(text))
    match = REQUIRED_RE.search(text)
    required = tuple(QUOTED_RE.findall(match.group(1))) if match else ()
    return skip, required


def callback_reads(reg: Registration, token: str) -> bool:
    """True when one of the setting's callback functions names the token."""
    pattern = re.compile(rf"\b{re.escape(token)}\b")
    for fn in reg.functions:
        path = ADDONS / reg.addon / "functions" / f"fnc_{fn}.sqf"
        if path.exists() and pattern.search(path.read_text(encoding="utf-8")):
            return True
    return False


def globals_in_sqf(text: str) -> dict[str, list[int]]:
    """Map every SQF global in one file to the lines it appears on.

    The scan walks the text once. It skips a double-quoted string, a `//` line
    comment and a `/* */` block comment, so a name that appears only in a string
    or a comment is not reported. It then takes every identifier. SQF requires a
    local variable to begin with an underscore, so an identifier without that
    prefix is a global, and the prefix is the only thing that separates the two.
    """
    found: dict[str, list[int]] = {}
    line = 1
    index = 0
    length = len(text)
    while index < length:
        char = text[index]
        if char == "\n":
            line += 1
            index += 1
        elif char == '"':
            index += 1
            while index < length and text[index] != '"':
                if text[index] == "\\":
                    index += 1
                elif text[index] == "\n":
                    line += 1
                index += 1
            index += 1
        elif text.startswith("//", index):
            while index < length and text[index] != "\n":
                index += 1
        elif text.startswith("/*", index):
            index += 2
            while index < length and not text.startswith("*/", index):
                if text[index] == "\n":
                    line += 1
                index += 1
            index += 2
        elif char.isalpha() or char == "_":
            start = index
            while index < length and (text[index].isalnum() or text[index] == "_"):
                index += 1
            token = text[start:index]
            if not token.startswith("_"):
                found.setdefault(token, []).append(line)
        else:
            index += 1
    return found


def addon_globals() -> dict[str, list[str]]:
    """Map every SQF global in the addons to the `path:line` places it appears."""
    by_name: dict[str, list[str]] = {}
    for path in sorted(ADDONS.rglob("*.sqf")):
        relative = path.relative_to(ROOT)
        for name, lines in globals_in_sqf(path.read_text(encoding="utf-8")).items():
            by_name.setdefault(name, []).extend(f"{relative}:{line}" for line in lines)
    return by_name


def main() -> int:
    failures: list[str] = []

    registrations: list[Registration] = []
    for path in sorted(ADDONS.glob("*/initSettings.inc.sqf")):
        registrations.extend(parse_registrations(path))
    reg_by_name = {reg.name: reg for reg in registrations}

    rows = parse_table(CYCLE_TEST.read_text(encoding="utf-8"))
    row_by_name = {row.name: row for row in rows}

    # The DLC addon names, read from the addons that are themselves
    # skip-scoped. The gate holds no second copy of them.
    addon_dirs = sorted(d for d in ADDONS.iterdir() if d.is_dir())
    own = {f"A3ACC_{d.name}" for d in addon_dirs}
    dlc_addons: set[str] = set()
    for addon_dir in addon_dirs:
        skip, required = config_facts(addon_dir)
        if skip:
            dlc_addons |= set(required) - own

    owning = {reg.addon for reg in registrations}
    no_setting = [d.name for d in addon_dirs if d.name not in owning]

    # Assertion 1: the bijection, in both directions.
    bijection_ok = True
    for name in sorted(set(reg_by_name) - set(row_by_name)):
        bijection_ok = False
        failures.append(
            f"setting {name} is registered but has no row in {CYCLE_TEST.name}, "
            "so the cycle test never runs it"
        )
    for name in sorted(set(row_by_name) - set(reg_by_name)):
        bijection_ok = False
        failures.append(
            f"{CYCLE_TEST.name} has a row for {name}, which no initSettings "
            "file registers"
        )

    # Assertion 2 and 3: the shape of every registration.
    for reg in registrations:
        where = f"{reg.source.name}:{reg.name}"
        if not NAME_RE.match(reg.name):
            failures.append(f"{where}: the name does not match {NAME_RE.pattern}")
        if reg.kind not in TYPES:
            failures.append(f"{where}: type {reg.kind!r} is not one of {TYPES}")
        if reg.category != CATEGORY:
            failures.append(
                f"{where}: category is {reg.category!r}, expected {CATEGORY!r}"
            )
        if reg.is_global != "0":
            failures.append(
                f"{where}: _isGlobal is {reg.is_global!r}, expected 0, because "
                "the settings are client-local"
            )
        if reg.need_restart != "false":
            failures.append(
                f"{where}: _needRestart is {reg.need_restart!r}, expected false"
            )
        if "[_this] call FUNC(" not in reg.callback:
            failures.append(f"{where}: the callback does not call a FUNC with [_this]")
        if not reg.functions:
            failures.append(f"{where}: the callback names no FUNC")
        prep = ADDONS / reg.addon / "XEH_PREP.hpp"
        prep_text = prep.read_text(encoding="utf-8") if prep.exists() else ""
        for fn in reg.functions:
            path = ADDONS / reg.addon / "functions" / f"fnc_{fn}.sqf"
            if not path.exists():
                failures.append(
                    f"{where}: the callback calls FUNC({fn}) but "
                    f"{reg.addon}/functions/fnc_{fn}.sqf does not exist"
                )
            if not re.search(rf"\bPREP\({re.escape(fn)}\)", prep_text):
                failures.append(
                    f"{where}: the callback calls FUNC({fn}) but "
                    f"{reg.addon}/XEH_PREP.hpp has no PREP({fn}) line"
                )
        if reg.default not in reg.admitted:
            failures.append(
                f"{where}: the default {reg.default!r} is outside the admitted "
                f"values {reg.admitted}"
            )
        if reg.kind == "CHECKBOX" and reg.default not in ("false", "true"):
            failures.append(
                f"{where}: a CHECKBOX default {reg.default!r} is not a boolean"
            )

    # Assertion 4: no setting can vanish at load.
    for reg in registrations:
        skip, required = config_facts(ADDONS / reg.addon)
        if skip:
            failures.append(
                f"{reg.source.name}:{reg.name}: the addon declares "
                "skipWhenMissingDependencies = 1, so the setting does not exist "
                "on every server the cycle test runs on"
            )
        dlc = sorted(set(required) & dlc_addons)
        if dlc:
            failures.append(
                f"{reg.source.name}:{reg.name}: the addon requires the DLC "
                f"addon(s) {dlc}, so the setting does not exist on every server "
                "the cycle test runs on"
            )

    # Assertion 5: the table agrees with the source, and no row is vacuous.
    for row in rows:
        reg = reg_by_name.get(row.name)
        if reg is None:
            continue
        where = f"{CYCLE_TEST.name}:{row.name}"
        if row.kind != reg.kind:
            failures.append(
                f"{where}: the row type is {row.kind!r} but the registration "
                f"type is {reg.kind!r}"
            )
        if row.values != reg.admitted:
            failures.append(
                f"{where}: the row admits {row.values} but the registration "
                f"admits {reg.admitted}"
            )
        if row.default != reg.default:
            failures.append(
                f"{where}: the row default is {row.default!r} but the "
                f"registration default is {reg.default!r}"
            )
        if row.default not in row.values:
            failures.append(
                f"{where}: the default {row.default!r} is outside the admitted "
                f"values {row.values}"
            )
        if row.observable is None:
            failures.append(
                f"{where}: the row declares neither observable=<getter> nor "
                "unobservable=<reason>, so its assertion is vacuous"
            )
        elif row.observable:
            if row.detail not in GETTERS:
                failures.append(
                    f"{where}: observable getter {row.detail!r} is not in the "
                    f"curated list {GETTERS}"
                )
            elif not callback_reads(reg, row.detail):
                failures.append(
                    f"{where}: the row claims observable={row.detail}, but no "
                    "callback function of the setting reads it, so the claim is "
                    "vacuous"
                )
        elif not row.detail:
            failures.append(
                f"{where}: the unobservable reason is empty, so it says nothing"
            )

    # Assertion 6: no addon global shadows a registered setting. Both sides are
    # read from source: the settings from the registrations, the globals from a
    # scan of every `.sqf` file. SQF is not case sensitive for global
    # identifiers, so the compare folds case.
    globals_by_name = addon_globals()
    reg_by_lower = {name.lower(): name for name in reg_by_name}
    collisions: list[str] = []
    for name, places in sorted(globals_by_name.items()):
        setting = reg_by_lower.get(name.lower())
        if setting is None:
            continue
        for place in places:
            collisions.append(
                f"{place}: the global {name} shares a name with the registered "
                f"setting {setting}, case insensitively, so the two are the same "
                "SQF variable and one overwrites the other"
            )
    failures.extend(collisions)

    print(f"Registered settings: {len(registrations)}")
    print(f"Owning addons: {len(owning)}")
    print(f"No-setting addons: {len(no_setting)} ({', '.join(no_setting)})")
    print(f"Cycle-table rows: {len(rows)}")
    print(f"Bijection: {'ok' if bijection_ok else 'FAIL'}")
    own_globals = sorted(g for g in globals_by_name if g.lower().startswith("a3acc_"))
    print(
        f"Addon globals: {len(globals_by_name)} distinct, {len(own_globals)} in the "
        f"A3ACC_ namespace ({', '.join(own_globals)})"
    )
    print(f"Global/setting collisions: {len(collisions)}")

    print("\nAdmitted values per setting:")
    for reg in sorted(registrations, key=lambda r: r.name):
        admitted = ",".join(reg.admitted)
        print(f"  {reg.name:24s} {reg.kind:8s} {admitted:12s} default {reg.default}")

    print("\nCycle-table classification per row:")
    for row in rows:
        if row.observable:
            mark = f"observable={row.detail}"
        elif row.observable is False:
            mark = f"unobservable={row.detail}"
        else:
            mark = f"UNCLASSIFIED={row.detail}"
        print(f"  {row.name:24s} {mark}")

    if failures:
        print("\nFAILURES:")
        for failure in failures:
            print(f"  - {failure}")
        return 1

    observable_rows = sum(1 for row in rows if row.observable)
    print(
        f"\n[verify_settings] PASS: {len(registrations)} settings across "
        f"{len(owning)} addons bijective with {len(rows)} cycle-table rows, "
        f"every registration well-formed and PREP-backed, every default inside "
        f"its admitted values, no setting on a DLC-scoped addon, "
        f"{observable_rows} rows observable and {len(rows) - observable_rows} "
        "rows carrying an unobservable reason, and no addon global shares a name "
        f"with a setting ({len(globals_by_name)} globals scanned)"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
