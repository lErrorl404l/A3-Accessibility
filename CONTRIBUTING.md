# Contributing to A3 Accessibility

Thank you for your interest. This page states how to build the mod, which
gates to run, and how to write a commit message.

## Before you start

Install HEMTT (the Arma 3 build tool). Install Python 3.10 or later. You do
not need an Arma 3 install to run the gates.

Clone the repository and install the git hooks:

```bash
git clone https://github.com/lErrorl404l/A3-Accessibility.git
cd A3-Accessibility
git config core.hooksPath .githooks
```

The hooks run the fast gates before every commit.

## Build

```bash
hemtt build     # build the addon to .hemttout/build
hemtt dev       # build a development copy with file patching
hemtt launch    # build and start Arma 3 with the default profile
```

## Gates

Run these three commands before you push. CI runs the same commands.

```bash
hemtt check -p -e                 # lint the config and the SQF
python3 tests/verify_palette.py   # offline palette test
hemtt build                       # confirm the build succeeds
```

- `hemtt check -p -e` must exit 0 with no error and no warning.
- `python3 tests/verify_palette.py` must exit 0. It checks the pure palette
  function and needs no game.
- `hemtt build` must exit 0.

The in-engine test is manual. Run
`execVM "z\a3acc\addons\colourblind\test.sqf"` from the debug console and
read the RPT file.

## Commit messages

Use the form `<component>: <imperative summary>`. Keep the subject under 50
characters. Write the body only when the reason is not clear.

```
colourblind: apply the mode to map markers
ci: gate lint, the offline palette test and build
docs: add the colour-blind QA checklist
```

- Use the imperative mood. Write "add", not "added".
- Name the component: `colourblind`, `ci`, `docs` or `tests`.
- Sign every commit with GPG.
- Cite the plan section or the standard the change satisfies in the body.

## Code rules

- Put one function in each file in `addons/<component>/functions/`.
- Register each function in `XEH_PREP.hpp`.
- Keep the pure functions pure. They must read only their arguments.
- Write in British English and in ASD-STE100 controlled English.
- Use ASCII only.

## Licence

The mod is released under the GNU General Public License, version 2 or
later. See `LICENSE`.
