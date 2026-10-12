// Eden editor draw colours, for colour-blind mission makers. Same universal
// palette. The waypoint and logic colours are left alone: their legibility
// depends on the editor background, which this addon cannot see.

class Cfg3DEN {
    class Trigger {
        class Draw {
            class 3D { color[] = {0.00, 0.80, 0.80, 1}; };
            class 2D { color[] = {0.00, 0.80, 0.80, 1}; };
        };
    };
    class Comment {
        class Draw {
            class 3D { color[] = {0.00, 0.35, 0.85, 1}; };
            class 2D { color[] = {0.00, 0.35, 0.85, 1}; };
        };
    };
    class Connections {
        class Group { color[] = {1.00, 0.70, 0.00, 1}; };
        class Sync { color[] = {1.00, 0.70, 0.00, 1}; };
        class WaypointActivation { color[] = {1.00, 0.70, 0.00, 1}; };
    };
};
