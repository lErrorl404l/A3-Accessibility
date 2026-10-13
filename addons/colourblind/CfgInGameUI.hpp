// HUD and respawn-table colours. Every channel reads an addon mission variable.
//
// The mission namespace is not a preference. The engine evaluates this class
// before the profile namespace exists, and a profile expression here terminates
// the game: "Trying to get namespace profile but world is not initialized yet",
// then "Application terminated intentionally". That is proven twice, once on a
// dedicated server where the fatal class was MPTable, and once on a client where
// the same message came from another class in this file. A mission expression in
// the same place cannot be evaluated that early either, but it warns and the
// shipped default stands, which is survivable where a termination is not.
// tests/verify_surface.py refuses a profile expression anywhere in the config.
//
// MPTable is the respawn table, not the scoreboard: the shipped config puts the
// MPTable control under RscRespawnCounter, and no game script reads its colours,
// so the engine reads them, at that early phase.
//
// IslandMap is not overridden: the shipped class reads the engine
// side variables directly, and fnc_applyVars writes those. SquadRadar is not
// overridden either: the extracted shipped config defines no colour property
// for it.
//
// CommandBar carries the team red, which maps to OPFOR. Every red on
// UnitInfo/UnitCombatMode carries OPFOR, including the keys named colorGreen
// and colorWhite, because the shipped value is the side red. The combat mode
// keys colorRed and colorYellow ship black, so the addon leaves them as
// shipped. DragAndDropFont holds the enabled green, which means friendly, so it
// maps to BLUFOR, and the disabled red, which maps to OPFOR.

class CfgInGameUI {
    class SideColors {
        colorFriendly[] = {"(missionnamespace getvariable ['A3ACC_Surf_SideColors_colorFriendly_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_SideColors_colorFriendly_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_SideColors_colorFriendly_B',0.384])",1};
        colorEnemy[] = {"(missionnamespace getvariable ['A3ACC_Surf_SideColors_colorEnemy_R',0.706])","(missionnamespace getvariable ['A3ACC_Surf_SideColors_colorEnemy_G',0.0745])","(missionnamespace getvariable ['A3ACC_Surf_SideColors_colorEnemy_B',0.0196])",1};
        colorNeutral[] = {"(missionnamespace getvariable ['A3ACC_Surf_SideColors_colorNeutral_R',0.606])","(missionnamespace getvariable ['A3ACC_Surf_SideColors_colorNeutral_G',0.606])","(missionnamespace getvariable ['A3ACC_Surf_SideColors_colorNeutral_B',0.606])",1};
        colorCivilian[] = {"(missionnamespace getvariable ['A3ACC_Surf_SideColors_colorCivilian_R',0.606])","(missionnamespace getvariable ['A3ACC_Surf_SideColors_colorCivilian_G',0.606])","(missionnamespace getvariable ['A3ACC_Surf_SideColors_colorCivilian_B',0.606])",1};
        colorUnknown[] = {"(missionnamespace getvariable ['A3ACC_Surf_SideColors_colorUnknown_R',0.863])","(missionnamespace getvariable ['A3ACC_Surf_SideColors_colorUnknown_G',0.584])","(missionnamespace getvariable ['A3ACC_Surf_SideColors_colorUnknown_B',0])",1};
    };

    class MPTable {
        colorWest[] = {"(missionnamespace getvariable ['A3ACC_Surf_MPTable_colorWest_R',0.13])","(missionnamespace getvariable ['A3ACC_Surf_MPTable_colorWest_G',0.41])","(missionnamespace getvariable ['A3ACC_Surf_MPTable_colorWest_B',0.87])",1};
        colorEast[] = {"(missionnamespace getvariable ['A3ACC_Surf_MPTable_colorEast_R',0.83])","(missionnamespace getvariable ['A3ACC_Surf_MPTable_colorEast_G',0.17])","(missionnamespace getvariable ['A3ACC_Surf_MPTable_colorEast_B',0.17])",1};
        colorCiv[]  = {"(missionnamespace getvariable ['A3ACC_Surf_MPTable_colorCiv_R',0.45])","(missionnamespace getvariable ['A3ACC_Surf_MPTable_colorCiv_G',0.05])","(missionnamespace getvariable ['A3ACC_Surf_MPTable_colorCiv_B',0.9])",1};
        colorRes[]  = {"(missionnamespace getvariable ['A3ACC_Surf_MPTable_colorRes_R',0.18])","(missionnamespace getvariable ['A3ACC_Surf_MPTable_colorRes_G',0.65])","(missionnamespace getvariable ['A3ACC_Surf_MPTable_colorRes_B',0.12])",1};
    };

    class CommandBar {
        colorRedTeam[] = {"(missionnamespace getvariable ['A3ACC_Surf_CfgInGameUI_CommandBar_colorRedTeam_R',1.0])","(missionnamespace getvariable ['A3ACC_Surf_CfgInGameUI_CommandBar_colorRedTeam_G',0])","(missionnamespace getvariable ['A3ACC_Surf_CfgInGameUI_CommandBar_colorRedTeam_B',0])",1.0};
        class UnitInfo {
            class UnitCombatMode {
                colorBlue[] = {"(missionnamespace getvariable ['A3ACC_Surf_CfgInGameUI_UnitCombatMode_colorBlue_R',1])","(missionnamespace getvariable ['A3ACC_Surf_CfgInGameUI_UnitCombatMode_colorBlue_G',0])","(missionnamespace getvariable ['A3ACC_Surf_CfgInGameUI_UnitCombatMode_colorBlue_B',0])",0.5};
                colorGreen[] = {"(missionnamespace getvariable ['A3ACC_Surf_CfgInGameUI_UnitCombatMode_colorGreen_R',1])","(missionnamespace getvariable ['A3ACC_Surf_CfgInGameUI_UnitCombatMode_colorGreen_G',0])","(missionnamespace getvariable ['A3ACC_Surf_CfgInGameUI_UnitCombatMode_colorGreen_B',0])",0.7};
                colorWhite[] = {"(missionnamespace getvariable ['A3ACC_Surf_CfgInGameUI_UnitCombatMode_colorWhite_R',1])","(missionnamespace getvariable ['A3ACC_Surf_CfgInGameUI_UnitCombatMode_colorWhite_G',0])","(missionnamespace getvariable ['A3ACC_Surf_CfgInGameUI_UnitCombatMode_colorWhite_B',0])",0.7};
                colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_CfgInGameUI_UnitCombatMode_colorText_R',1])","(missionnamespace getvariable ['A3ACC_Surf_CfgInGameUI_UnitCombatMode_colorText_G',0])","(missionnamespace getvariable ['A3ACC_Surf_CfgInGameUI_UnitCombatMode_colorText_B',0])",1};
            };
        };
    };
    class DragAndDropFont {
        colorEnabled[] = {"(missionnamespace getvariable ['A3ACC_Surf_CfgInGameUI_DragAndDropFont_colorEnabled_R',0])","(missionnamespace getvariable ['A3ACC_Surf_CfgInGameUI_DragAndDropFont_colorEnabled_G',1])","(missionnamespace getvariable ['A3ACC_Surf_CfgInGameUI_DragAndDropFont_colorEnabled_B',0])",0.3};
        colorDisabled[] = {"(missionnamespace getvariable ['A3ACC_Surf_CfgInGameUI_DragAndDropFont_colorDisabled_R',1])","(missionnamespace getvariable ['A3ACC_Surf_CfgInGameUI_DragAndDropFont_colorDisabled_G',0])","(missionnamespace getvariable ['A3ACC_Surf_CfgInGameUI_DragAndDropFont_colorDisabled_B',0])",0.3};
    };
};
