# Client probe evidence

This directory holds the evidence a client probe run produces. It is part of the
repository, so a later run cannot destroy it.

## Where a run writes

The runner `tests/run_client_probe.sh` copies every report the run produced into:

```
docs/evidence/client-probe/<stamp>/
```

## The naming rule

- `<stamp>` is the UTC time the run ended, written as `YYYYMMDDTHHMMSSZ`, for
  example `20261014T164102Z`.
- Each report keeps the file name the engine gave it, for example
  `arma3_x64_2026-10-14_16-24-56.rpt`. That name holds the launch time, so the
  report stays identifiable on its own.
- `readings.txt` in the same directory holds the probe's `[A3ACC-PROBE]` lines
  from the followed report. This file is the durable artefact, because it holds
  the reading. The report around it is the context.
- `isolation.txt` in the same directory holds the outside-repo check. It lists
  each tree outside the repository and states whether the run changed it.

## Why the copy exists

The engine rotates its reports by count. A run therefore deletes the reports of
an earlier run, and a reading the plan cites can be lost before the plan is
finished. The runner makes the copy when the run ends, which is before the next
run can rotate it out.

## The recovered set

`recovered-2026-10-14/` holds the reports that were still in the Proton prefix
when the archiving was added. A person copied them, not a run, because the
archiving did not exist when they were written. The reports of the earlier runs,
including `Arma3_x64_2026-10-14_06-00-33.rpt`, were already rotated out and are
gone. `SUMMARY.txt` in that directory states the launch line and the last line of
each report.
