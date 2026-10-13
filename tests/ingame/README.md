# The in-engine test tier

Runs the addon's test suite inside a real Arma 3 dedicated server, in Docker. It
proves the code does not break anything. It does NOT prove the addon works as
intended, because a dedicated server has no renderer and no interface.

What each tier proves:

| Tier | Proves | Cannot prove |
|---|---|---|
| Offline Python gates | the config shape, the variable set, the contrast ratios, the absence of a filter | nothing about the engine |
| This tier, in engine | every command accepts its arguments, every config class resolves, the variables hold the mode values, every converted expression resolves to the mode colour, the suite restores vanilla, and that a profile expression under `CfgInGameUI/MPTable` terminates the server at startup | the rendered result, the parent chain, and whether the engine reads a config value more than once. `getArray` returns the raw expression string |
| Client RPT | the rendered result, and whether the engine re-evaluates a config expression | nothing, but it is not repeatable |

The authoritative source for a config parent, a shipped value or a shipped
property set is the game PBO, read with `extractpbo`. See
`docs/research/15-shipped-pbo-surface.md` and `tests/verify_shipped.py`.

## Run the suite

```
ARMA3_SERVER_ROOT=<arma3 server install> \
A3ACC_CBA=<a CBA_A3 folder> \
bash tests/ingame/run.sh
```

`run.sh` builds the addon, assembles the mod set, starts the server with the test
mission, captures the log and runs `verify.py` on it. It exits 0 only when the
suite passed and the log is clean. `verify.py` also fails on a cleared vanilla
base class and on a missing entry under a root this addon overrides.

Environment:

- `ARMA3_SERVER_ROOT` - a real Arma 3 dedicated server install. The Docker image
  ships no server files.
- `A3ACC_CBA` - a CBA_A3 folder. The default is `tests/ingame/mods/@cba_a3`.
- `A3ACC_PARAMS` - overrides the server mod list. Set it to
  `-autoInit -noBattlEye` to load NO addon, which is how the shipped values are
  read.

## Files

- `run.sh` - the driver.
- `verify.py` - the log gate.
- `docker-compose.yml` - the container.
- `config.toml`, `config.vanilla.toml` - the server configs.
- `configs/server.cfg` - the server settings. The mission is chosen here, in the
  `Missions` class, not in `config.toml`.
- `missions/a3acc_test.Stratis` - the suite entry. `init.sqf` waits on the
  `A3ACC_testComplete` flag, not on `scriptDone`, which is unreliable here.
- `missions/a3acc_probe.Stratis` - a probe that dumps a named class's properties
  and the colour variable values. See its header for what it cannot do.
- `mods/`, `run.log`, `server/` - generated, and gitignored.

## Why the suite waits on a flag

`scriptDone` does not become true for every test script here, even after the body
has run to its last line. A wait on it hangs the run with the `DONE` marker
missing. The suite therefore records each result as it completes, and the mission
waits on an explicit completion flag with a deadline.
