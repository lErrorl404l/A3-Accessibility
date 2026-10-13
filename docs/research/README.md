# Research index

What each file is for, and which ones are authoritative. Read this before
planning a change.

The numbered files are a record of what was established, and each cites its
source. Files 15 to 21 are the current evidence base: they were read from the
shipped game PBOs, so they override an earlier file where the two disagree.

## The current evidence base

These four decide what the addon can and cannot do. Re-read them before a
colour, text, label or difficulty change.

| File | What it settles |
|---|---|
| `17-dynamic-variable-layer.md` | The 44 profile variables the engine reads, which is the lever for a mode-driven colour |
| `20-colour-coverage.md` | Every colour-bearing property, whether it is dynamic, and every red and green literal with a judgement |
| `21-fonts-and-difficulty.md` | The font families, and the 24 difficulty options with the value per preset |
| `22-remaining-levers.md` | What is left: the blinking indicator lights, a check that the planned mechanisms exist, and the candidates that need a probe |
| `15-shipped-pbo-surface.md` | Where each config root lives in the shipped PBOs, and how to extract one |

`16-vanilla-surface-values.md` holds the shipped values for the surfaces the
addon converts. `tests/verify_shipped.py` checks the addon against them.

## Verification records

| File | What it records |
|---|---|
| `12-command-capability.md` | The 32 commands verified in engine, with their arity |
| `13-hearing-probe.md` | The four hearing probes and what each returned |
| `18-wiki-command-verification.md` | 37 commands checked against the wiki. The wiki does not answer when a config expression is evaluated |
| `19-mod-survey.md` | 19 accessibility and colour mods, the technique each uses, and the pitfalls they reported |

## Domain background

| File | What it covers |
|---|---|
| `01-cvd-types.md` | The four deficiency types, and why a filter is forbidden |
| `02-cba-and-tooling.md` | The CBA facilities the addon uses |
| `03-testing.md` | The three test tiers and what each can prove |
| `04-accessibility-features.md` | The feature catalogue and what is feasible in Arma 3 |
| `05-aee-prior-art.md` | The AEE override surface, and the bare-reopen rule |
| `06-arma3-colour-surface.md` | The colour surface and its moddability |
| `07-mod-quality-standards.md` | The standards CBA, ACE and ACRE follow |
| `08-example-mods.md` | Two example mods, and what to copy |
| `09-accessibility-law.md` | UK, US and EU accessibility requirements |
| `14-accessibility-what-good-looks-like.md` | The standards, the prior art, and the addon's boundary |
| `10-colour-surface-dump.md` | The vanilla colour keys, dumped in engine |
| `11-config-sweep.md` | The 3453 colour properties found by a config walk |

## Tools

`probe-client-runtime-colour.sqf` is a paste-in debug console probe. It counts
the colour properties, tests whether a control colour survives a redraw, and
tests the marker colour string form. It needs a rendering client.

## Method note

A dedicated server proves the code does not break. It cannot prove the addon
works as intended, because it has no renderer and no interface. A rendered claim
needs a human at a client. The game PBO, read with `extractpbo`, is the
authoritative source for a parent, a value or a property set.
