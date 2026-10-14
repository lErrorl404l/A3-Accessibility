#!/usr/bin/env python3
"""Offline gate for the transform boundary.

The mod applies one client-side `colorCorrections` post-process effect to the
whole rendered frame. It does not simulate a colour vision deficiency. A
simulation needs a post-process effect family that grades or distorts the
picture, or a colour matrix. This gate fails if such a mechanism appears in the
addon source.

The gate asserts exactly FOUR properties, and nothing else:

1. EFFECT COUNT. Exactly one `ppEffectCreate` call exists under
   `addons/colourblind/functions/`, and its effect name matches
   `colorCorrections` case insensitively.
2. PINNED PRIORITY. That call passes a named constant, and the constant is a
   `#define` in the same file, so one place owns the number.
3. DESTROY ON OFF. The mode-0 branch of `fnc_applyFrame.sqf` calls
   `ppEffectEnable false`, calls `ppEffectDestroy` and clears the handle
   variable. This is a source-shape check, so it confirms the branch exists and
   not that it ran.
4. NO SHIPPED SIMULATION MECHANISM. No `setPiPEffect`, no effect family other
   than `colorCorrections`, and no numeric array of ten or more elements
   anywhere in the addon.

The scan for `ppEffectCreate` is scoped to `functions/` and excludes
`test_*.sqf` BY NAME. `test_frame.sqf` exercises the effect path too and names
`ppEffectCreate` in a log line, so an unscoped addon-wide scan would count it
and the "exactly one" claim would be false. The restricted scan is what makes
that claim true.

BOUNDARY NOTE. The gate cannot tell a correction from a simulation by reading
the source. Both are a post-process colour transform, and the difference is what
the transform does to the picture, not what the source says. The correction
claim is therefore a documented and client-checked claim, not a machine-checked
one. This gate does not prove the boundary, and a reader who wants the boundary
proved is looking at the wrong tier.

RANGE PROVENANCE. The numeric bounds this transform tier applies to the addon's
colour arrays are SELF-IMPOSED, and they are stricter than shipped content. The
shipped RealIsBrown template carries a blend alpha of -0.5. The shipped EastWind
template carries a colorize alpha of 1.21. Both are outside the documented
nominal 0-to-1 channel range. The tier's 0-to-1 array-channel assertions, in
`tests/verify_frame.py`, and this gate's ten-element matrix rule are therefore
house rules for this addon's values. They are not a claim about the engine. The
bounds stay in force.

Exit code 0 means the four properties hold. It needs no game.
"""

from __future__ import annotations

import fnmatch
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE_DIR = ROOT / "addons"
SOURCE_GLOBS = ["*.sqf", "*.hpp", "*.cpp", "*.inc"]

COLOUR_COMPONENT = ROOT / "addons" / "colourblind"
FUNCTIONS_DIR = COLOUR_COMPONENT / "functions"
FRAME_FUNCTION = FUNCTIONS_DIR / "fnc_applyFrame.sqf"

# The effect-create scan is scoped to functions/ and skips test_*.sqf by name.
EFFECT_SCAN_GLOB = "*.sqf"
EFFECT_SCAN_EXCLUDE = "test_*.sqf"
EFFECT = "colorcorrections"

# Check A applies to every addon. It bans the global screen effect, every
# post-process effect family other than the colour-corrections transform, and
# the capital-C class name as a guard. A matrix stays banned too, because a
# matrix is the shape of a colour simulation.
CHECK_A_TOKENS = [
    "setPiPEffect",
    "ColorCorrections",
    "filmGrain",
    "chromAberration",
    "wetDistortion",
    "dynamicBlur",
    "radialBlur",
    "ColorInversion",
    "SSAO",
    "Resolution",
]

# Check B applies to the colour component only. That component remaps colours,
# so it must be provably brightness-neutral and may not touch the aperture
# commands. The flash damping items live in a future component.
CHECK_B_TOKENS = ["setAperture", "setApertureNew"]

# A colour matrix is ten or more numbers in one array, with nothing else in it.
# The body must hold only numbers, commas and whitespace, so a code block that
# happens to contain ten numbers is not a match.
ARRAY = re.compile(r"[\{\[][^\{\}\[\]]*[\}\]]")
NUMBER = re.compile(r"-?\d+(?:\.\d+)?")
NUMERIC_BODY = re.compile(r"^[\s\d.,\-+]+$")

# The create call and its named priority constant, as `tests/verify_priority.py`
# reads them.
CREATE = re.compile(
    r'ppEffectCreate\s*\[\s*"([^"]+)"\s*,\s*([A-Za-z_][A-Za-z0-9_]*|\d+)\s*\]',
    re.IGNORECASE,
)
DEFINE = re.compile(r"^\s*#define\s+([A-Za-z_][A-Za-z0-9_]*)\s+(\d+)\s*$", re.MULTILINE)

# The mode-0 branch of the frame function, and the handle it must clear.
OFF_MARKER = "if (_mode == 0) then {"
OFF_END = "} else {"
HANDLE_CLEAR = re.compile(r'setVariable\s*\[\s*"[^"]*ppHandle"\s*,\s*nil\s*\]')


def matrix_arrays(text: str) -> list[str]:
    found = []
    for match in ARRAY.finditer(text):
        body = match.group(0)[1:-1]
        if not NUMERIC_BODY.match(body):
            continue
        if len(NUMBER.findall(body)) >= 10:
            found.append(match.group(0))
    return found


def scan(paths: list[Path], tokens: list[str], check: str) -> list[str]:
    failures: list[str] = []
    for path in paths:
        text = path.read_text(encoding="utf-8", errors="replace")
        rel = path.relative_to(ROOT)
        for token in tokens:
            if token in text:
                failures.append(f"{check}: {rel} contains {token}")
        for array in matrix_arrays(text):
            failures.append(f"{check}: {rel} colour matrix {array[:60]}")
    return failures


def effect_calls() -> list[tuple[Path, str, str]]:
    """Return (file, effect, priority argument) for every create call in scope."""
    found: list[tuple[Path, str, str]] = []
    for path in sorted(FUNCTIONS_DIR.rglob(EFFECT_SCAN_GLOB)):
        if fnmatch.fnmatch(path.name, EFFECT_SCAN_EXCLUDE):
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        for effect, argument in CREATE.findall(text):
            found.append((path, effect, argument))
    return found


def off_branch(text: str) -> str | None:
    """Return the mode-0 branch body of the frame function, or None."""
    start = text.find(OFF_MARKER)
    if start < 0:
        return None
    end = text.find(OFF_END, start)
    if end < 0:
        return None
    return text[start:end]


def check_off_branch(failures: list[str]) -> None:
    text = FRAME_FUNCTION.read_text(encoding="utf-8")
    branch = off_branch(text)
    if branch is None:
        failures.append(
            f"property 3: {FRAME_FUNCTION.name} has no {OFF_MARKER!r} branch"
        )
        return
    if "ppEffectEnable false" not in branch:
        failures.append(
            f"property 3: the Off branch of {FRAME_FUNCTION.name} does not call "
            "ppEffectEnable false"
        )
    if "ppEffectDestroy" not in branch:
        failures.append(
            f"property 3: the Off branch of {FRAME_FUNCTION.name} does not call "
            "ppEffectDestroy"
        )
    if not HANDLE_CLEAR.search(branch):
        failures.append(
            f"property 3: the Off branch of {FRAME_FUNCTION.name} does not clear "
            "the handle variable"
        )


def main() -> int:
    files: list[Path] = []
    for glob in SOURCE_GLOBS:
        files.extend(sorted(SOURCE_DIR.rglob(glob)))
    colour_files = [p for p in files if COLOUR_COMPONENT in p.parents]

    failures = scan(files, CHECK_A_TOKENS, "A")
    failures += scan(colour_files, CHECK_B_TOKENS, "B")

    calls = effect_calls()
    effect = ""
    name = ""
    value: int | None = None

    if len(calls) != 1:
        failures.append(
            f"property 1: {len(calls)} ppEffectCreate calls under "
            f"{FUNCTIONS_DIR.relative_to(ROOT)} with {EFFECT_SCAN_EXCLUDE} excluded, "
            "expected exactly one"
        )
    else:
        call_file, effect, argument = calls[0]
        if effect.lower() != EFFECT:
            failures.append(
                f"property 1: the create call uses the effect {effect}, expected "
                f"{EFFECT} (case insensitive)"
            )
        if argument.isdigit():
            failures.append(
                f"property 2: the create call uses the bare literal {argument}. "
                "The priority must be a named constant, so one place owns it"
            )
        else:
            defines = dict(DEFINE.findall(call_file.read_text(encoding="utf-8")))
            if argument not in defines:
                failures.append(
                    f"property 2: {argument} is used in the create call but has no "
                    f"#define in {call_file.name}"
                )
            else:
                name = argument
                value = int(defines[argument])

    check_off_branch(failures)

    print(f"Effect: {effect or 'NONE'}")
    print(f"Priority: {name} = {value}" if value is not None else "Priority: NONE")
    print(f"Banned tokens: {len(CHECK_A_TOKENS)}")
    print(
        f"Effect scan: {FUNCTIONS_DIR.relative_to(ROOT)}/{EFFECT_SCAN_GLOB} with "
        f"{EFFECT_SCAN_EXCLUDE} excluded by name"
    )
    print(
        f"Check A over {len(files)} source files, check B over {len(colour_files)} "
        "colour files"
    )

    if failures:
        print("\nFAILURES:")
        for failure in failures:
            print(f"  - {failure}")
        return 1

    print(
        f"\n[verify_postprocess] PASS: four properties hold. One {effect} effect at "
        f"{name} = {value}, the Off branch destroys it, and no simulation mechanism "
        "ships"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
