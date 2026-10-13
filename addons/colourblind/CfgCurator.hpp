// Zeus editor draw colours. Only the red and the green properties are converted,
// because each one is the protan and deutan confusion pair. Every other
// CfgCurator colour is white, black, grey, cyan or teal, which is not a red and
// green pair, so the addon leaves it as shipped. The shipped CfgNotifications
// Curator classes are teal, so the addon leaves those as shipped too. No class
// in the shipped CfgCurator states a parent, so each reopen below is bare,
// exactly as the shipped config states it.

class CfgCurator {
    class DrawObject {
        class 2D {
            colorSelectionSquare[] = {"(profilenamespace getvariable ['A3ACC_Surf_CfgCurator_DrawObject_2D_colorSelectionSquare_R',0])","(profilenamespace getvariable ['A3ACC_Surf_CfgCurator_DrawObject_2D_colorSelectionSquare_G',1])","(profilenamespace getvariable ['A3ACC_Surf_CfgCurator_DrawObject_2D_colorSelectionSquare_B',0])",1};
            colorPreviewDisabled[] = {"(profilenamespace getvariable ['A3ACC_Surf_CfgCurator_DrawObject_2D_colorPreviewDisabled_R',1])","(profilenamespace getvariable ['A3ACC_Surf_CfgCurator_DrawObject_2D_colorPreviewDisabled_G',0])","(profilenamespace getvariable ['A3ACC_Surf_CfgCurator_DrawObject_2D_colorPreviewDisabled_B',0])",1};
        };
        class 3D {
            colorSelectionSquare[] = {"(profilenamespace getvariable ['A3ACC_Surf_CfgCurator_DrawObject_3D_colorSelectionSquare_R',0])","(profilenamespace getvariable ['A3ACC_Surf_CfgCurator_DrawObject_3D_colorSelectionSquare_G',1])","(profilenamespace getvariable ['A3ACC_Surf_CfgCurator_DrawObject_3D_colorSelectionSquare_B',0])",1};
            colorPreviewDisabled[] = {"(profilenamespace getvariable ['A3ACC_Surf_CfgCurator_DrawObject_3D_colorPreviewDisabled_R',1])","(profilenamespace getvariable ['A3ACC_Surf_CfgCurator_DrawObject_3D_colorPreviewDisabled_G',0])","(profilenamespace getvariable ['A3ACC_Surf_CfgCurator_DrawObject_3D_colorPreviewDisabled_B',0])",1};
        };
    };
    class DrawWaypoint {
        class 3D {
            colorNormal[] = {"(profilenamespace getvariable ['A3ACC_Surf_CfgCurator_DrawWaypoint_3D_colorNormal_R',0.5])","(profilenamespace getvariable ['A3ACC_Surf_CfgCurator_DrawWaypoint_3D_colorNormal_G',1.0])","(profilenamespace getvariable ['A3ACC_Surf_CfgCurator_DrawWaypoint_3D_colorNormal_B',0.5])",1};
            colorCycleNormal[] = {"(profilenamespace getvariable ['A3ACC_Surf_CfgCurator_DrawWaypoint_3D_colorCycleNormal_R',0.5])","(profilenamespace getvariable ['A3ACC_Surf_CfgCurator_DrawWaypoint_3D_colorCycleNormal_G',1.0])","(profilenamespace getvariable ['A3ACC_Surf_CfgCurator_DrawWaypoint_3D_colorCycleNormal_B',0.5])",1};
        };
    };
    class DrawPlayer {
        class 2D {
            color[] = {"(profilenamespace getvariable ['A3ACC_Surf_CfgCurator_DrawPlayer_2D_color_R',0.7])","(profilenamespace getvariable ['A3ACC_Surf_CfgCurator_DrawPlayer_2D_color_G',0.1])","(profilenamespace getvariable ['A3ACC_Surf_CfgCurator_DrawPlayer_2D_color_B',0])",1};
        };
        class 3D {
            color[] = {"(profilenamespace getvariable ['A3ACC_Surf_CfgCurator_DrawPlayer_3D_color_R',0.7])","(profilenamespace getvariable ['A3ACC_Surf_CfgCurator_DrawPlayer_3D_color_G',0.1])","(profilenamespace getvariable ['A3ACC_Surf_CfgCurator_DrawPlayer_3D_color_B',0])",1};
        };
    };
};
