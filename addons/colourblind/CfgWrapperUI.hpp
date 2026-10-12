// Zeus and high-command cursor colours. Vanilla green move and friendly cursors
// and red destroy cursors are the protan and deutan confusion pair. Same
// universal palette: green becomes blue, red becomes amber. The parents are
// restated so a bare reopen cannot clear them.

class CfgWrapperUI {
    class Cursors {
        class Curator;
        class Move { color[] = {0.00, 0.35, 0.85, 1}; };
        class Move3D { color[] = {0.00, 0.35, 0.85, 1}; };
        class Track { color[] = {1.00, 0.70, 0.00, 1}; };
        class Track3D { color[] = {1.00, 0.70, 0.00, 1}; };
        class HC_move: Track { color[] = {0.00, 0.35, 0.85, 1}; };
        class HC_overFriendly: Track { color[] = {0.00, 0.35, 0.85, 1}; };
        class CuratorPlaceWaypoint: Curator { color[] = {0.00, 0.35, 0.85, 1}; };
        class CuratorPlaceWaypointMulti: Curator { color[] = {0.00, 0.35, 0.85, 1}; };
        class CuratorPlaceWaypointCycle: Curator { color[] = {0.00, 0.35, 0.85, 1}; };
        class CuratorPlaceWaypointGetIn: Curator { color[] = {0.00, 0.35, 0.85, 1}; };
        class CuratorPlaceWaypointDestroy: Curator { color[] = {1.00, 0.70, 0.00, 1}; };
        class CuratorPlaceWaypointDestroyMulti: Curator { color[] = {1.00, 0.70, 0.00, 1}; };
    };
};
