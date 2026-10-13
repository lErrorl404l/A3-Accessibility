// High-command and editor cursor colours. The Zeus cursors are in the Curator
// addon, whose whole config the engine skips when the Zeus DLC is absent. The
// shipped config leaves Move, Move3D, Track and Track3D uncoloured, so this addon
// does not touch those four. Each colour became a per-channel expression with the
// shipped value as the default. The four 3DENPlaceWaypoint cursors ship the
// neutral green, so each maps to Independent.

class CfgWrapperUI {
    class Cursors {
        class Track;
        class 3DEN;
        class 3DENPlaceWaypoint: 3DEN {
            color[] = {"(missionnamespace getvariable ['A3ACC_Surf_Cursors_3DENPlaceWaypoint_R',0.5])","(missionnamespace getvariable ['A3ACC_Surf_Cursors_3DENPlaceWaypoint_G',1.0])","(missionnamespace getvariable ['A3ACC_Surf_Cursors_3DENPlaceWaypoint_B',0.5])",1.0};
        };
        class 3DENPlaceWaypointMulti: 3DEN {
            color[] = {"(missionnamespace getvariable ['A3ACC_Surf_Cursors_3DENPlaceWaypointMulti_R',0.5])","(missionnamespace getvariable ['A3ACC_Surf_Cursors_3DENPlaceWaypointMulti_G',1.0])","(missionnamespace getvariable ['A3ACC_Surf_Cursors_3DENPlaceWaypointMulti_B',0.5])",1.0};
        };
        class 3DENPlaceWaypointAttach: 3DEN {
            color[] = {"(missionnamespace getvariable ['A3ACC_Surf_Cursors_3DENPlaceWaypointAttach_R',0.5])","(missionnamespace getvariable ['A3ACC_Surf_Cursors_3DENPlaceWaypointAttach_G',1.0])","(missionnamespace getvariable ['A3ACC_Surf_Cursors_3DENPlaceWaypointAttach_B',0.5])",1.0};
        };
        class 3DENPlaceWaypointAttachMulti: 3DEN {
            color[] = {"(missionnamespace getvariable ['A3ACC_Surf_Cursors_3DENPlaceWaypointAttachMulti_R',0.5])","(missionnamespace getvariable ['A3ACC_Surf_Cursors_3DENPlaceWaypointAttachMulti_G',1.0])","(missionnamespace getvariable ['A3ACC_Surf_Cursors_3DENPlaceWaypointAttachMulti_B',0.5])",1.0};
        };
        class HC_move: Track { color[] = {"(missionnamespace getvariable ['A3ACC_Surf_Cursors_HC_move_R',0])","(missionnamespace getvariable ['A3ACC_Surf_Cursors_HC_move_G',0.6])","(missionnamespace getvariable ['A3ACC_Surf_Cursors_HC_move_B',0])",1}; };
        class HC_overFriendly: Track { color[] = {"(missionnamespace getvariable ['A3ACC_Surf_Cursors_HC_overFriendly_R',0])","(missionnamespace getvariable ['A3ACC_Surf_Cursors_HC_overFriendly_G',0.6])","(missionnamespace getvariable ['A3ACC_Surf_Cursors_HC_overFriendly_B',0])",1}; };
    };
};
