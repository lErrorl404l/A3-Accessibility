# A3 Accessibility

Accessibility modes for Arma 3, made for players with colour vision deficiency.

The mod adds selectable colour-blind modes. Each mode remaps the map marker colours, so friendly,
enemy, neutral and unknown units stay easy to tell apart. The mod changes the colours. It does not
apply a screen filter, so the rest of the picture stays as it is.

## Features

- Five modes: Off, Protan, Deutan, Tritan and Achromatopsia.
- Remaps the colours that carry side and status meaning: the map markers and the
  map, the HUD and 3D icon side colours, the respawn table, the vehicle optic
  indicators, the task and score notifications, the interface error and warning
  text, the tactical ping, the sensor panel, the server browser, the compass and
  the Zeus editor.
- Reduces camera shake, for motion sensitivity.
- Shows a directional cue for nearby gunfire, for deaf and hard-of-hearing
  players.
- Reduces HUD clutter.
- Makes map markers larger, for low vision.
- Forces subtitles on.
- Adds an always-walk option, for reduced motor demand. It removes sprint, so
  it is off by default.
- Shows the current objective in a small panel.
- Adds an accessibility help screen to the pause menu.
- Adds a keybind for every feature, unbound by default.
- Works in the editor and in single player.
- No filter and no post-process effect.

## How to use

1. Subscribe to CBA_A3 and to this mod.
2. Enable both in the Arma 3 launcher.
3. In game, open the settings menu and find the "A3 Accessibility" category.
4. Choose the mode that suits you.

## Requirements

- Arma 3, version 2.14 or later.
- CBA_A3.

## Notes

- The mod changes the colours the game itself uses for sides and status. It does
  not draw a filter over the screen.
- If a mission sets a raw colour value on a marker, that marker keeps its value.
- The modes separate colours by brightness as well as by hue, so they stay clear
  in poor light.
- A few screens are built when the game loads, before the setting is readable.
  The addon writes the saved mode before any display is built, so a mode change
  reaches those screens at the next mission load. A screen the engine reads
  before the world exists keeps its shipped colour. See
  [ACCESSIBILITY.md](ACCESSIBILITY.md).
- The mod needs no paid DLC. Each DLC's extra colours live in their own addon,
  which the game skips when that DLC is not installed, so the rest of the mod
  still works and the absent DLC keeps its shipped colours.
- This addon is addon-scoped. It cannot change Arma 3 itself, and it cannot add a shape or a text cue
  where the game uses colour alone. See [ACCESSIBILITY.md](ACCESSIBILITY.md).

## Feedback

Report problems at the [GitHub repository](https://github.com/lErrorl404l/A3-Accessibility).

## Credits

Made by lErrorl404l.
