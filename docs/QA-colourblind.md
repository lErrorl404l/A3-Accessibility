# Colour-blind mode manual QA

Manual QA for the colour-blind modes. Plan section 7.5. Run the checklist
after the automated gates pass. The rendered pixel is not observable to an
automated test, so this checklist is the only check of the final colour.

Build and launch with `hemtt launch`. The default profile carries the CBA_A3
workshop id `450814997`, from `.hemtt/project.toml`.

## Steps

1. Launch with the HEMTT default profile.
2. Place one marker of each of the five classes in Eden: friendly, enemy,
   neutral, civilian and unknown.
3. Open the CBA settings menu. Confirm the five mode names and the Off
   default.
4. Select each mode in turn. Confirm the five markers change, and that no
   marker keeps its vanilla colour.
5. Select Off. Confirm every marker returns to its vanilla colour.
6. Create a new marker while a mode other than Off is active. Confirm the
   watcher recolours it within 2 seconds.
7. Run a mission that sets a marker with a raw array. Confirm the marker is
   untouched, the other markers still change, and one RPT line records the
   skip.
8. Check the RPT file for `Error` and for `Updating base class`. Both must be
   absent.
9. View each palette through a CVD simulator and confirm the gated pairs
   stay distinct.

## Result

Record the result for each step. State PASS or FAIL and attach the RPT file
and the screenshots. A second person must be able to run the list without
asking a question.

| Step | Result | Evidence |
|---|---|---|
| 1 | | |
| 2 | | |
| 3 | | |
| 4 | | |
| 5 | | |
| 6 | | |
| 7 | | |
| 8 | | |
| 9 | | |

## UNVERIFIED items

The following items are unproven. Plan section 11. Check each item before
the release that depends on it.

1. Whether Arma 3 has a native colour-blind setting. `06-arma3-colour-surface.md`
   section 4 marks it UNCONFIRMED. Check Options, Video and Game, in game.
2. The vanilla `CfgMarkerColors` class list and values.
   `06-arma3-colour-surface.md` section 6 item 4. Read the BIKI in a normal
   browser and dump the config from a game install.
3. The colour keys of `CfgInGameUI`. `06-arma3-colour-surface.md` section 1
   marks them UNVERIFIED. This slice does not override them.
4. Whether `setMarkerColorLocal` accepts an RGBA array as well as a name. The
   BIKI returned 403. This slice uses names only, so the design does not
   depend on it.
5. Whether `getMarkerColor` returns a name for a marker whose colour came
   from a raw array. Check in game. Section 6.4 of the plan assumes it may
   return a non-name, and degrades.
6. The engine class that carries objective markers.
   `06-arma3-colour-surface.md` section 1. The objective class has palette
   values but no config entry until this is known.
7. Whether `CBA_fnc_test` resolves the `z\a3acc` addon path.
   `03-testing.md` section 1 shows an `\x\<addon>\` path. Check in game. The
   debug-console `execVM` path is the fallback and is the documented floor.
8. The offline runner flags and its exit-code behaviour. `03-testing.md`
   section 6 records the question. The offline tier now uses
   `tests/verify_palette.py`, so this item is closed for this slice.
9. The CBA settings persistence store and its lifetime. `02-cba-and-tooling.md`
   section 2 names the sources but not the store. Check in game across two
   sessions.
10. Control of marker icon shape and outline weight. `01-cvd-types.md`
    section 3 makes these the carrier for the achromatopsia mode, and
    `05-aee-prior-art.md` section 3 records the marker texture aspect limit.
    This is the largest gap in the achromatopsia mode.
11. Whether `CfgMarkers` icon shape differences are addon-overridable for
    vanilla icons. `04-accessibility-features.md` marks this INFERRED.
12. Whether the engine logs `Updating base class` for a parentless reopen,
    and whether the HEMTT `L-C03` and `L-C04` lints catch the file-root
    forward-declaration trap. `05-aee-prior-art.md` section 3. Confirm with a
    deliberate bad config, then revert.
