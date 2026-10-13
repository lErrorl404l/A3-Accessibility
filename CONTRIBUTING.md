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

Run these before you push. CI runs the same ones.

```bash
hemtt check -p -e                  # lint the config and the SQF
hemtt script check_prefixes        # confirm every addon prefix is right
python3 tests/verify_palette.py    # the pure palette, and every 3:1 pair
python3 tests/verify_no_filter.py  # no post-process and no colour matrix
python3 tests/verify_surface.py    # the expression form and the variable set
hemtt build                        # confirm the build succeeds
```

- `hemtt check -p -e` must exit 0 with no error and no warning.
- `python3 tests/verify_palette.py` must exit 0. It checks the pure palette
  function and needs no game.
- `python3 tests/verify_no_filter.py` must exit 0. It fails on a post-process
  effect or a colour matrix in any addon, and on an aperture call in the colour
  component, which must stay brightness-neutral.
- `python3 tests/verify_surface.py` must exit 0. It fails when a config
  expression and the writer disagree, and when a reopened class does not restate
  its vanilla parent.
- `hemtt build` must exit 0.

One gate needs a game install, so CI cannot run it. Run it after a config change
and after a game update:

```bash
python3 tests/verify_shipped.py    # every override against the shipped config
```

It compares every override against the extracted game configs for the parent,
the property set and the shipped value. It must report 0 properties added to a
shipped class. `docs/research/15-shipped-pbo-surface.md` says how to extract the
configs.

## The client tier

A rendered or interactive result cannot be checked from a dedicated server. After
a client run, read the RPT:

```bash
python3 tests/check_client_rpt.py            # newest RPT in the default folder
python3 tests/check_client_rpt.py <file.rpt> # or name one
```

It reports whether the addon loaded, any vanilla parent it cleared, any missing
entry under a root it overrides, any error that names it, and its own diagnostic
lines. It refuses to pass a run that never loaded the addon. Then run the
checklist in `docs/QA-accessibility.md` for the rendered result, which only a
person can judge.

## The in-engine tier

`tests/ingame/run.sh` runs the suite inside a real dedicated server in Docker. It
needs a server install and a CBA_A3 folder. It proves the code does not break
anything. It cannot prove the addon works as intended, because a dedicated
server has no renderer. See `tests/ingame/README.md`.

The debug console is the quick alternative: run
`execVM "z\a3acc\addons\colourblind\test.sqf"` and read the RPT.

## Commit messages

Use the form `<component>: <imperative summary>`. Keep the subject under 50
characters. Write the body only when the reason is not clear.

```
colourblind: apply the mode to map markers
ci: gate lint, the offline palette test and build
docs: add the colour-blind QA checklist
```

- Use the imperative mood. Write "add", not "added".
- Name the component: `main`, `colourblind`, `hearing`, `motion`, `cognitive`,
  `lowvision`, `motor`, `build`, `ci`, `docs` or `tests`.
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
