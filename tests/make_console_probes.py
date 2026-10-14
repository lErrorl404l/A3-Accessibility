#!/usr/bin/env python3
"""Derive the paste-ready console copies of the client probes.

The Arma 3 debug console does not accept comments, so each probe ships in two
forms. The source, `tests/probes/probe_<name>.sqf`, is the readable artefact and
carries the comments. The console copy, `tests/probes/probe_<name>.console.sqf`,
carries no comments and no blank lines, and is the file an operator pastes.

This generator derives each console copy from its source, so a later edit to a
source cannot leave a stale copy behind. The source is never changed.

The strip removes WHOLE-LINE comments and blank lines only. A trailing comment,
a `//` after code on the same line, is refused, because stripping one safely is a
parser job and a naive strip could cut a `//` inside a string. Move a trailing
comment onto its own line in the source. A block comment is refused for the same
reason.

Every assertion runs before a file is written. A failed assertion writes nothing
and exits non-zero:

1. DERIVABLE. The source holds no trailing comment and no block comment.
2. LINE COUNT. The derived copy holds exactly the code lines of the source, so
   the strip dropped nothing and added nothing.
3. OUTPUT LINES. The derived copy carries every machine-read output line of its
   source, with the same count: the `[A3ACC-PROBE]` lines, the `LOOK` lines and
   the state names.
4. NO COMMENT. The derived copy holds no comment token outside a string.
5. PARSE. The derived copy parses under the SQF parser this repository uses.

The generator is idempotent. It derives the console copy from the source alone,
so a second run leaves the file byte-identical.

    python3 tests/make_console_probes.py
"""

from __future__ import annotations

import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PROBES = ROOT / "tests" / "probes"

# Source -> console copy. The source is the input and the readable artefact. The
# console copy is the paste-ready output.
PAIRS = (
    ("probe_frame_params.sqf", "probe_frame_params.console.sqf"),
    ("probe_double_transform.sqf", "probe_double_transform.console.sqf"),
)

# The machine-read output of each probe. Each marker must survive the strip with
# the same count, so a dropped or rewritten output line fails the build.
OUTPUT_MARKERS = {
    "probe_frame_params.sqf": (
        "[A3ACC-PROBE]",
        '"mode %1"',
        "alpha 1 (the wiki table's reading)",
        "alpha 0 (the shipped template's reading)",
        "seven elements (radial ellipse)",
    ),
    "probe_double_transform.sqf": (
        "[A3ACC-PROBE]",
        "LOOK",
        "A rule off, frame off",
        "B rule off, frame on",
        "C rule on,  frame off",
        "D rule on,  frame on",
    ),
}

# The SQF parser. The bare name is tried first, then the path this machine holds.
SQFVM_PATH = Path("/home/matt/.local/bin/sqfvm")


def comment_index(line: str) -> int:
    """Return the index of the first comment token outside a string, or -1.

    A comment token is `//` or `/*`. SQF doubles a quote to escape it inside a
    string, so the scanner consumes a doubled pair and stays inside the string.
    """
    in_string = False
    index = 0
    length = len(line)
    while index < length:
        char = line[index]
        if char == '"':
            if in_string and index + 1 < length and line[index + 1] == '"':
                index += 2
                continue
            in_string = not in_string
            index += 1
            continue
        if not in_string and char == "/" and index + 1 < length:
            if line[index + 1] in ("/", "*"):
                return index
        index += 1
    return -1


def code_lines(text: str) -> list[str]:
    """Return the source lines that are code, in order.

    A whole-line comment and a blank line are dropped. A line that carries code
    before its comment is returned as it stands, so a caller can detect it.
    """
    return [
        line for line in text.splitlines() if line.strip() and comment_index(line) < 0
    ]


def derive(text: str) -> str:
    """Return the console copy: the code lines, joined with one trailing newline."""
    return "\n".join(code_lines(text)) + "\n"


def source_problems(text: str) -> list[str]:
    """Return the reasons a source cannot be stripped by the whole-line rule."""
    problems: list[str] = []
    for number, line in enumerate(text.splitlines(), start=1):
        index = comment_index(line)
        if index < 0:
            continue
        token = line[index : index + 2]
        before = line[:index]
        if before.strip():
            problems.append(
                f"line {number} carries a TRAILING comment ({token}): "
                f"{line.strip()!r}. Move it onto its own line."
            )
        elif token == "/*":
            problems.append(
                f"line {number} opens a BLOCK comment, which the whole-line rule "
                f"cannot strip: {line.strip()!r}"
            )
    return problems


def marker_counts(text: str, markers: tuple[str, ...]) -> dict[str, int]:
    """Return the count of each marker in the text."""
    return {marker: text.count(marker) for marker in markers}


def derived_problems(
    source_text: str,
    derived_text: str,
    markers: tuple[str, ...],
) -> list[str]:
    """Return the reasons the derived copy differs from what the source implies."""
    problems: list[str] = []

    expected_lines = code_lines(source_text)
    if expected_lines != derived_text.splitlines():
        problems.append(
            f"the derived copy holds {len(derived_text.splitlines())} lines, "
            f"but the source has {len(expected_lines)} code lines"
        )

    # The markers are counted in the source's CODE lines, because a source
    # comment may name a marker, and that occurrence does not reach the console
    # copy.
    source_markers = marker_counts("\n".join(expected_lines), markers)
    derived_markers = marker_counts(derived_text, markers)
    for marker in markers:
        if derived_markers[marker] != source_markers[marker]:
            problems.append(
                f"output marker {marker!r} appears {derived_markers[marker]} times "
                f"in the derived copy and {source_markers[marker]} times in the source"
            )

    for number, line in enumerate(derived_text.splitlines(), start=1):
        if comment_index(line) >= 0:
            problems.append(
                f"line {number} of the derived copy holds a comment token: "
                f"{line.strip()!r}"
            )

    if not derived_text.strip():
        problems.append("the derived copy is empty")

    return problems


def find_sqfvm() -> str | None:
    """Return the SQF parser path, or None when it is absent."""
    found = shutil.which("sqfvm")
    if found:
        return found
    if SQFVM_PATH.is_file():
        return str(SQFVM_PATH)
    return None


def parses(parser: str, text: str, console: Path) -> tuple[bool, str]:
    """Return whether the text parses, and the parser output.

    The parser reads a path, so the text goes to a temporary file beside the
    console copy. The temporary file is removed before the console copy is
    written, so a failed assertion leaves no partial output.
    """
    temporary = console.with_name(console.name + ".tmp")
    temporary.write_text(text, encoding="utf-8")
    try:
        result = subprocess.run(
            [parser, "--input-sqf", str(temporary), "--parse-only", "--no-work-print"],
            capture_output=True,
            text=True,
            stdin=subprocess.DEVNULL,
            check=False,
        )
    finally:
        temporary.unlink(missing_ok=True)
    output = (result.stdout + result.stderr).strip()
    return result.returncode == 0 and "[ERR]" not in output, output


def main() -> int:
    parser = find_sqfvm()
    if parser is None:
        print("FAIL: the SQF parser sqfvm was not found.")
        print(f"Install it, or place it at {SQFVM_PATH}.")
        print("The derived copies cannot be checked without it, so nothing is written.")
        return 1

    failures = 0
    for source_name, console_name in PAIRS:
        source = PROBES / source_name
        console = PROBES / console_name
        print(f"{source_name} -> {console_name}")

        if not source.is_file():
            print(f"  FAIL: {source.relative_to(ROOT)} is missing")
            failures += 1
            continue

        source_text = source.read_text(encoding="utf-8")

        problems = source_problems(source_text)
        if problems:
            print(f"  FAIL: {source_name} is not derivable by the whole-line rule:")
            for problem in problems:
                print(f"    {problem}")
            failures += 1
            continue

        derived_text = derive(source_text)
        markers = OUTPUT_MARKERS[source_name]

        problems = derived_problems(source_text, derived_text, markers)
        if problems:
            print("  FAIL: the derived copy is wrong:")
            for problem in problems:
                print(f"    {problem}")
            failures += 1
            continue

        parsed, output = parses(parser, derived_text, console)
        if not parsed:
            print(f"  FAIL: the derived copy does not parse under {parser}:")
            for line in output.splitlines():
                print(f"    {line}")
            failures += 1
            continue

        derived_markers = marker_counts(derived_text, markers)
        shown = ", ".join(f"{marker}={derived_markers[marker]}" for marker in markers)
        print(f"  lines: {len(derived_text.splitlines())} code lines, no blank line")
        print(f"  output markers: {shown}")
        print("  comments: 0 in the derived copy")
        print(f"  parse: {parser} exit 0")

        if console.is_file() and console.read_text(encoding="utf-8") == derived_text:
            print(f"  unchanged: {console.relative_to(ROOT)}")
        else:
            console.write_text(derived_text, encoding="utf-8")
            print(f"  wrote: {console.relative_to(ROOT)}")

    if failures:
        print(
            f"\nFAIL: {failures} probe(s) could not be derived. "
            "A failing pair writes no console copy."
        )
        return 1

    print("\nOK: every console copy derives from its source and parses.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
