// Zeus and high-command cursor colours. The shipped config leaves Move, Move3D,
// Track and Track3D uncoloured, so this addon does not touch those four. Each
// colour became a per-channel expression with the shipped value as the default.
// The four 3DENPlaceWaypoint cursors ship the neutral green, so each maps to
// Independent.

class CfgWrapperUI {
    class Cursors {
        class Curator;
        class Track;
        class 3DEN;
        class 3DENPlaceWaypoint: 3DEN {
            color[] = {"(profilenamespace getvariable ['A3ACC_Surf_Cursors_3DENPlaceWaypoint_R',0.5])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_3DENPlaceWaypoint_G',1.0])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_3DENPlaceWaypoint_B',0.5])",1.0};
        };
        class 3DENPlaceWaypointMulti: 3DEN {
            color[] = {"(profilenamespace getvariable ['A3ACC_Surf_Cursors_3DENPlaceWaypointMulti_R',0.5])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_3DENPlaceWaypointMulti_G',1.0])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_3DENPlaceWaypointMulti_B',0.5])",1.0};
        };
        class 3DENPlaceWaypointAttach: 3DEN {
            color[] = {"(profilenamespace getvariable ['A3ACC_Surf_Cursors_3DENPlaceWaypointAttach_R',0.5])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_3DENPlaceWaypointAttach_G',1.0])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_3DENPlaceWaypointAttach_B',0.5])",1.0};
        };
        class 3DENPlaceWaypointAttachMulti: 3DEN {
            color[] = {"(profilenamespace getvariable ['A3ACC_Surf_Cursors_3DENPlaceWaypointAttachMulti_R',0.5])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_3DENPlaceWaypointAttachMulti_G',1.0])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_3DENPlaceWaypointAttachMulti_B',0.5])",1.0};
        };
        class HC_move: Track { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_Cursors_HC_move_R',0])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_HC_move_G',0.6])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_HC_move_B',0])",1}; };
        class HC_overFriendly: Track { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_Cursors_HC_overFriendly_R',0])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_HC_overFriendly_G',0.6])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_HC_overFriendly_B',0])",1}; };
        class CuratorPlaceWaypoint: Curator { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypoint_R',0.5])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypoint_G',1.0])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypoint_B',0.5])",1}; };
        class CuratorPlaceWaypointMulti: Curator { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointMulti_R',0.5])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointMulti_G',1.0])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointMulti_B',0.5])",1}; };
        class CuratorPlaceWaypointCycle: Curator { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointCycle_R',0.5])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointCycle_G',1.0])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointCycle_B',0.5])",1}; };
        class CuratorPlaceWaypointGetIn: Curator { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointGetIn_R',0.5])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointGetIn_G',1.0])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointGetIn_B',0.5])",1}; };
        class CuratorPlaceWaypointDestroy: Curator { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointDestroy_R',1.0])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointDestroy_G',0.0])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointDestroy_B',0.0])",1}; };
        class CuratorPlaceWaypointDestroyMulti: Curator { color[] = {"(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointDestroyMulti_R',1.0])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointDestroyMulti_G',0.0])","(profilenamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointDestroyMulti_B',0.0])",1}; };
    };
};
