<!-- Plan section 7.6 and docs/research/07-mod-quality-standards.md. -->

## What does this change?

<!-- One paragraph. Name the component and the reason for the change. -->

## Checklist

- [ ] `hemtt check -p -e` passes.
- [ ] `hemtt script check_prefixes` passes.
- [ ] `python3 tests/verify_palette.py` passes.
- [ ] `python3 tests/verify_no_filter.py` passes. No post-process and no colour
      matrix, and no aperture call in the colour component.
- [ ] `python3 tests/verify_surface.py` passes. Every config expression and the
      writer agree, and every reopened class restates its vanilla parent.
- [ ] `python3 tests/verify_shipped.py` passes, if a config changed. It needs the
      extracted game configs. It must report 0 properties added to a shipped
      class.
- [ ] `tests/ingame/run.sh` passes, if a function or a config changed.
- [ ] The accessibility statement in `ACCESSIBILITY.md` still holds.
- [ ] Tested in game, if the change affects what a player sees or hears. Run the
      checklist in `docs/QA-accessibility.md` and paste the result.

## Notes

A rendered or interactive result cannot be checked by any automated gate. State
plainly what you ran and what you could not.
