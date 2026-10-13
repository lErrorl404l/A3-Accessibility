// Side identity markers and the group channel colour.
//
// Red and dark red carry OPFOR. A friendly green carries BLUFOR. A neutral or
// independent green carries Independent. Each class states the parent the
// shipped config states, and each expression default is the shipped value, so
// Off changes nothing. Each parent is declared at the file root as external.
//
//   CfgMarkers/Flag                            red          OPFOR
//   CfgMarkers/Select                          red          OPFOR
//   CfgMarkers/GroundSupport_CAS_EAST          dark red     OPFOR
//   CfgMarkers/GroundSupport_ARTY_EAST         dark red     OPFOR
//   CfgMarkers/Minefield                       red          OPFOR
//   CfgMarkers/GroundSupport_CAS_RESISTANCE    dark green   Independent
//   CfgMarkers/GroundSupport_ARTY_RESISTANCE   dark green   Independent
//   CfgGroupIcons/Flag                         red          OPFOR
//   CfgGroupIcons/Select                       red          OPFOR
//   CfgORBATDefault/color                      red          OPFOR
//   RscChatListDefault/colorGroupChannel       green        BLUFOR

class GroundSupport_ARTY_WEST;
class GroundSupport_CAS_WEST;

class CfgMarkers {
    class Flag {
        color[] = {"(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_Flag_color_R',1])","(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_Flag_color_G',0])","(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_Flag_color_B',0])",1};
    };
    class Select: Flag {
        color[] = {"(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_Select_color_R',1])","(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_Select_color_G',0])","(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_Select_color_B',0])",1};
    };
    class GroundSupport_CAS_EAST: GroundSupport_CAS_WEST {
        color[] = {"(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_GroundSupport_CAS_EAST_color_R',0.5])","(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_GroundSupport_CAS_EAST_color_G',0])","(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_GroundSupport_CAS_EAST_color_B',0])",1};
    };
    class GroundSupport_ARTY_EAST: GroundSupport_ARTY_WEST {
        color[] = {"(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_GroundSupport_ARTY_EAST_color_R',0.5])","(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_GroundSupport_ARTY_EAST_color_G',0])","(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_GroundSupport_ARTY_EAST_color_B',0])",1};
    };
    class Minefield {
        color[] = {"(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_Minefield_color_R',0.9])","(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_Minefield_color_G',0])","(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_Minefield_color_B',0])",1};
    };
    class GroundSupport_CAS_RESISTANCE: GroundSupport_CAS_WEST {
        color[] = {"(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_GroundSupport_CAS_RESISTANCE_color_R',0])","(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_GroundSupport_CAS_RESISTANCE_color_G',0.5])","(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_GroundSupport_CAS_RESISTANCE_color_B',0])",1};
    };
    class GroundSupport_ARTY_RESISTANCE: GroundSupport_ARTY_WEST {
        color[] = {"(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_GroundSupport_ARTY_RESISTANCE_color_R',0])","(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_GroundSupport_ARTY_RESISTANCE_color_G',0.5])","(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_GroundSupport_ARTY_RESISTANCE_color_B',0])",1};
    };
};

class CfgGroupIcons {
    class Flag {
        color[] = {"(missionnamespace getvariable ['A3ACC_Surf_CfgGroupIcons_Flag_color_R',1])","(missionnamespace getvariable ['A3ACC_Surf_CfgGroupIcons_Flag_color_G',0])","(missionnamespace getvariable ['A3ACC_Surf_CfgGroupIcons_Flag_color_B',0])",1};
    };
    class Select: Flag {
        color[] = {"(missionnamespace getvariable ['A3ACC_Surf_CfgGroupIcons_Select_color_R',1])","(missionnamespace getvariable ['A3ACC_Surf_CfgGroupIcons_Select_color_G',0])","(missionnamespace getvariable ['A3ACC_Surf_CfgGroupIcons_Select_color_B',0])",1};
    };
};

class CfgORBATDefault {
    color[] = {"(missionnamespace getvariable ['A3ACC_Surf_CfgORBATDefault_color_R',1])","(missionnamespace getvariable ['A3ACC_Surf_CfgORBATDefault_color_G',0])","(missionnamespace getvariable ['A3ACC_Surf_CfgORBATDefault_color_B',0])",1};
};

class RscChatListDefault {
    colorGroupChannel[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscChatListDefault_colorGroupChannel_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscChatListDefault_colorGroupChannel_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscChatListDefault_colorGroupChannel_B',0.384])",1};
    colorGroupChannelPlayerBackground[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscChatListDefault_colorGroupChannelPlayerBackground_R',0.709])","(missionnamespace getvariable ['A3ACC_Surf_RscChatListDefault_colorGroupChannelPlayerBackground_G',0.972])","(missionnamespace getvariable ['A3ACC_Surf_RscChatListDefault_colorGroupChannelPlayerBackground_B',0.384])",0.5};
};
