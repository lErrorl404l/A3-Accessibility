# The 2D interface colour surface

This file records the vehicle MFD extraction for the 2D coverage work, and it
carries the 2D surface table. The table is the specification for the later
override rows: they implement exactly the rows it marks covered.
`tests/verify_2d_coverage.py` asserts the table's internal facts, so the table
and the implementation cannot drift apart.

Line numbers below are the line that declares the class, that is the
`class <name>` line. The `color[]` line follows it.

## Method

The game rapifies the shipped configs, so a class name appears as plain bytes
inside a PBO. A byte scan therefore locates a class without an extraction. A value or a
parent needs the extraction, which `extractpbo` gives.

- Install: `/ext/Development/a3pm-server`. Count: 490 PBOs.
- Tool: `/home/matt/bin/extractpbo`, version 2.35.
- Extraction command per archive:
  `/home/matt/bin/extractpbo -P <install>/<path>.pbo <dest>`.
- The extraction is not durable. The two gate directories
  `/tmp/opencode/vanilla` and `/tmp/opencode/gamepbo` hold the result.

### Sweep, and why it is complete

A byte scan of every PBO in the install finds a class name completely only when
the game stores every config without compression. The following checks validate
the scan.

- 191 of the 196 base addons hold the plain bytes `CfgPatches`, so their config
  is not compressed.
- 5 base addons do not hold those bytes:
  `map_altis_data_layers_00_00`, `map_altis_data_layers_00_01`,
  `map_altis_data_layers_01_00`, `map_altis_data_layers_01_01` and
  `uifonts_f_data`. None of the five carries a `config.bin` entry, so each is a
  data archive with no config. No class can live in them.

Every config in the install is therefore readable by a byte scan. The scan
covers all 490 PBOs.

## The six MFD side subclasses

The search key is the six subclass names this task names: `targetFriendly`,
`targetEnemy`, `targetGroundFriendly`, `targetAirEnemy`, `rwrFriendly` and
`rwrGroup`. The scan also covers `rwrEnemy`, because the classification rule
treats it as an enemy colour.

Result: one archive in the whole install holds any of them. That archive is
`addons/air_f_beta.pbo`, whose `CfgPatches` class is `A3_Air_F_Beta`.

| Archive | `CfgPatches` class | Six-name occurrences |
|---|---|---|
| `addons/air_f_beta.pbo` | `A3_Air_F_Beta` | 18 (plus 3 `rwrEnemy`) |

The archive declares three `CfgPatches` classes: `A3_Air_F_Beta`,
`A3_Air_F_Beta_Heli_Attack_01` and `A3_Air_F_Beta_Heli_Attack_02`. The
archive-level name is `A3_Air_F_Beta`.

### Every finding, with file and line

The path is relative to the extracted archive. Each occurrence sits under
`CfgVehicles/<vehicle>/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/`.
The file is `a3/air_f_beta/heli_attack_01/config.cpp` for every row.

| Vehicle class | Subclass | Line | Shipped colour |
|---|---|---|---|
| `Heli_Attack_01_base_F` | `rwrFriendly` | 6716 | `{0,1,0}` |
| `Heli_Attack_01_base_F` | `rwrEnemy` | 6721 | `{1,0,0}` |
| `Heli_Attack_01_base_F` | `rwrGroup` | 6726 | `{1,0,0}` |
| `Heli_Attack_01_base_F` | `targetFriendly` | 6756 | `{0,1,0}` |
| `Heli_Attack_01_base_F` | `targetEnemy` | 6761 | `{1,0,0}` |
| `Heli_Attack_01_base_F` | `targetGroundFriendly` | 6780 | `{0,1,0}` |
| `Heli_Attack_01_base_F` | `targetAirEnemy` | 6911 | `{1,0,0}` |
| `Heli_Attack_01_dynamicLoadout_base_F` | `rwrFriendly` | 12006 | `{0,1,0}` |
| `Heli_Attack_01_dynamicLoadout_base_F` | `rwrEnemy` | 12011 | `{1,0,0}` |
| `Heli_Attack_01_dynamicLoadout_base_F` | `rwrGroup` | 12016 | `{1,0,0}` |
| `Heli_Attack_01_dynamicLoadout_base_F` | `targetFriendly` | 12046 | `{0,1,0}` |
| `Heli_Attack_01_dynamicLoadout_base_F` | `targetEnemy` | 12051 | `{1,0,0}` |
| `Heli_Attack_01_dynamicLoadout_base_F` | `targetGroundFriendly` | 12070 | `{0,1,0}` |
| `Heli_Attack_01_dynamicLoadout_base_F` | `targetAirEnemy` | 12201 | `{1,0,0}` |
| `Heli_Attack_01_pylons_dynamicLoadout_base_F` | `rwrFriendly` | 18852 | `{0,1,0}` |
| `Heli_Attack_01_pylons_dynamicLoadout_base_F` | `rwrEnemy` | 18857 | `{1,0,0}` |
| `Heli_Attack_01_pylons_dynamicLoadout_base_F` | `rwrGroup` | 18862 | `{1,0,0}` |
| `Heli_Attack_01_pylons_dynamicLoadout_base_F` | `targetFriendly` | 18892 | `{0,1,0}` |
| `Heli_Attack_01_pylons_dynamicLoadout_base_F` | `targetEnemy` | 18897 | `{1,0,0}` |
| `Heli_Attack_01_pylons_dynamicLoadout_base_F` | `targetGroundFriendly` | 18916 | `{0,1,0}` |
| `Heli_Attack_01_pylons_dynamicLoadout_base_F` | `targetAirEnemy` | 19047 | `{1,0,0}` |

The friendly colour is `{0,1,0}`. The enemy colour is `{1,0,0}`. `rwrGroup`
reads `{1,0,0}`, so it is an enemy colour by value.

These 21 rows are the seven named subclasses only, so they are a LOWER BOUND. The
full side-named set is 32 distinct leaves on the same three classes, because the
name carries other side words too (`targetGroup`, `targetManFriendly`,
`targetNVGEnemy`, `targetLaserGroup` and the rest). The Counts section states the
full set. The classification rule is the SUBCLASS NAME only, and a value test is
never a primary classifier.

## MFD classes in the DLC archives

The six names do not appear in any DLC archive, and neither does any other
side-named MFD subclass. A side-named subclass is one whose name carries a side
word: `Friendly`, `Enemy`, `Group` or `rwr`. NO DLC archive holds one, so no DLC
MFD class carries a side colour. MFD classes do appear in DLC vehicle archives,
under other subclass names, and the colours there are MFD tint and status
colours, not side colours.

| DLC | Archive | `CfgPatches` class | Vehicle class | File | Line |
|---|---|---|---|---|---|
| Apex | `expansion/addons/air_f_exp.pbo` | `A3_Air_F_Exp` | `Plane_Civil_01_base_F` | `a3/air_f_exp/plane_civil_01/config.cpp` | 587 |
| Apex | `expansion/addons/air_f_exp.pbo` | `A3_Air_F_Exp` | `VTOL_01_base_F` | `a3/air_f_exp/vtol_01/config.cpp` | 281 |
| Apex | `expansion/addons/air_f_exp.pbo` | `A3_Air_F_Exp` | `VTOL_01_base_F` (turret) | `a3/air_f_exp/vtol_01/config.cpp` | 2202 |
| Apex | `expansion/addons/air_f_exp.pbo` | `A3_Air_F_Exp` | `VTOL_01_armed_base_F` | `a3/air_f_exp/vtol_01/config.cpp` | 3852 |
| Apex | `expansion/addons/air_f_exp.pbo` | `A3_Air_F_Exp` | `VTOL_02_base_F` | `a3/air_f_exp/vtol_02/config.cpp` | 237 |
| Apex | `expansion/addons/air_f_exp.pbo` | `A3_Air_F_Exp` | `VTOL_02_infantry_dynamicLoadout_base_F` | `a3/air_f_exp/vtol_02/config.cpp` | 2746 |
| Apex | `expansion/addons/soft_f_exp.pbo` | `A3_Soft_F_Exp` | `Offroad_02_base_F` | `a3/soft_f_exp/offroad_02/config.cpp` | 626 |
| Helicopters | `heli/addons/air_f_heli.pbo` | `A3_Air_F_Heli` | `Heli_Transport_03_base_F` | `a3/air_f_heli/heli_transport_03/config.cpp` | 178 |
| Helicopters | `heli/addons/air_f_heli.pbo` | `A3_Air_F_Heli` | `Heli_Transport_04_base_F` | `a3/air_f_heli/heli_transport_04/config.cpp` | 596 |
| Jets | `jets/addons/air_f_jets.pbo` | `A3_Air_F_Jets` | `Plane_Fighter_01_Base_F` | `a3/air_f_jets/plane_fighter_01/config.cpp` | 724 |
| Jets | `jets/addons/air_f_jets.pbo` | `A3_Air_F_Jets` | `Plane_Fighter_02_Base_F` | `a3/air_f_jets/plane_fighter_02/config.cpp` | 936 |
| Jets | `jets/addons/air_f_jets.pbo` | `A3_Air_F_Jets` | `Plane_Fighter_04_Base_F` | `a3/air_f_jets/plane_fighter_04/config.cpp` | 763 |
| Jets | `jets/addons/static_f_destroyer.pbo` | `A3_Static_F_Destroyer` | `Land_Destroyer_01_Boat_Rack_01_Base_F` | `a3/static_f_destroyer/boat_rack_01/config.cpp` | 191 |
| Laws of War | `orange/addons/air_f_orange.pbo` | `A3_Air_F_Orange` | `UAV_06_base_F` | `a3/air_f_orange/uav_06/config.cpp` | 236 |
| Tanks | `tank/addons/armor_f_tank.pbo` | `A3_Armor_F_Tank` | `AFV_Wheeled_01_base_F` | `a3/armor_f_tank/afv_wheeled_01/config.cpp` | 307 |
| Tanks | `tank/addons/armor_f_tank.pbo` | `A3_Armor_F_Tank` | `AFV_Wheeled_01_up_base_F` | `a3/armor_f_tank/afv_wheeled_01/config.cpp` | 2137 |
| Tanks | `tank/addons/armor_f_tank.pbo` | `A3_Armor_F_Tank` | `LT_01_AT_base_F` | `a3/armor_f_tank/lt_01/config.cpp` | 1063 |
| Tanks | `tank/addons/armor_f_tank.pbo` | `A3_Armor_F_Tank` | `LT_01_scout_base_F` | `a3/armor_f_tank/lt_01/config.cpp` | 1761 |
| Tanks | `tank/addons/armor_f_tank.pbo` | `A3_Armor_F_Tank` | `LT_01_AA_base_F` | `a3/armor_f_tank/lt_01/config.cpp` | 2514 |
| Tanks | `tank/addons/armor_f_tank.pbo` | `A3_Armor_F_Tank` | `LT_01_cannon_base_F` | `a3/armor_f_tank/lt_01/config.cpp` | 3209 |
| Tanks | `tank/addons/armor_f_tank.pbo` | `A3_Armor_F_Tank` | `MBT_04_base_F` | `a3/armor_f_tank/mbt_04/config.cpp` | 329 |
| Tanks | `tank/addons/armor_f_tank.pbo` | `A3_Armor_F_Tank` | `MBT_04_cannon_base_F` | `a3/armor_f_tank/mbt_04/config.cpp` | 2700 |

This file reads the DLC identity from the core config, `bin/bin/config.cpp:1455-1497`,
which lists the DLC tags `Apex`, `Jets`, `Laws of War` and `Tanks`. The `orange`
prefix is Laws of War, proven by `a3/data_f_orange/config.cpp:48`
(`nameShort = "Laws of War"`) and `:53`
(`action = "https://www.arma3.com/dlc/lawsofwar"`).

Four DLC MFD classes carry no colour at all. `a3/air_f_orange/uav_06/config.cpp:236`
and `a3/static_f_destroyer/boat_rack_01/config.cpp:191` each declare an empty
`class MFD{};`, and so do both Helicopters classes,
`a3/air_f_heli/heli_transport_03/config.cpp:178` and
`a3/air_f_heli/heli_transport_04/config.cpp:596`. This file records them as well.

The DLC MFD colours are tint and status colours. The measured values are
`{1.0,0.0,0.0}` for `StallGroup` at
`a3/air_f_exp/plane_civil_01/config.cpp:1003` and
`a3/air_f_jets/plane_fighter_01/config.cpp:2660`, `{0.15,1.0,0.15,1.0}` for
`AirplaneHUD` at `a3/air_f_exp/vtol_01/config.cpp:292`, `{0.082,0.408,0.039,1}`
for `FA18_MFD_HORIZON` at `a3/air_f_jets/plane_fighter_01/config.cpp:735`,
`{0,0.7,0}` and `{0.7,0,0}` for `Fuel_background_green` and
`Fuel_background_red` at `a3/armor_f_tank/afv_wheeled_01/config.cpp:922,942`,
`{0.15,1,0.05}` for `MFD_Commander_OnScreen/Draw` at
`a3/armor_f_tank/afv_wheeled_01/config.cpp:1016`, `{0.92,0.01,0}` for
`MFD_Driver_Fire` at `a3/armor_f_tank/mbt_04/config.cpp:380`, and
`{0.15,0.15,1.0,1.0}` and `{0.07,0.87,0.195}` for `Dashboard` and `Draw` at
`a3/soft_f_exp/offroad_02/config.cpp:637,643`. The example shades this file
recorded earlier, `{0,0.8,0}` and `{0.8,0,0}`, do not occur in the extraction.

None of these is a side colour, so no DLC MFD row is covered. The classification
rule is the SUBCLASS NAME only, over the side-named leaves (`Friendly`, `Enemy`,
`Group`, `rwr`). A value test against the five side colours is NEVER a primary
classifier and may only confirm inside the side-named set. A value test alone is
FORBIDDEN, because it cannot tell a side red from a warning red: `StallGroup`,
`Fuel_background_red` and `MFD_Driver_Fire` all ship a red, and none is a side
colour. This is the same principle the frame plan uses: the name declares and the
value confirms. Every DLC MFD row is therefore `excluded`, with the reason "the
class carries MFD tint and status colours only".

## MFD classes in the base game archives

These base archives also hold a `CfgVehicles/<vehicle>/MFD` class, none of them
with a six-name subclass. Each is a base game archive, so it needs no DLC addon.

| Archive | `CfgPatches` class | MFD classes |
|---|---|---|
| `addons/air_f.pbo` | `A3_Air_F` | 2 |
| `addons/air_f_beta.pbo` | `A3_Air_F_Beta` | 11 |
| `addons/air_f_epb.pbo` | `A3_Air_F_EPB` | 1 |
| `addons/air_f_epc.pbo` | `A3_Air_F_EPC` | 4 |
| `addons/air_f_gamma.pbo` | `A3_Air_F_Gamma` | 1 |
| `addons/armor_f_beta.pbo` | `A3_Armor_F_Beta` | 8 |
| `addons/armor_f_decade.pbo` | `A3_Armor_F_Decade` | 1 |
| `addons/armor_f_epb.pbo` | `A3_Armor_F_EPB` | 2 |
| `addons/armor_f_epc.pbo` | `A3_Armor_F_EPC` | 1 |
| `addons/armor_f_gamma.pbo` | `A3_Armor_F_Gamma` | 7 |
| `addons/boat_f_beta.pbo` | `A3_Boat_F_Beta` | 1 |
| `addons/drones_f.pbo` | `A3_Drones_F` | 1 |
| `addons/soft_f.pbo` | `A3_Soft_F` | 2 |
| `addons/soft_f_beta.pbo` | `A3_Soft_F_Beta` | 2 |
| `addons/soft_f_gamma.pbo` | `A3_Soft_F_Gamma` | 4 |
| `dta/bin.pbo` | `Core` | 4 |
| `addons/data_f.pbo` | `A3_Data_F` | 1 (an empty `class MFD`) |

The core config `dta/bin.pbo` declares four base MFD classes:
`CfgVehicles/AllVehicles/MFD` at `bin/bin/config.cpp:5352`,
`CfgVehicles/Helicopter/MFD` at `:6760`, `CfgVehicles/Plane/MFD` at `:6950`
and `CfgVehicles/ParachuteBase/MFD` at `:7265`. A reopen of a per-variant class
needs these parents declared forward, in the form
`addons/colourblind/RscSideDisplays.hpp:29-34` uses. The empty
`CfgVehicles/<vehicle>/MFD` in `data_f` sits at `a3/data_f/config.cpp:4504`.

## Counts

| Search | Archives searched | Archives with a hit |
|---|---|---|
| The six subclass names | 490 | 1 (`addons/air_f_beta.pbo`) |
| The `MFD` token | 490 | 61 |
| A `CfgVehicles` MFD class | 61 (every archive with the token) | 24 |

The 490 archives break down as 196 base addons, 3 core `dta` archives, 286 DLC
archives and 5 tool archives.

The six-name sweep is complete over all 490 archives. The MFD-class sweep is
complete over the 61 archives that carry the token. An archive without the token
cannot hold an MFD class. The 37 token archives without a `CfgVehicles` MFD
class are terrain, structure, vegetation, prop, weapon, interface, data and
language archives.

## The MFD colour counts

The extraction gives these numbers. The rule that produces each is stated with it.

- 21 MFD colour properties carry one of the seven named subclasses
  (`targetFriendly`, `targetEnemy`, `targetGroundFriendly`, `targetAirEnemy`,
  `rwrFriendly`, `rwrGroup` and `rwrEnemy`). All 21 sit in
  `addons/air_f_beta.pbo`, on the three `Heli_Attack_01` classes. The 21 are
  seven subclasses times three vehicles. **The 21 is a LOWER BOUND.** The
  side-named set is larger: a subclass name that carries `Friendly`, `Enemy`,
  `Group` or `rwr` gives 32 distinct side-named leaves on the same three classes,
  and the 21 are 21 of the 32.
- The 32 distinct side-named leaves are `rwr`, `rwrDestroyed`, `rwrFriendly`,
  `rwrEnemy`, `rwrGroup` and 27 `target*` leaves. Thirty of the 32 carry a colour.
  `rwr` and `rwrDestroyed` carry none. Each of the three vehicles holds 30
  side-named colour properties, so the side-named colour-property count is 90
  across the three `Heli_Attack_01` classes. Each vehicle's `Sensor` subtree holds
  37 colour properties in total, 30 of them side-named.
- 1390 colour properties sit inside a `CfgVehicles/<vehicle>/MFD` subtree across
  the extraction. The rule is a scoped parse: for every `CfgVehicles/<vehicle>`
  class, take its `MFD` subtree and count every property whose name contains
  `color` and is an array. The count is 1098 in the base archives and 292 in the
  DLC archives. Every colour property in an MFD subtree is named exactly `color[]`.
  This number is REPRODUCIBLE.
- **The earlier figure of 1522 is SUPERSEDED.** A scoped parse over the same
  archives does not reproduce it, so 1390 is authoritative.

`docs/research/20-colour-coverage.md` records two different MFD counts:
`:189` records 160 side-coloured MFD properties, and `:349-350` records 56
vehicle classes with 145 side colours (30 friendly, 115 enemy) against 1245
status reds. Neither count agrees with the other, and neither agrees with this
extraction. The reconciliation is not done. It needs the effective-config rule
the earlier count used, where a property defined twice takes the later value. The
value test those counts used is replaced by the name-only rule above, which does
not need the five side colours.

## The other 2D surfaces, with measured locations

These are the remaining covered and excluded surfaces. They were re-verified
against the extraction in `/tmp/opencode/vanilla` and `/tmp/opencode/gamepbo`, so
the surface table can be written without a further extraction.

| Surface | Class path | Property | Shipped value | File | Line |
|---|---|---|---|---|---|
| Optics | `RscInGameUI/RscWeaponRangeZeroing` | `CA_DistanceText.colorText` | `{1,0,0,1}` | `ui_f/a3/ui_f/config.cpp` | 7065 |
| Optics | `RscInGameUI/RscWeaponRangeZeroing` | `CA_Distance.colorText` | `{1,0.15,0.15,0.65}` | `ui_f/a3/ui_f/config.cpp` | 7075 |
| Optics | `RscInGameUI/RscOptics_VLS_01` | `CA_DistanceText.colorText` | `{1,0,0,1}` | `ui_f/a3/ui_f/config.cpp` | 13202 |
| Optics | `RscInGameUI/RscOptics_VLS_01` | `CA_Distance.colorText` | `{1,0.15,0.15,0.65}` | `ui_f/a3/ui_f/config.cpp` | 13212 |
| Map | `CfgInGameUI/IslandMap` | `colorCivilian` | reads `Map_BLUFOR_*` | `ui_f/a3/ui_f/config.cpp` | 96078 |
| Map | `CfgInGameUI/IslandMap` | `colorEnemy` | reads `Map_OPFOR_*` | `ui_f/a3/ui_f/config.cpp` | 96079 |
| Map | `CfgInGameUI/IslandMap` | `colorFriendly` | reads `Map_Independent_*` | `ui_f/a3/ui_f/config.cpp` | 96080 |
| Map | `CfgInGameUI/IslandMap` | `colorNeutral` | reads `Map_Civilian_*` | `ui_f/a3/ui_f/config.cpp` | 96081 |
| Map | `CfgInGameUI/IslandMap` | `colorUnknown` | reads `Map_Unknown_*` | `ui_f/a3/ui_f/config.cpp` | 96082 |
| Map | `CfgInGameUI/IslandMap` | `colorDetectorSync` | `{0,1,0,1}` | `bin/bin/config.cpp` | 10767 |
| Editor | `RscDisplayMissionEditor` | `colorAttrPosition` | `{0,1,0,1}` | `bin/bin/config.cpp` | 21126 |
| Editor | `RscDisplayMissionEditor` | `colorAttrDirection` | `{0,1,0,1}` | `bin/bin/config.cpp` | 21127 |
| Editor | `RscDisplayMissionEditor` | `colorAttrParent` | `{1,0,0,1}` | `bin/bin/config.cpp` | 21129 |

The `RscWeaponRangeZeroing` display class sits at `ui_f/a3/ui_f/config.cpp:7057`
and `RscOptics_VLS_01` at `:13194`. Each carries `idc = -1` on `CA_DistanceText`
and `idc = 198` on `CA_Distance`. The pair is a real miss inside the family the
addon already covers 138 classes of, and the four values are the enemy red or a
derived red.

`CfgInGameUI/IslandMap` is declared twice. The five role keys are in
`ui_f/a3/ui_f/config.cpp:96076`, and they read a DIFFERENT profile family than the
role implies: `colorFriendly` reads `Map_Independent_*`, `colorNeutral` reads
`Map_Civilian_*`, `colorCivilian` reads `Map_BLUFOR_*`, `colorEnemy` reads
`Map_OPFOR_*` and `colorUnknown` reads `Map_Unknown_*`. The base block with
`colorSync` and `colorDetectorSync` is in `bin/bin/config.cpp:10725`.

`colorDetectorSync` IS a shipped property, at `bin/bin/config.cpp:10767` inside the
base `IslandMap` block at `:10725`. The earlier claim that it is absent from the
extracted config is WRONG: a grep over `ui_f` alone misses it because the `ui_f`
block does not hold the key. It stays `excluded`, with the corrected reason that
it is a map status colour and not a side colour.

`RscDisplayMissionEditor` sits at `bin/bin/config.cpp:21122`. It declares six
`colorAttr*` properties; the three side-coloured ones are `colorAttrPosition`,
`colorAttrDirection` and `colorAttrParent`, and the other three
(`colorAttrDialog`, `colorAttrLink`, `colorAttrCounter`) carry no side meaning.

## The surface table

One row per surface. The columns are, in order: `class path | property | shipped
value | role | surface key | decision | mechanism | reason | tier`.

`role` is one of `enemy`, `friendly`, `neutral`, `unknown`, `civilian`, or `-`
for a surface that is not a side colour. `surface key` is one of `BLUFOR`,
`OPFOR`, `Independent`, `Civilian` or `Unknown`, and `-` for an excluded row.
`mechanism` is `config override` for a covered row and `-` for an excluded row.
`tier` is `server`, `headless`, `client`, or a comma-separated set.

The four surface sets and their covered row counts. The gate
`tests/verify_2d_coverage.py` counts the covered rows of each set in the table
and asserts the count equals the number recorded here.

```
COVERED-COUNT MFD 90
COVERED-COUNT Optics 4
COVERED-COUNT IslandMap 5
COVERED-COUNT MissionEditor 3
```

The MFD rows are the side-named leaves (`Friendly`, `Enemy`, `Group`, `rwr`) of
the three `Heli_Attack_01` classes, thirty leaves across three vehicles. The
name is the only primary classifier. A value test against the five side colours
confirms inside the side-named set and is forbidden on its own.

<!-- SURFACE TABLE BEGIN -->

### Covered: the vehicle MFD side colours (90)

| class path | property | shipped value | role | surface key | decision | mechanism | reason | tier |
|---|---|---|---|---|---|---|---|---|
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/rwrEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/rwrFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/rwrGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetAirEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetAirFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetAirGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetAirRemoteEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetAirRemoteFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetAirRemoteGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetGroundEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetGroundFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetGroundGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetGroundRemoteEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetGroundRemoteFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetGroundRemoteGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetLaserEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetLaserFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetLaserGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetManEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetManFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetManGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetManRemoteEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetManRemoteFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetManRemoteGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetNVGEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetNVGFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetNVGGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/rwrEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/rwrFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/rwrGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetAirEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetAirFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetAirGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetAirRemoteEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetAirRemoteFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetAirRemoteGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetGroundEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetGroundFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetGroundGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetGroundRemoteEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetGroundRemoteFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetGroundRemoteGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetLaserEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetLaserFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetLaserGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetManEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetManFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetManGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetManRemoteEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetManRemoteFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetManRemoteGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetNVGEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetNVGFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetNVGGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/rwrEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/rwrFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/rwrGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetAirEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetAirFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetAirGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetAirRemoteEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetAirRemoteFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetAirRemoteGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetGroundEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetGroundFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetGroundGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetGroundRemoteEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetGroundRemoteFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetGroundRemoteGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetLaserEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetLaserFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetLaserGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetManEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetManFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetManGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetManRemoteEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetManRemoteFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetManRemoteGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetNVGEnemy | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetNVGFriendly | color | {0,1,0} | friendly | BLUFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |
| CfgVehicles/Heli_Attack_01_pylons_dynamicLoadout_base_F/MFD/MFD_Left_Radar/Draw/RadarGround/SensorGroup/Sensor/targetNVGGroup | color | {1,0,0} | enemy | OPFOR | covered | config override | the engine draws the MFD from config, and the friendly green against the enemy red is the protan and deutan confusion pair | headless, client |


### Covered: the optics distance readouts (4)

| class path | property | shipped value | role | surface key | decision | mechanism | reason | tier |
|---|---|---|---|---|---|---|---|---|
| RscInGameUI/RscWeaponRangeZeroing/CA_DistanceText | colorText | {1,0,0,1} | enemy | OPFOR | covered | config override | a real miss inside the optics family the addon already covers, and the shipped colour is the enemy red or a derived red | headless, client |
| RscInGameUI/RscWeaponRangeZeroing/CA_Distance | colorText | {1,0.15,0.15,0.65} | enemy | OPFOR | covered | config override | a real miss inside the optics family the addon already covers, and the shipped colour is the enemy red or a derived red | headless, client |
| RscInGameUI/RscOptics_VLS_01/CA_DistanceText | colorText | {1,0,0,1} | enemy | OPFOR | covered | config override | a real miss inside the optics family the addon already covers, and the shipped colour is the enemy red or a derived red | headless, client |
| RscInGameUI/RscOptics_VLS_01/CA_Distance | colorText | {1,0.15,0.15,0.65} | enemy | OPFOR | covered | config override | a real miss inside the optics family the addon already covers, and the shipped colour is the enemy red or a derived red | headless, client |


### Covered: the map unit-icon keys (5)

| class path | property | shipped value | role | surface key | decision | mechanism | reason | tier |
|---|---|---|---|---|---|---|---|---|
| CfgInGameUI/IslandMap | colorFriendly | reads Map_Independent_* | friendly | BLUFOR | covered | config override | the map unit icons are a side-identity surface, and the shipped key reads a different variable family than the role implies | headless, client |
| CfgInGameUI/IslandMap | colorEnemy | reads Map_OPFOR_* | enemy | OPFOR | covered | config override | the map unit icons are a side-identity surface, and the shipped key reads a different variable family than the role implies | headless, client |
| CfgInGameUI/IslandMap | colorNeutral | reads Map_Civilian_* | neutral | Independent | covered | config override | the map unit icons are a side-identity surface, and the shipped key reads a different variable family than the role implies | headless, client |
| CfgInGameUI/IslandMap | colorCivilian | reads Map_BLUFOR_* | civilian | Civilian | covered | config override | the map unit icons are a side-identity surface, and the shipped key reads a different variable family than the role implies | headless, client |
| CfgInGameUI/IslandMap | colorUnknown | reads Map_Unknown_* | unknown | Unknown | covered | config override | the map unit icons are a side-identity surface, and the shipped key reads a different variable family than the role implies | headless, client |
| CfgInGameUI/IslandMap | colorDetectorSync | {0,1,0,1} | - | - | excluded | - | a map status colour, not a side colour | headless |


### Covered: the mission editor attribute colours (3)

| class path | property | shipped value | role | surface key | decision | mechanism | reason | tier |
|---|---|---|---|---|---|---|---|---|
| RscDisplayMissionEditor | colorAttrPosition | {0,1,0,1} | neutral | Independent | covered | config override | the mission editor is a 2D surface and Cfg3DEN is already covered, so leaving it is an inconsistency | headless, client |
| RscDisplayMissionEditor | colorAttrDirection | {0,1,0,1} | neutral | Independent | covered | config override | the mission editor is a 2D surface and Cfg3DEN is already covered, so leaving it is an inconsistency | headless, client |
| RscDisplayMissionEditor | colorAttrParent | {1,0,0,1} | enemy | OPFOR | covered | config override | the mission editor is a 2D surface and Cfg3DEN is already covered, so leaving it is an inconsistency | headless, client |


### Excluded: the DLC MFD classes

| class path | property | shipped value | role | surface key | decision | mechanism | reason | tier |
|---|---|---|---|---|---|---|---|---|
| CfgVehicles/Heli_Transport_03_base_F/MFD | MFD | - | - | - | excluded | - | the class declares an empty class MFD{} and carries no colour | headless |
| CfgVehicles/Heli_Transport_04_base_F/MFD | MFD | - | - | - | excluded | - | the class declares an empty class MFD{} and carries no colour | headless |
| CfgVehicles/Land_Destroyer_01_Boat_Rack_01_Base_F/MFD | MFD | - | - | - | excluded | - | the class declares an empty class MFD{} and carries no colour | headless |
| CfgVehicles/UAV_06_base_F/MFD | MFD | - | - | - | excluded | - | the class declares an empty class MFD{} and carries no colour | headless |
| CfgVehicles/Plane_Civil_01_base_F/MFD | MFD | {1.0,1.0,1.0} | - | - | excluded | - | the class carries MFD tint and status colours only | headless |
| CfgVehicles/VTOL_01_base_F/MFD | MFD | {0.15,1.0,0.15,1.0} | - | - | excluded | - | the class carries MFD tint and status colours only | headless |
| CfgVehicles/VTOL_01_base_F/Turrets/CopilotTurret/MFD | MFD | {0.15,1.0,0.15,1.0} | - | - | excluded | - | the class carries MFD tint and status colours only | headless |
| CfgVehicles/VTOL_01_armed_base_F/MFD | MFD | {0.15,1.0,0.15,1.0} | - | - | excluded | - | the class carries MFD tint and status colours only | headless |
| CfgVehicles/VTOL_02_base_F/MFD | MFD | {0.15,1.0,0.15,1.0} | - | - | excluded | - | the class carries MFD tint and status colours only | headless |
| CfgVehicles/VTOL_02_infantry_dynamicLoadout_base_F/MFD | MFD | {0.15,1.0,0.15,1.0} | - | - | excluded | - | the class carries MFD tint and status colours only | headless |
| CfgVehicles/Offroad_02_base_F/MFD | MFD | {0.15,0.15,1.0,1.0} | - | - | excluded | - | the class carries MFD tint and status colours only | headless |
| CfgVehicles/Plane_Fighter_01_Base_F/MFD | MFD | {0.082,0.408,0.039,1} | - | - | excluded | - | the class carries MFD tint and status colours only | headless |
| CfgVehicles/Plane_Fighter_02_Base_F/MFD | MFD | {0.082,0.408,0.039,1} | - | - | excluded | - | the class carries MFD tint and status colours only | headless |
| CfgVehicles/Plane_Fighter_04_Base_F/MFD | MFD | {0,0.12,0} | - | - | excluded | - | the class carries MFD tint and status colours only | headless |
| CfgVehicles/AFV_Wheeled_01_base_F/MFD | MFD | {0.84,0.86,0.84} | - | - | excluded | - | the class carries MFD tint and status colours only | headless |
| CfgVehicles/AFV_Wheeled_01_up_base_F/MFD | MFD | {0.84,0.86,0.84} | - | - | excluded | - | the class carries MFD tint and status colours only | headless |
| CfgVehicles/LT_01_AT_base_F/MFD | MFD | {0.84,0.86,0.84} | - | - | excluded | - | the class carries MFD tint and status colours only | headless |
| CfgVehicles/LT_01_scout_base_F/MFD | MFD | {0.84,0.86,0.84} | - | - | excluded | - | the class carries MFD tint and status colours only | headless |
| CfgVehicles/LT_01_AA_base_F/MFD | MFD | {0.84,0.86,0.84} | - | - | excluded | - | the class carries MFD tint and status colours only | headless |
| CfgVehicles/LT_01_cannon_base_F/MFD | MFD | {0.84,0.86,0.84} | - | - | excluded | - | the class carries MFD tint and status colours only | headless |
| CfgVehicles/MBT_04_base_F/MFD | MFD | {0.84,0.86,0.84} | - | - | excluded | - | the class carries MFD tint and status colours only | headless |
| CfgVehicles/MBT_04_cannon_base_F/MFD | MFD | {0.84,0.86,0.84} | - | - | excluded | - | the class carries MFD tint and status colours only | headless |


### Excluded: the remaining surfaces

| class path | property | shipped value | role | surface key | decision | mechanism | reason | tier |
|---|---|---|---|---|---|---|---|---|
| CfgInGameUI/IslandMap | colorSync | {0.0,0.0,1.0,1.0} | - | - | excluded | - | the player's own chosen map line colour, with no side meaning, so recolouring it would be a harm | headless |
| CfgMarkerColors/ColorRed | color | {0.9,0,0,1} | - | - | excluded | - | the player's own chosen map line colour, with no side meaning, so recolouring it would be a harm | headless |
| CfgMarkerColors/ColorYellow | color | {0.85,0.85,0,1} | - | - | excluded | - | the player's own chosen map line colour, with no side meaning, so recolouring it would be a harm | headless |
| CfgMarkerColors/ColorGreen | color | {0,0.8,0,1} | - | - | excluded | - | the player's own chosen map line colour, with no side meaning, so recolouring it would be a harm | headless |
| CfgMarkerColors/ColorBlue | color | {0,0,1,1} | - | - | excluded | - | the player's own chosen map line colour, with no side meaning, so recolouring it would be a harm | headless |
| CfgInGameUI | IGUI_TEXT_RGB | - | - | - | excluded | - | an interface grey, not a confusion pair | headless |
| CfgInGameUI | GUI_BCG_RGB | - | - | - | excluded | - | an interface grey, not a confusion pair | headless |
| CfgInGameUI | IGUI_BCG_RGB | - | - | - | excluded | - | an interface grey, not a confusion pair | headless |
| RscMapControl | colorForest | {0.6,0.8,0.2,0.5} | - | - | excluded | - | terrain art, not side identity | headless |
| RscMapControl | colorSea | {0.56,0.8,0.98,0.5} | - | - | excluded | - | terrain art, not side identity | headless |
| CfgInGameUI/TacticalPing/RadialMenu | colorSelectBackground | {1,0,0,1} | - | - | excluded | - | a menu selection highlight, not side identity | headless |
| CfgDebriefing/BLUFORBase | pictureColor | reads Map_BLUFOR_* | - | - | excluded | - | a decorative debriefing picture tint | headless |
| RscTestControlTypes | color | - | - | - | excluded | - | a developer test display, not player visible | headless |
| RscTestObjectUI | color | - | - | - | excluded | - | a developer test display, not player visible | headless |
| RscTitles/RscDebugText | color | - | - | - | excluded | - | a debug title, not player visible | headless |
| CfgCloudlets | colorCoef | {0.7,0.7,0.7,0.7} | - | - | excluded | - | particle art, not side identity | headless |
| RscDisplayLoadingOM/controls/ProgressBar | colorBar | {1,0,0,1} | - | - | excluded | - | the loading bar, seen once per load | headless |
| RscCombo | colorScrollbar | {0.95,0.95,0.95,1} | - | - | excluded | - | an incidental interface accent | headless |
| RscCombo | colorActive | {1,0,0,0} | - | - | excluded | - | an incidental interface accent | headless |
| RscDisplayGameOptions/controls/sliderColorR | colorActive | {1,0,0,1} | - | - | excluded | - | a colour slider accent on the addon's own settings screen | headless |
| RscDisplayGameOptions/controls/sliderColorG | colorActive | {0,1,0,1} | - | - | excluded | - | a colour slider accent on the addon's own settings screen | headless |
| RscDisplayMultiplayer/controls/ValueSessions | color | - | - | - | excluded | - | a legacy duplicate superseded by CA_ValueSessions, which the addon covers | headless |

<!-- SURFACE TABLE END -->

## Not done here

- The override assertion and the client-step assertion of
  `tests/verify_2d_coverage.py`. The first belongs to the override header row
  and the second to the client record row.
- This pass writes no override and changes no addon file.
