#!/usr/bin/env python3
"""Offline gate for the dynamic surface expressions.

The colour engine writes profile variables and the config reads them back as
per-channel expressions. This gate reads the real writer and the real config
headers, then:

1. Checks every converted colour is a three-expression triple plus an alpha.
2. Checks the config variable names and the writer table are the same set.
3. Checks the engine variables the writer owns, and the ones it must not touch.
4. Checks the deleted override files are gone and unreferenced.
5. Checks every reopened class restates its parent.

It needs no game and no SQF interpreter. Exit code 0 means all gates pass.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ADDON = ROOT / "addons" / "colourblind"
APPLY_VARS = ADDON / "functions" / "fnc_applyVars.sqf"
CONFIG = ADDON / "config.cpp"

CONFIG_FILES = [
    ADDON / "CfgInGameUI.hpp",
    ADDON / "CfgWrapperUI.hpp",
    ADDON / "CfgCurator.hpp",
    ADDON / "CfgRscInGameUI.hpp",
    ADDON / "Cfg3DEN.hpp",
    ADDON / "CfgNotifications.hpp",
    ADDON / "CfgSideIdentity.hpp",
    ADDON / "RscSideDisplays.hpp",
]

DELETED_FILES = [
    ADDON / "CfgMarkerColors.hpp",
    ADDON / "CfgMarkers.hpp",
    ADDON / "CfgGroupIcons.hpp",
    ADDON / "CfgLocationTypes.hpp",
]

# The engine variables the writer owns. Alpha is left to the player.
ENGINE_VARS = [
    "Map_BLUFOR",
    "Map_OPFOR",
    "Map_Independent",
    "Map_Civilian",
    "Map_Unknown",
    "IGUI_ERROR_RGB",
    "IGUI_WARNING_RGB",
    "IGUI_TACTPING_RGB",
]

# The engine variables the writer must not touch.
FORBIDDEN_VARS = ["IGUI_TEXT_RGB", "IGUI_BCG_RGB", "GUI_BCG_RGB"]

# Every reopened class and its required parent. A None parent means the shipped
# config states no parent, so the reopen must be bare.
REOPENED_PARENTS = {
    ("CfgWrapperUI.hpp", "HC_move"): "Track",
    ("CfgWrapperUI.hpp", "HC_overFriendly"): "Track",
    ("CfgWrapperUI.hpp", "CuratorPlaceWaypoint"): "Curator",
    ("CfgWrapperUI.hpp", "CuratorPlaceWaypointMulti"): "Curator",
    ("CfgWrapperUI.hpp", "CuratorPlaceWaypointCycle"): "Curator",
    ("CfgWrapperUI.hpp", "CuratorPlaceWaypointGetIn"): "Curator",
    ("CfgWrapperUI.hpp", "CuratorPlaceWaypointDestroy"): "Curator",
    ("CfgWrapperUI.hpp", "CuratorPlaceWaypointDestroyMulti"): "Curator",
    ("CfgNotifications.hpp", "TaskSucceeded"): "TaskAssigned",
    ("CfgNotifications.hpp", "TaskFailed"): "TaskAssigned",
    ("CfgNotifications.hpp", "TaskCanceled"): "TaskAssigned",
    ("CfgNotifications.hpp", "TaskAssignedIcon"): "TaskCreatedIcon",
    ("CfgNotifications.hpp", "TaskSucceededIcon"): "TaskCreatedIcon",
    ("CfgNotifications.hpp", "TaskFailedIcon"): "TaskCreatedIcon",
    ("CfgNotifications.hpp", "TaskCanceledIcon"): "TaskCreatedIcon",
    ("CfgCurator.hpp", "CfgCurator"): None,
    ("CfgCurator.hpp", "DrawObject"): None,
    ("CfgCurator.hpp", "DrawWaypoint"): None,
    ("CfgCurator.hpp", "DrawPlayer"): None,
    ("CfgCurator.hpp", "2D"): None,
    ("CfgCurator.hpp", "3D"): None,
}

# The optic file repeats leaf class names under different parents, for example
# CA_Distance under RscText in one optic and under RscOpticsValue in another. A
# leaf name alone is not unique there, so every reopened class is also gated by
# its full class path.
REOPENED_PARENTS_BY_PATH = {
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOpticsRangeFinderMRAWS"): "RscUnitInfo",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOpticsRangeFinderMRAWS/CA_IGUI_elements_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOpticsRangeFinderMRAWS/CA_IGUI_elements_group/controls/CA_Distance"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOpticsRangeFinderVorona"): "RscUnitInfo",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOpticsRangeFinderVorona/CA_IGUI_elements_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOpticsRangeFinderVorona/CA_IGUI_elements_group/controls/CA_Distance"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOpticsRangeFinderVorona/CA_IGUI_elements_group/controls/CA_FlirMode"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOpticsRangeFinderVorona/CA_IGUI_elements_group/controls/CA_VisionMode"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOpticsRangeFinderVorona/CA_NFOV_mode_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOpticsRangeFinderVorona/CA_NFOV_mode_group/controls/CA_FOVModeNFOV"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOpticsRangeFinderVorona/CA_WFOV_mode_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOpticsRangeFinderVorona/CA_WFOV_mode_group/controls/CA_FOVModeWFOV"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_APC_Wheeled_01_gunner"): "RscUnitInfo",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_APC_Wheeled_01_gunner/CA_APC_NFOV_mode_group"): "RscControlsGroupNoScrollbars",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_APC_Wheeled_01_gunner/CA_APC_NFOV_mode_group/controls/CA_FOVModeNFOV"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_APC_Wheeled_01_gunner/CA_APC_WFOV_mode_group"): "RscControlsGroupNoScrollbars",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_APC_Wheeled_01_gunner/CA_APC_WFOV_mode_group/controls/CA_FOVModeWFOV"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_APC_Wheeled_01_gunner/CA_IGUI_elements_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_APC_Wheeled_01_gunner/CA_IGUI_elements_group/controls/CA_Distance"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_APC_Wheeled_01_gunner/CA_IGUI_elements_group/controls/CA_FlirMode"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_APC_Wheeled_01_gunner/CA_IGUI_elements_group/controls/CA_Heading"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_APC_Wheeled_01_gunner/CA_IGUI_elements_group/controls/CA_OpticsPitch"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_APC_Wheeled_01_gunner/CA_IGUI_elements_group/controls/CA_TurretIndicator"): "RscPicture",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_APC_Wheeled_01_gunner/CA_IGUI_elements_group/controls/CA_VisionMode"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_APC_Wheeled_01_gunner/CA_IGUI_elements_group/controls/FireSolutionValid"): "RscPicture",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_APC_Wheeled_01_gunner/CA_IGUI_elements_group/controls/TargetSpeedText"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_Boat_Armed_01_commander"): "RscUnitInfo",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_Boat_Armed_01_commander/CA_IGUI_elements_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_Boat_Armed_01_commander/CA_IGUI_elements_group/controls/CA_Distance"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_Boat_Armed_01_commander/CA_IGUI_elements_group/controls/CA_FlirMode"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_Boat_Armed_01_commander/CA_IGUI_elements_group/controls/CA_Heading"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_Boat_Armed_01_commander/CA_IGUI_elements_group/controls/CA_TurretIndicator"): "RscPicture",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_Boat_Armed_01_commander/CA_IGUI_elements_group/controls/CA_VisionMode"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_Boat_Armed_01_commander/CA_IGUI_elements_group/controls/CA_VisionMode_text"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_Boat_Armed_01_commander/CA_IGUI_elements_group/controls/CA_distance_text"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_CAS_01_TGP"): "RscUnitInfo",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_CAS_01_TGP/CA_IGUI_elements_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_CAS_01_TGP/CA_IGUI_elements_group/controls/CA_Laser"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_Heli_Attack_01_pilot"): "RscUnitInfo",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_Heli_Attack_01_pilot/CA_IGUI_elements_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_Heli_Attack_01_pilot/CA_IGUI_elements_group/controls/CA_Laser"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_Heli_Attack_02_gunner"): "RscUnitInfo",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_Heli_Attack_02_gunner/CA_IGUI_elements_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_Heli_Attack_02_gunner/CA_IGUI_elements_group/controls/CA_Distance"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_Heli_Attack_02_gunner/CA_IGUI_elements_group/controls/CA_VisionMode"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_Heli_Attack_02_pilot"): "RscUnitInfo",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_Heli_Attack_02_pilot/CA_IGUI_elements_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_Heli_Attack_02_pilot/CA_IGUI_elements_group/controls/CA_Laser"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_LaserDesignator/CA_IGUI_elements_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_LaserDesignator/CA_IGUI_elements_group/controls/CA_Distance"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_LaserDesignator/CA_IGUI_elements_group/controls/CA_Elev"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_LaserDesignator/CA_IGUI_elements_group/controls/CA_Heading"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_LaserDesignator/CA_IGUI_elements_group/controls/CA_Laser"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_LaserDesignator/CA_IGUI_elements_group/controls/CA_OpticsZoom"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_LaserDesignator/CA_IGUI_elements_group/controls/CA_VisionMode"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_LaserDesignator_02/CA_IGUI_elements_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_LaserDesignator_02/CA_IGUI_elements_group/controls/CA_Distance"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_LaserDesignator_02/CA_IGUI_elements_group/controls/CA_DistanceText"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_LaserDesignator_02/CA_IGUI_elements_group/controls/CA_DistanceTextM"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_LaserDesignator_02/CA_IGUI_elements_group/controls/CA_Elev"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_LaserDesignator_02/CA_IGUI_elements_group/controls/CA_Heading"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_LaserDesignator_02/CA_IGUI_elements_group/controls/CA_HeadingText"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_LaserDesignator_02/CA_IGUI_elements_group/controls/CA_Laser"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_LaserDesignator_02/CA_IGUI_elements_group/controls/CA_OpticsZoom"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_LaserDesignator_02/CA_IGUI_elements_group/controls/CA_OpticsZoomText"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_LaserDesignator_02/CA_IGUI_elements_group/controls/CA_VisionMode"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_LaserDesignator_02/CA_IGUI_elements_group/controls/CA_VisionModeText"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_LaserDesignator_02/CA_IGUI_elements_group/controls/TextElev"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander"): "RscUnitInfo",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander/CA_APC_NFOV_mode_group"): "RscControlsGroupNoScrollbars",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander/CA_APC_NFOV_mode_group/controls/CA_FOVModeNFOV"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander/CA_APC_WFOV_mode_group"): "RscControlsGroupNoScrollbars",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander/CA_APC_WFOV_mode_group/controls/CA_FOVModeWFOV"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander/CA_IGUI_elements_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander/CA_IGUI_elements_group/controls/AzimuthMark"): "RscPicture",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander/CA_IGUI_elements_group/controls/CA_FlirMode"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander/CA_IGUI_elements_group/controls/CA_Heading"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander/CA_IGUI_elements_group/controls/CA_HorizontalCompass"): "RscPicture",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander/CA_IGUI_elements_group/controls/CA_LasedRange"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander/CA_IGUI_elements_group/controls/CA_OpticsPitch"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander/CA_IGUI_elements_group/controls/CA_TurretIndicator"): "RscPicture",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander/CA_IGUI_elements_group/controls/CA_VisionMode"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander_RCWS"): "RscUnitInfo",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander_RCWS/CA_APC_NFOV_mode_group"): "RscControlsGroupNoScrollbars",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander_RCWS/CA_APC_NFOV_mode_group/controls/CA_FOVModeNFOV"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander_RCWS/CA_APC_WFOV_mode_group"): "RscControlsGroupNoScrollbars",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander_RCWS/CA_APC_WFOV_mode_group/controls/CA_FOVModeWFOV"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander_RCWS/CA_IGUI_elements_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander_RCWS/CA_IGUI_elements_group/controls/AzimuthMark"): "RscPicture",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander_RCWS/CA_IGUI_elements_group/controls/CA_FlirMode"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander_RCWS/CA_IGUI_elements_group/controls/CA_Heading"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander_RCWS/CA_IGUI_elements_group/controls/CA_HorizontalCompass"): "RscPicture",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander_RCWS/CA_IGUI_elements_group/controls/CA_LasedRange"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander_RCWS/CA_IGUI_elements_group/controls/CA_MaxElevERR"): "CA_OpticsPitch",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander_RCWS/CA_IGUI_elements_group/controls/CA_OpticsPitch"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander_RCWS/CA_IGUI_elements_group/controls/CA_TurretIndicator"): "RscPicture",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_commander_RCWS/CA_IGUI_elements_group/controls/CA_VisionMode"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_gunner"): "RscUnitInfo",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_gunner/CA_APC_NFOV_mode_group"): "RscControlsGroupNoScrollbars",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_gunner/CA_APC_NFOV_mode_group/controls/CA_FOVModeNFOV"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_gunner/CA_APC_WFOV_mode_group"): "RscControlsGroupNoScrollbars",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_gunner/CA_APC_WFOV_mode_group/controls/CA_FOVModeWFOV"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_gunner/CA_IGUI_elements_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_gunner/CA_IGUI_elements_group/controls/AzimuthMark"): "RscPicture",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_gunner/CA_IGUI_elements_group/controls/CA_FlirMode"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_gunner/CA_IGUI_elements_group/controls/CA_Heading"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_gunner/CA_IGUI_elements_group/controls/CA_HorizontalCompass"): "RscPicture",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_gunner/CA_IGUI_elements_group/controls/CA_LasedRange"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_gunner/CA_IGUI_elements_group/controls/CA_MaxElevERR"): "CA_OpticsPitch",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_gunner/CA_IGUI_elements_group/controls/CA_MaxLeadERR"): "CA_LasedObjectERR",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_gunner/CA_IGUI_elements_group/controls/CA_OpticsPitch"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_gunner/CA_IGUI_elements_group/controls/CA_TurretIndicator"): "RscPicture",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_gunner/CA_IGUI_elements_group/controls/CA_VisionMode"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_MBT_01_gunner/CA_IGUI_elements_group/controls/TargetSpeedText"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_Rangefinder"): "RscUnitInfo",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_Rangefinder/CA_IGUI_elements_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_Rangefinder/CA_IGUI_elements_group/controls/CA_Distance"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_Rangefinder/CA_IGUI_elements_group/controls/CA_Heading"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_Rangefinder/CA_IGUI_elements_group/controls/CA_VisionMode"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_SDV_driver"): "RscUnitInfo",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_SDV_driver/DriverOpticsGroup"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_SDV_driver/DriverOpticsGroup/controls/ValuePitch"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_SDV_periscope/CA_IGUI_elements_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_SDV_periscope/CA_IGUI_elements_group/controls/CA_Distance"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_SDV_periscope/CA_IGUI_elements_group/controls/CA_Elev"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_SDV_periscope/CA_IGUI_elements_group/controls/CA_Laser"): "RscPicture",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_SDV_periscope/CA_IGUI_elements_group/controls/CA_OpticsZoom"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_SDV_periscope/CA_IGUI_elements_group/controls/CA_VisionMode"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_UAV_gunner"): "RscUnitInfo",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_UAV_gunner/CA_IGUI_elements_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_UAV_gunner/CA_IGUI_elements_group/controls/CA_Laser"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_VTOL_01_copilot"): "RscUnitInfo",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_VTOL_01_copilot/CA_IGUI_elements_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_VTOL_01_copilot/CA_IGUI_elements_group/controls/CA_Laser"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_VTOL_01_gunner"): "RscUnitInfo",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_VTOL_01_gunner/CA_IGUI_elements_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_VTOL_01_gunner/CA_IGUI_elements_group/controls/CA_MaxElevERR"): "Text_Grid",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_VTOL_01_gunner/CA_IGUI_elements_group/controls/CA_MaxLeadERR"): "Text_Grid",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_VTOL_02_gunner"): "RscUnitInfo",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_VTOL_02_gunner/CA_IGUI_elements_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_VTOL_02_gunner/CA_IGUI_elements_group/controls/CA_Distance"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_VTOL_02_gunner/CA_IGUI_elements_group/controls/CA_Laser"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_VTOL_02_gunner/CA_IGUI_elements_group/controls/CA_VisionMode"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_cows"): "RscUnitInfo",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_cows/CA_NFOV_mode_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_cows/CA_NFOV_mode_group/controls/CA_Distance_NFOV"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_cows/CA_WFOV_mode_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_cows/CA_WFOV_mode_group/controls/CA_Distance_WFOV"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_crows"): "RscUnitInfo",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_crows/CA_IGUI_elements_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_crows/CA_IGUI_elements_group/controls/CA_Distance"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_crows/CA_IGUI_elements_group/controls/CA_FlirMode"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_crows/CA_IGUI_elements_group/controls/CA_Heading"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_crows/CA_IGUI_elements_group/controls/CA_TurretIndicator"): "RscPicture",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_crows/CA_IGUI_elements_group/controls/CA_VisionMode"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_crows/CA_IGUI_elements_group/controls/CA_VisionMode_text"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_crows/CA_IGUI_elements_group/controls/CA_distance_text"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_punisher/CA_IGUI_elements_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_punisher/CA_IGUI_elements_group/Controls/A3_DEG_text"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_punisher/CA_IGUI_elements_group/Controls/A3_FuseRange"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_punisher/CA_IGUI_elements_group/Controls/CA_Distance"): "RscOpticsValue",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_punisher/CA_IGUI_elements_group/Controls/CA_Elev"): "RscOpticsValue",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_punisher/CA_IGUI_elements_group/Controls/CA_VisionMode"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_sos"): "RscUnitInfo",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_sos/CA_IGUI_elements_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_sos/CA_IGUI_elements_group/controls/CA_Distance"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_sos/CA_Sniper_NFOV_mode_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_sos/CA_Sniper_NFOV_mode_group/controls/CA_FOVModeNFOV"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_sos/CA_Sniper_WFOV_mode_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_sos/CA_Sniper_WFOV_mode_group/controls/CA_FOVModeWFOV"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_strider_commander/CA_IGUI_elements_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_strider_commander/CA_IGUI_elements_group/controls/CA_Distance"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_strider_commander/CA_IGUI_elements_group/controls/CA_Elev"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_strider_commander/CA_IGUI_elements_group/controls/CA_Heading"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_strider_commander/CA_IGUI_elements_group/controls/CA_Laser"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_strider_commander/CA_IGUI_elements_group/controls/CA_OpticsZoom"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscOptics_strider_commander/CA_IGUI_elements_group/controls/CA_VisionMode"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscWeaponRangeArtillery/CA_IGUI_elements_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscWeaponRangeArtillery/CA_IGUI_elements_group/controls/CA_Distance"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscWeaponRangeArtillery/CA_IGUI_elements_group/controls/CA_Elev"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscWeaponRangeArtillery/CA_IGUI_elements_group/controls/CA_Elev_Need"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscWeaponRangeArtillery/CA_IGUI_elements_group/controls/CA_Heading"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscWeaponRangeArtillery/CA_IGUI_elements_group/controls/CA_OpticsPitch"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscWeaponRangeArtillery/CA_IGUI_elements_group/controls/CA_OpticsZoom"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscWeaponRangeArtillery/CA_IGUI_elements_group/controls/CA_Time"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscWeaponRangeArtillery/CA_IGUI_elements_group/controls/CA_VisionMode"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscWeaponRangeArtillery/CA_RangeElements_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscWeaponRangeArtillery/CA_RangeElements_group/controls/CA_OORange"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscWeaponRangeArtilleryAuto/CA_AutoElements_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscWeaponRangeArtilleryAuto/CA_AutoElements_group/controls/CA_Auto"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscWeaponRangeArtilleryAuto/CA_IGUI_elements_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscWeaponRangeArtilleryAuto/CA_IGUI_elements_group/controls/CA_Distance"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscWeaponRangeArtilleryAuto/CA_IGUI_elements_group/controls/CA_Elev"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscWeaponRangeArtilleryAuto/CA_IGUI_elements_group/controls/CA_Elev_Need"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscWeaponRangeArtilleryAuto/CA_IGUI_elements_group/controls/CA_Heading"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscWeaponRangeArtilleryAuto/CA_IGUI_elements_group/controls/CA_OpticsPitch"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscWeaponRangeArtilleryAuto/CA_IGUI_elements_group/controls/CA_OpticsZoom"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscWeaponRangeArtilleryAuto/CA_IGUI_elements_group/controls/CA_Time"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscWeaponRangeArtilleryAuto/CA_IGUI_elements_group/controls/CA_VisionMode"): "RscText",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscWeaponRangeArtilleryAuto/CA_RangeElements_group"): "RscControlsGroup",
    ("CfgRscInGameUI.hpp", "RscInGameUI/RscWeaponRangeArtilleryAuto/CA_RangeElements_group/controls/CA_OORange"): "RscText",
    ("CfgSideIdentity.hpp", "CfgGroupIcons/Select"): "Flag",
    ("CfgSideIdentity.hpp", "CfgMarkers/GroundSupport_ARTY_EAST"): "GroundSupport_ARTY_WEST",
    ("CfgSideIdentity.hpp", "CfgMarkers/GroundSupport_ARTY_RESISTANCE"): "GroundSupport_ARTY_WEST",
    ("CfgSideIdentity.hpp", "CfgMarkers/GroundSupport_CAS_EAST"): "GroundSupport_CAS_WEST",
    ("CfgSideIdentity.hpp", "CfgMarkers/GroundSupport_CAS_RESISTANCE"): "GroundSupport_CAS_WEST",
    ("CfgSideIdentity.hpp", "CfgMarkers/Select"): "Flag",
    ("RscSideDisplays.hpp", "RscDisplayCurator/Controls/Add"): "RscControlsGroupNoScrollbars",
    ("RscSideDisplays.hpp", "RscDisplayCurator/Controls/Add/controls/SideIndependent"): "SideBLUFOR",
    ("RscSideDisplays.hpp", "RscDisplayCurator/Controls/Add/controls/SideOPFOR"): "SideBLUFOR",
    ("RscSideDisplays.hpp", "RscDisplayMultiplayer"): "RscStandardDisplay",
    ("RscSideDisplays.hpp", "RscDisplayMultiplayer/controls/CA_ValueSessions"): "RscListBox",
    ("RscSideDisplays.hpp", "RscCustomInfoAirborneMiniMap"): "RscCustomInfoMiniMap",
    ("RscSideDisplays.hpp", "RscCustomInfoAirborneMiniMap/controls"): "controls",
    ("RscSideDisplays.hpp", "RscCustomInfoAirborneMiniMap/controls/MiniMap"): "MiniMap",
    ("RscSideDisplays.hpp", "RscCustomInfoAirborneMiniMap/controls/MiniMap/Controls"): "Controls",
    ("RscSideDisplays.hpp", "RscCustomInfoAirborneMiniMap/controls/MiniMap/Controls/CA_MiniMap"): "CA_MiniMap",
    ("RscSideDisplays.hpp", "RscDisplayMultiplayerSetup"): "RscStandardDisplay",
    ("RscSideDisplays.hpp", "RscDisplayMultiplayerSetup/controls/CA_ValueRoles"): "RscListBox",
    ("RscSideDisplays.hpp", "RscHorizontalCompass"): "RscControlsGroupNoScrollbars",
    ("RscSideDisplays.hpp", "RscHorizontalCompass/Controls/Compass"): "RscControlsGroupNoScrollbars",
    ("RscSideDisplays.hpp", "RscHorizontalCompass/Controls/Compass/Controls/DangerZone"): "RscPicture",
    ("RscSideDisplays.hpp", "RscHorizontalCompass/Controls/Compass/Controls/Bar1"): "RscControlsGroupNoScrollbars",
    ("RscSideDisplays.hpp", "RscHorizontalCompass/Controls/Compass/Controls/Bar1/Controls/HQ"): "RscPicture",
}

# A class block opener, by indentation, so the class path can be rebuilt.
CLASS_PATH_OPEN = re.compile(
    r"^([ \t]*)class\s+([A-Za-z0-9_]+)\s*(?::\s*([A-Za-z0-9_]+))?\s*(?:\{|$)"
)


def class_parents(text: str) -> dict[str, str]:
    """Return {class path: declared parent} for every class that states one."""
    stack: list[tuple[int, str]] = []
    found: dict[str, str] = {}
    for line in text.splitlines():
        match = CLASS_PATH_OPEN.match(line)
        if match:
            indent = len(match.group(1))
            while stack and stack[-1][0] >= indent:
                stack.pop()
            stack.append((indent, match.group(2)))
            if match.group(3):
                found["/".join(name for _, name in stack)] = match.group(3)
    return found


# A per-channel expression over an addon surface variable, in either namespace.
EXPR_RE = re.compile(
    r"\"\((profilenamespace|missionnamespace) getvariable "
    r"\['A3ACC_Surf_([A-Za-z0-9_]+)_([RGB])',([0-9.]+)\]\)\""
)
TABLE_RE = re.compile(r'^\s*\["([A-Za-z0-9_]+)", "([A-Za-z]+)"\],?\s*$', re.M)
CLASS_RE = re.compile(r"class\s+(\w+)(\s*:\s*(\w+))?\s*\{")


def table_block(text: str, marker: str) -> str:
    split = text.split(marker, 1)
    if len(split) != 2:
        return ""
    return split[1].split("];", 1)[0]


def main() -> int:
    failures: list[str] = []

    # Gate 1 and 2: the config triples and the writer tables are the same set,
    # per namespace.
    apply_text = APPLY_VARS.read_text(encoding="utf-8")
    profile_table = {
        m.group(1)
        for m in TABLE_RE.finditer(table_block(apply_text, "private _surfaceVars = ["))
    }
    mission_table = {
        m.group(1)
        for m in TABLE_RE.finditer(table_block(apply_text, "private _missionVars = ["))
    }
    if not profile_table:
        failures.append("fnc_applyVars.sqf: the _surfaceVars table is empty")
    if not mission_table:
        failures.append("fnc_applyVars.sqf: the _missionVars table is empty")

    config_profile: set[str] = set()
    config_mission: set[str] = set()
    channels: dict[str, set[str]] = {}
    for path in CONFIG_FILES:
        text = path.read_text(encoding="utf-8")
        for match in EXPR_RE.finditer(text):
            namespace, name, channel, _default = match.groups()
            (config_profile if namespace == "profilenamespace" else config_mission).add(
                name
            )
            channels.setdefault(name, set()).add(channel)

    for name in sorted(config_profile - profile_table):
        failures.append(
            f"config reads profile variable {name} but the writer has no such variable"
        )
    for name in sorted(profile_table - config_profile):
        failures.append(
            f"the writer writes profile variable {name} but no config reads it"
        )
    for name in sorted(config_mission - mission_table):
        failures.append(
            f"config reads mission variable {name} but the writer has no such variable"
        )
    for name in sorted(mission_table - config_mission):
        failures.append(
            f"the writer writes mission variable {name} but no config reads it"
        )

    # Gate 3: every surface colour is a triple.
    for name, found in sorted(channels.items()):
        if found != {"R", "G", "B"}:
            failures.append(f"{name}: channels {sorted(found)}, expected R, G, B")

    # Gate 4: the engine variables, owned and forbidden.
    for var in ENGINE_VARS:
        if f'"{var}"' not in apply_text:
            failures.append(f"fnc_applyVars.sqf does not write {var}")
    for var in FORBIDDEN_VARS:
        if var in apply_text:
            failures.append(f"fnc_applyVars.sqf must not touch {var}")

    # Gate 5: the deleted files are gone and unreferenced.
    config_text = CONFIG.read_text(encoding="utf-8")
    for path in DELETED_FILES:
        if path.exists():
            failures.append(f"{path.name} still exists")
        if path.name in config_text:
            failures.append(f"config.cpp still includes {path.name}")

    # Gate 6: every reopened class restates its parent.
    texts = {path.name: path.read_text(encoding="utf-8") for path in CONFIG_FILES}
    for (filename, cls), parent in REOPENED_PARENTS.items():
        found = False
        for match in CLASS_RE.finditer(texts[filename]):
            if match.group(1) == cls:
                found = True
                if match.group(3) != parent:
                    failures.append(
                        f"{filename} {cls}: parent is {match.group(3)!r}, expected {parent!r}"
                    )
        if not found:
            failures.append(f"{filename} {cls}: class not found")

    for (filename, cls_path), parent in REOPENED_PARENTS_BY_PATH.items():
        declared = class_parents(texts[filename])
        if cls_path not in declared:
            failures.append(f"{filename} {cls_path}: class not found")
        elif declared[cls_path] != parent:
            failures.append(
                f"{filename} {cls_path}: parent is {declared[cls_path]!r}, "
                f"expected {parent!r}"
            )

    if failures:
        print("FAILURES:")
        for failure in failures:
            print(f"  - {failure}")
        return 1

    print(
        f"[verify_surface] PASS: {len(config_profile)} profile and {len(config_mission)} mission "
        f"surface variables in the config and the writer, {len(ENGINE_VARS)} engine variables owned, "
        "no forbidden variable, no deleted override, every parent restated, "
        f"{len(REOPENED_PARENTS_BY_PATH)} class paths gated by parent"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
