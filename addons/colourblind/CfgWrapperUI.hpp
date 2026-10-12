// Zeus and high-command cursor colours. Move, Move3D, Track and Track3D have
// no shipped colour, so this addon adds the property to recolour them. Every
// reopened class restates its parent.

class CfgWrapperUI {
    class Cursors {
        class Curator;
        class Move { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_Cursors_Move_R',1])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_Move_G',1])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_Move_B',1])",1}; };
        class Move3D { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_Cursors_Move3D_R',1])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_Move3D_G',1])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_Move3D_B',1])",1}; };
        class Track { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_Cursors_Track_R',1])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_Track_G',1])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_Track_B',1])",1}; };
        class Track3D { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_Cursors_Track3D_R',1])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_Track3D_G',1])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_Track3D_B',1])",1}; };
        class HC_move: Track { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_Cursors_HC_move_R',0])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_HC_move_G',0.6])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_HC_move_B',0])",1}; };
        class HC_overFriendly: Track { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_Cursors_HC_overFriendly_R',0])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_HC_overFriendly_G',0.6])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_HC_overFriendly_B',0])",1}; };
        class CuratorPlaceWaypoint: Curator { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypoint_R',1])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypoint_G',1])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypoint_B',1])",1}; };
        class CuratorPlaceWaypointMulti: Curator { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointMulti_R',1])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointMulti_G',1])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointMulti_B',1])",1}; };
        class CuratorPlaceWaypointCycle: Curator { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointCycle_R',1])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointCycle_G',1])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointCycle_B',1])",1}; };
        class CuratorPlaceWaypointGetIn: Curator { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointGetIn_R',1])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointGetIn_G',1])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointGetIn_B',1])",1}; };
        class CuratorPlaceWaypointDestroy: Curator { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointDestroy_R',1])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointDestroy_G',1])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointDestroy_B',1])",1}; };
        class CuratorPlaceWaypointDestroyMulti: Curator { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointDestroyMulti_R',1])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointDestroyMulti_G',1])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointDestroyMulti_B',1])",1}; };
    };
};
