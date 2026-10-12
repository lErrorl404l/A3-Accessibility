// Marker catalogue side colours, on the universal palette.
//
// The parent is restated on every class. A bare reopen clears the vanilla parent,
// which drops the icon, side, size and scope, and the lost scope then propagates
// to every child marker (o_inf, o_armor, n_air and so on).

class CfgMarkers {
    class Flag;
    class b_unknown: Flag {
        color[] = {0.00, 0.35, 0.85, 1};
    };
    class o_unknown: b_unknown {
        color[] = {1.00, 0.70, 0.00, 1};
    };
    class n_unknown: b_unknown {
        color[] = {0.00, 0.80, 0.80, 1};
    };
};
