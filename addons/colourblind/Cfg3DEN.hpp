// Eden editor draw colours. Trigger, Comment and the connection lines carry a
// shipped colour, so each expression default is that colour.

class Cfg3DEN {
    class Trigger {
        class Draw {
            class 3D { color[] = {"(missionnamespace getvariable ['A3ACC_Surf_Cfg3DEN_Trigger_Draw_3D_R',0.1])","(missionnamespace getvariable ['A3ACC_Surf_Cfg3DEN_Trigger_Draw_3D_G',0.1])","(missionnamespace getvariable ['A3ACC_Surf_Cfg3DEN_Trigger_Draw_3D_B',0.9])",1}; };
            class 2D { color[] = {"(missionnamespace getvariable ['A3ACC_Surf_Cfg3DEN_Trigger_Draw_2D_R',0.1])","(missionnamespace getvariable ['A3ACC_Surf_Cfg3DEN_Trigger_Draw_2D_G',0.1])","(missionnamespace getvariable ['A3ACC_Surf_Cfg3DEN_Trigger_Draw_2D_B',0.9])",1}; };
        };
    };
    class Comment {
        class Draw {
            class 3D { color[] = {"(missionnamespace getvariable ['A3ACC_Surf_Cfg3DEN_Comment_Draw_3D_R',0])","(missionnamespace getvariable ['A3ACC_Surf_Cfg3DEN_Comment_Draw_3D_G',1])","(missionnamespace getvariable ['A3ACC_Surf_Cfg3DEN_Comment_Draw_3D_B',0.75])",1}; };
            class 2D { color[] = {"(missionnamespace getvariable ['A3ACC_Surf_Cfg3DEN_Comment_Draw_2D_R',0])","(missionnamespace getvariable ['A3ACC_Surf_Cfg3DEN_Comment_Draw_2D_G',1])","(missionnamespace getvariable ['A3ACC_Surf_Cfg3DEN_Comment_Draw_2D_B',0.75])",1}; };
        };
    };
    class Connections {
        class Group { color[] = {"(missionnamespace getvariable ['A3ACC_Surf_Cfg3DEN_Connections_Group_R',0])","(missionnamespace getvariable ['A3ACC_Surf_Cfg3DEN_Connections_Group_G',1])","(missionnamespace getvariable ['A3ACC_Surf_Cfg3DEN_Connections_Group_B',1])",1}; };
        class Sync { color[] = {"(missionnamespace getvariable ['A3ACC_Surf_Cfg3DEN_Connections_Sync_R',0])","(missionnamespace getvariable ['A3ACC_Surf_Cfg3DEN_Connections_Sync_G',0])","(missionnamespace getvariable ['A3ACC_Surf_Cfg3DEN_Connections_Sync_B',1])",1}; };
        class WaypointActivation { color[] = {"(missionnamespace getvariable ['A3ACC_Surf_Cfg3DEN_Connections_WaypointActivation_R',0])","(missionnamespace getvariable ['A3ACC_Surf_Cfg3DEN_Connections_WaypointActivation_G',0])","(missionnamespace getvariable ['A3ACC_Surf_Cfg3DEN_Connections_WaypointActivation_B',1])",1}; };
    };
};
