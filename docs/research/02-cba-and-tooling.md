# CBA_A3 facilities and the Arma 3 build toolchain

Source of record for the mod's dependency and build plumbing. Research date 2026-10-11.

## 1. CBA_A3 overview

CBA (Community Base Addons) supplies shared frameworks: Extended Event Handlers (XEH),
function/macro library, the Settings system, Keybinding system, Custom Events, UI library,
debug console. Licence GPLv2; calling CBA functions does not force this addon under GPLv2.
<https://github.com/CBATeam/CBA_A3>

Known issue: CBA keybinds and settings need a mission to be initialised; with `-world=empty`
or `-skipIntro` they work in-game only, not in the main menu.

## 2. CBA Settings (the CVD mode dropdown)

Register with `CBA_fnc_addSetting`:

```
CBA_fnc_addSetting
  _setting      <STRING>   unique name; becomes the resulting global variable
  _settingType  <STRING>   "CHECKBOX" | "EDITBOX" | "LIST" | "SLIDER" | "COLOR" | "TIME"
  _title        <STRING|ARRAY>   display name (+ optional tooltip)
  _category     <STRING|ARRAY>   category (+ optional sub-category)
  _valueInfo    <ANY>      depends on _settingType
  _isGlobal     <BOOL|NUMBER>   1 = all clients, 2 = cannot be overwritten (default 0)
  _script       <CODE>     runs at init and on every change; _this = value, _thisSetting = name
  _needRestart  <BOOL>     default false
```

LIST `_valueInfo` is `[_values, _valueTitles, _defaultIndex]` where the default is an **index**,
not a value. Example:

```
["A3ACC_CVDMode", "LIST", ["Colour blind mode", "Select a CVD palette"],
    "A3 Accessibility",
    [[0, 1, 2, 3], ["Off", "Protan", "Deutan", "Tritan"], 0]
] call CBA_fnc_addSetting;
```

Register settings in `XEH_preInit.sqf` (recommended so they appear in Eden). `addSetting`
has local effect and must run on every machine.

Reading at runtime: the setting name is the global variable
(`missionNamespace getVariable ["A3ACC_CVDMode", 0]`), or `[_setting, _source] call CBA_settings_fnc_get`
(`_source` = "client" | "mission" | "server" | "priority" | "default").

**Do not use `CBA_fnc_getSetting`.** It was not found in CBA_A3; UNVERIFIED/incorrect.

## 3. Events

Confirmed names:

| Event | Arguments | When |
|---|---|---|
| `CBA_beforeSettingsInitialized` | - | before settings init |
| `CBA_SettingsInitialized` | - | settings ready / mission start |
| `CBA_SettingChanged` | `[_setting, _value]` | any setting changes |

The name is `CBA_SettingChanged` (singular). `CBA_SettingsChanged` is **incorrect**.

```
["CBA_SettingChanged", {
    params ["_setting", "_value"];
    if (_setting isEqualTo "A3ACC_CVDMode") then { [_value] call A3ACC_fnc_colourblind_apply; };
}] call CBA_fnc_addEventHandler;
```

Cleaner for a single setting: pass the 7th argument `_script` to `CBA_fnc_addSetting`.
It runs once at init and on every change.

## 4. XEH init and component conventions

Config classes per component (run once per session):

```cpp
class Extended_PreStart_EventHandlers { class A3ACC_colourblind { init = QUOTE(call COMPILE_FILE(XEH_preStart)); }; };
class Extended_PreInit_EventHandlers  { class A3ACC_colourblind { init = QUOTE(call COMPILE_FILE(XEH_preInit));  }; };
class Extended_PostInit_EventHandlers { class A3ACC_colourblind { init = QUOTE(call COMPILE_FILE(XEH_postInit)); }; };
```

`PreInit` runs once before units/vehicles process their handlers; `PostInit` runs after.
Order follows `requiredAddons[]`.

Per-component `script_component.hpp`:

```cpp
#define COMPONENT colourblind
#include "\z\a3acc\addons\main\script_mod.hpp"
#include "\z\a3acc\addons\main\script_macros.hpp"
```

`XEH_PREP.hpp` lists `PREP(fnc)`; `CfgFunctions.hpp` registers public `PATHTO_FNC`.

## 5. Build toolchain

**Use HEMTT.** It is current, cross-platform, has linting and a launch system, and is what
CBA_A3 itself builds with. pboProject / Addon Builder are legacy; armake2 is self-declared
incomplete (no PAA, no P3D binarization).

- <https://github.com/BrettMayson/HEMTT>, <https://hemtt.dev/>
- Minimum config: `.hemtt/project.toml` with `name` and `prefix`. `prefix` drives
  `$PBOPREFIX$` (`z\{prefix}\addons\main`).
- Commands: `hemtt check`, `hemtt dev`, `hemtt build`, `hemtt release`, `hemtt launch`, `hemtt publish`.
- Local toolchain: `hemtt` installed at `/home/matt/.local/bin/hemtt`.

## 6. Project layout used here

```
A3-Accessibility/
├── .hemtt/project.toml
├── include/                      # CBA + a3 include stubs so `hemtt check` resolves \x\cba\... offline
├── addons/
│   ├── main/                     # shared macros, version, CfgMods
│   └── colourblind/              # CVD feature component (setting + colour logic)
├── docs/research/
└── mod.cpp
```

Tag: `A3ACC`. PBO prefix: `z\a3acc`. Addon class names: `A3ACC_main`, `A3ACC_colourblind`.
`requiredAddons[]` for the feature component: `A3ACC_main`, `cba_common`, `cba_events`, `cba_settings`.

## 7. Corrections applied

- `CBA_fnc_getSetting` does not exist - removed from the design.
- Event is `CBA_SettingChanged` (singular), not `CBA_SettingsChanged`.
- `PREP_RECOMPILE_START` / `PREP_RECOMPILE_END` are not defined by CBA upstream; this project
  defines them in `addons/main/script_macros.hpp` (pattern per zen-mod/ZEN), so `hemtt check` is clean.
