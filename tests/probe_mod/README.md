# The client probe mod

TEST INSTRUMENT. This is not an addon for players. It is loaded only by
`tests/run_client_probe.sh`, it lives outside `addons/`, and it must never be
published or shipped.

## Why it exists

The client is the only place a rendered result can be seen. A dedicated server
has no renderer and no interface, so no server test can prove how a mode looks.
The project rule is therefore that a rendered claim needs a client. Until now
that client step was a person's job: launch the game, paste two probes into the
debug console, read the report back. This mod removes the person from the loop.

## What it does

On mission start, on a client, the mod runs `fnc_probeRun.sqf`. That script:

- carries the machine-checkable part of `tests/probes/probe_frame_params.sqf`
  and `tests/probes/probe_double_transform.sqf`;
- logs every reading with the `[A3ACC-PROBE]` tag, so `tests/check_client_rpt.py`
  lists it;
- creates its own task with `BIS_fnc_taskCreate`, so the objective-panel check
  does not depend on the mission, and removes the task and its controls when it
  finishes;
- writes one `[A3ACC-PROBE] STEP <n> <label>` line before each hold, so the
  runner captures one screenshot per step;
- writes `[A3ACC-PROBE] VERDICT <check> <state> <detail>` for every check, where
  the state is `PASS`, `FAIL` or `UNVERIFIABLE`;
- writes `[A3ACC-PROBE] DONE` when it finishes, so the runner waits on the
  marker and not on a timer.

## The checks, and the ones that need an eye

| Check | Reading | State |
|---|---|---|
| `addon-loaded` | the addon's three functions resolve | machine |
| `probe-task` | the probe's own task is the current task | machine |
| `frame-create` | the addon's effect handle at priority 1991 | machine |
| `frame-sets` | the six-value set size for each mode | machine |
| `frame-render` | whether a mode tints or greys the frame | eye, from the images |
| `frame-alpha` | the colorize alpha and the seven-element form | eye, from the images |
| `double-transform` | each control reads back the colour it was given | machine |
| `double-transform-render` | whether the frame moves a 2D control | eye, from the images |
| `objective-panel` | the panel handler runs and the panel is cut | machine |
| `markers` | a marker recolours through the real setting chain | machine |
| `settings-sound-cues` | the cue handler is armed and then removed | machine |
| `settings-force-walk` | whether sprint is removed | eye, from the images |
| `settings-reduce-motion` | whether the screen shakes | eye, from the images |
| `zeus-display` | the Zeus side rows | UNVERIFIABLE, see below |

## What cannot be automated, and why

The Zeus display check is `UNVERIFIABLE`, and the probe logs that rather than
pretending. The Zeus display, `RscDisplayCurator`, is opened by the player
pressing Y. No scripting command opens it, and no command reads the `SideOPFOR`
or `SideIndependent` row colour, so no probe can measure it. It needs a person
at the client, or a future engine command.

The `A3ACC_ForceWalk` and `A3ACC_ReduceMotion` settings are also
`UNVERIFIABLE`: sprint and camera shake are behaviours, not readable values.

## How to run it

```
bash tests/run_client_probe.sh
```

The runner builds the addon and this mod, starts a local dedicated server with
a mission that gives a player, launches the client with CBA and this mod loaded,
follows the client report, captures one screenshot per step and prints one block
per check.

## Isolation

The runner passes `-profiles=` pointed at `tests/probe_mod/run/profiles`, a
scratch directory inside its own tree. The engine therefore writes the profile,
the `Arma3.cfg` it would otherwise rewrite in the owner's Documents, the `.rpt`
reports and the data caches under that path. The runner also gives the Steam
Linux Runtime a scratch variable directory at `tests/probe_mod/run/pv-var`, so
the runtime does not write into its own install tree.

The runner snapshots every tree outside the repository before and after the run
and prints one line per tree. A change to a tree the runner owns fails the run.
A change to the prefix report folder or to the Steam config is reported and does
not fail the run, because the engine and the Steam client own those.

## Evidence

Every report the run produced is copied to `docs/evidence/client-probe/` when the
run ends, with the probe's readings in `readings.txt` and the outside-repo check
in `isolation.txt`. See `docs/evidence/client-probe/README.md` for the path and
the naming rule. The copy exists because the engine rotates its reports by count,
so a later run deletes the evidence of an earlier one.

## Parsing note

The SQF parser `sqfvm` does not list the getter `ctrlBackgroundColor` in its
command table, so `fnc_probeRun.sqf` does not parse under it. The command is
real. `ctrlBackgroundColor` is a standalone string in `arma3_x64.exe`, and the
addon's own `fnc_recolourControls.sqf` maps it as the getter for the
`colorBackground` property. `docs/research/12-command-capability.md` records it
as UNVERIFIED at runtime, because a dedicated server builds no display and
cannot read it.
