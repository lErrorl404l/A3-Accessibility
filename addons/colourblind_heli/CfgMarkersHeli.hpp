// The Helicopters DLC ground-support markers. The two EAST classes carry the dark
// red enemy colour and the two RESISTANCE classes the dark green neutral colour,
// so they map to OPFOR and Independent. The parents are declared at the file root
// as external, and they are the classes the two EAST and two RESISTANCE classes
// inherit from.

class GroundSupport_ARTY_WEST;
class GroundSupport_CAS_WEST;

class CfgMarkers {
    class GroundSupport_CAS_EAST: GroundSupport_CAS_WEST {
        color[] = {"(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_GroundSupport_CAS_EAST_color_R',0.5])","(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_GroundSupport_CAS_EAST_color_G',0])","(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_GroundSupport_CAS_EAST_color_B',0])",1};
    };
    class GroundSupport_ARTY_EAST: GroundSupport_ARTY_WEST {
        color[] = {"(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_GroundSupport_ARTY_EAST_color_R',0.5])","(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_GroundSupport_ARTY_EAST_color_G',0])","(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_GroundSupport_ARTY_EAST_color_B',0])",1};
    };
    class GroundSupport_CAS_RESISTANCE: GroundSupport_CAS_WEST {
        color[] = {"(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_GroundSupport_CAS_RESISTANCE_color_R',0])","(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_GroundSupport_CAS_RESISTANCE_color_G',0.5])","(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_GroundSupport_CAS_RESISTANCE_color_B',0])",1};
    };
    class GroundSupport_ARTY_RESISTANCE: GroundSupport_ARTY_WEST {
        color[] = {"(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_GroundSupport_ARTY_RESISTANCE_color_R',0])","(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_GroundSupport_ARTY_RESISTANCE_color_G',0.5])","(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_GroundSupport_ARTY_RESISTANCE_color_B',0])",1};
    };
};
