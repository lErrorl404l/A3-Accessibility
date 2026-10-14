# The 2D interface colour surface

This file records the vehicle MFD extraction for the 2D coverage work. The
surface table and the headless gate are the remaining parts of that task. They
are not written here yet.

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

## MFD classes in the DLC archives

The six names do not appear in any DLC archive. MFD classes do appear in DLC
vehicle archives, and the colours there are green and red shades under other
subclass names. This changes where an override belongs, because a DLC archive
needs its own addon and the `skipWhenMissingDependencies` flag, as
`docs/research/20-colour-coverage.md` records for the other DLC overrides.

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

Two DLC MFDs carry no colour and need no override:
`a3/air_f_orange/uav_06/config.cpp:236` and
`a3/static_f_destroyer/boat_rack_01/config.cpp:191` each declare an empty
`class MFD{};`. This file records them as well.

The green and red shades in the DLC MFDs are, for example, `{0,0.8,0}` and
`{0.8,0,0}` in `a3/air_f_jets/plane_fighter_01/config.cpp`, and
`{0.15,1,0.15,1.0}` in `a3/air_f_exp/vtol_01/config.cpp`. They are not one of
the six named subclasses, so the name test does not classify them. A value test
against the five side colours would. That test belongs to the surface table.

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

The extraction gives these numbers.

- 21 MFD colour properties carry one of the six named subclasses. All 21 sit in
  `addons/air_f_beta.pbo`, on the three `Heli_Attack_01` classes. The 21 are
  seven subclasses times three vehicles. The seventh is `rwrEnemy`.
- 1522 colour properties sit inside a `CfgVehicles/<vehicle>/MFD` class across
  the 24 archives. This count includes every `color[]` in an MFD subtree, so it
  holds the status colours, the whites, the greys and the black.

`docs/research/20-colour-coverage.md` records two different MFD counts:
`:189` records 160 side-coloured MFD properties, and `:349-350` records 56
vehicle classes with 145 side colours (30 friendly, 115 enemy) against 1245
status reds. Neither count agrees with the other, and neither agrees with this
extraction. The reconciliation is not done. It needs the five side colours
for a value test, and the effective-config rule the earlier count used, where a
property defined twice takes the later value.

## Not done here

- The surface table for this file. It has one row per surface, with the columns
  the task names.
- The headless gate `tests/verify_2d_coverage.py`.
- This pass writes no override and changes no addon file.
