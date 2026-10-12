// Group icon side colours, mirroring CfgMarkers. The parent is restated so a bare
// reopen cannot clear the vanilla inheritance.

class CfgGroupIcons {
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
