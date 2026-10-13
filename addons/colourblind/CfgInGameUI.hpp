// HUD and scoreboard colours. SideColors reads an addon profile variable per
// channel. MPTable reads an addon mission variable per channel: that choice is
// UNVERIFIED, because no note, log or probe records the engine evaluating
// MPTable at startup, and getArray returns the raw expression string, so no
// headless test can settle it. See docs/research/20-colour-coverage.md.
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
        colorFriendly[] = {"(profilenamespace getvariable ['A3ACC_Surf_SideColors_colorFriendly_R',0.709])","(profilenamespace getvariable ['A3ACC_Surf_SideColors_colorFriendly_G',0.972])","(profilenamespace getvariable ['A3ACC_Surf_SideColors_colorFriendly_B',0.384])",1};
        colorEnemy[] = {"(profilenamespace getvariable ['A3ACC_Surf_SideColors_colorEnemy_R',0.706])","(profilenamespace getvariable ['A3ACC_Surf_SideColors_colorEnemy_G',0.0745])","(profilenamespace getvariable ['A3ACC_Surf_SideColors_colorEnemy_B',0.0196])",1};
        colorNeutral[] = {"(profilenamespace getvariable ['A3ACC_Surf_SideColors_colorNeutral_R',0.606])","(profilenamespace getvariable ['A3ACC_Surf_SideColors_colorNeutral_G',0.606])","(profilenamespace getvariable ['A3ACC_Surf_SideColors_colorNeutral_B',0.606])",1};
        colorCivilian[] = {"(profilenamespace getvariable ['A3ACC_Surf_SideColors_colorCivilian_R',0.606])","(profilenamespace getvariable ['A3ACC_Surf_SideColors_colorCivilian_G',0.606])","(profilenamespace getvariable ['A3ACC_Surf_SideColors_colorCivilian_B',0.606])",1};
        colorUnknown[] = {"(profilenamespace getvariable ['A3ACC_Surf_SideColors_colorUnknown_R',0.863])","(profilenamespace getvariable ['A3ACC_Surf_SideColors_colorUnknown_G',0.584])","(profilenamespace getvariable ['A3ACC_Surf_SideColors_colorUnknown_B',0])",1};
    };

    class MPTable {
        colorWest[] = {"(missionnamespace getvariable ['A3ACC_Surf_MPTable_colorWest_R',0.13])","(missionnamespace getvariable ['A3ACC_Surf_MPTable_colorWest_G',0.41])","(missionnamespace getvariable ['A3ACC_Surf_MPTable_colorWest_B',0.87])",1};
        colorEast[] = {"(missionnamespace getvariable ['A3ACC_Surf_MPTable_colorEast_R',0.83])","(missionnamespace getvariable ['A3ACC_Surf_MPTable_colorEast_G',0.17])","(missionnamespace getvariable ['A3ACC_Surf_MPTable_colorEast_B',0.17])",1};
        colorCiv[]  = {"(missionnamespace getvariable ['A3ACC_Surf_MPTable_colorCiv_R',0.45])","(missionnamespace getvariable ['A3ACC_Surf_MPTable_colorCiv_G',0.05])","(missionnamespace getvariable ['A3ACC_Surf_MPTable_colorCiv_B',0.9])",1};
        colorRes[]  = {"(missionnamespace getvariable ['A3ACC_Surf_MPTable_colorRes_R',0.18])","(missionnamespace getvariable ['A3ACC_Surf_MPTable_colorRes_G',0.65])","(missionnamespace getvariable ['A3ACC_Surf_MPTable_colorRes_B',0.12])",1};
    };

    class CommandBar {
        colorRedTeam[] = {"(profilenamespace getvariable ['A3ACC_Surf_CfgInGameUI_CommandBar_colorRedTeam_R',1.0])","(profilenamespace getvariable ['A3ACC_Surf_CfgInGameUI_CommandBar_colorRedTeam_G',0])","(profilenamespace getvariable ['A3ACC_Surf_CfgInGameUI_CommandBar_colorRedTeam_B',0])",1.0};
        class UnitInfo {
            class UnitCombatMode {
                colorBlue[] = {"(profilenamespace getvariable ['A3ACC_Surf_CfgInGameUI_UnitCombatMode_colorBlue_R',1])","(profilenamespace getvariable ['A3ACC_Surf_CfgInGameUI_UnitCombatMode_colorBlue_G',0])","(profilenamespace getvariable ['A3ACC_Surf_CfgInGameUI_UnitCombatMode_colorBlue_B',0])",0.5};
                colorGreen[] = {"(profilenamespace getvariable ['A3ACC_Surf_CfgInGameUI_UnitCombatMode_colorGreen_R',1])","(profilenamespace getvariable ['A3ACC_Surf_CfgInGameUI_UnitCombatMode_colorGreen_G',0])","(profilenamespace getvariable ['A3ACC_Surf_CfgInGameUI_UnitCombatMode_colorGreen_B',0])",0.7};
                colorWhite[] = {"(profilenamespace getvariable ['A3ACC_Surf_CfgInGameUI_UnitCombatMode_colorWhite_R',1])","(profilenamespace getvariable ['A3ACC_Surf_CfgInGameUI_UnitCombatMode_colorWhite_G',0])","(profilenamespace getvariable ['A3ACC_Surf_CfgInGameUI_UnitCombatMode_colorWhite_B',0])",0.7};
                colorText[] = {"(profilenamespace getvariable ['A3ACC_Surf_CfgInGameUI_UnitCombatMode_colorText_R',1])","(profilenamespace getvariable ['A3ACC_Surf_CfgInGameUI_UnitCombatMode_colorText_G',0])","(profilenamespace getvariable ['A3ACC_Surf_CfgInGameUI_UnitCombatMode_colorText_B',0])",1};
            };
        };
    };
    class DragAndDropFont {
        colorEnabled[] = {"(profilenamespace getvariable ['A3ACC_Surf_CfgInGameUI_DragAndDropFont_colorEnabled_R',0])","(profilenamespace getvariable ['A3ACC_Surf_CfgInGameUI_DragAndDropFont_colorEnabled_G',1])","(profilenamespace getvariable ['A3ACC_Surf_CfgInGameUI_DragAndDropFont_colorEnabled_B',0])",0.3};
        colorDisabled[] = {"(profilenamespace getvariable ['A3ACC_Surf_CfgInGameUI_DragAndDropFont_colorDisabled_R',1])","(profilenamespace getvariable ['A3ACC_Surf_CfgInGameUI_DragAndDropFont_colorDisabled_G',0])","(profilenamespace getvariable ['A3ACC_Surf_CfgInGameUI_DragAndDropFont_colorDisabled_B',0])",0.3};
    };
};
