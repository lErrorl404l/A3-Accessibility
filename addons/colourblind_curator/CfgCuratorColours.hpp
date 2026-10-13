// The Zeus surfaces the addon converts: the side list in the Zeus display, the
// minefield marker, and the waypoint cursors. SideOPFOR and SideIndependent
// restate the parent the shipped config states, so SideBLUFOR is declared at the
// file root as external, as are the two control classes the list is built from.
//
//   RscDisplayCurator/SideOPFOR/colorText            dark red    OPFOR
//   RscDisplayCurator/SideIndependent/colorText      dark green  Independent
//   CfgMarkers/Minefield/color                       red         OPFOR
//   Cursors/CuratorPlaceWaypoint*                    green       BLUFOR
//   Cursors/CuratorPlaceWaypointDestroy*             red         OPFOR

class RscControlsGroupNoScrollbars;
class SideBLUFOR;

class RscDisplayCurator {
    class Controls {
        class Add: RscControlsGroupNoScrollbars {
            class controls {
                class SideOPFOR: SideBLUFOR {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscDisplayCurator_SideOPFOR_colorText_R',0.5])","(missionnamespace getvariable ['A3ACC_Surf_RscDisplayCurator_SideOPFOR_colorText_G',0])","(missionnamespace getvariable ['A3ACC_Surf_RscDisplayCurator_SideOPFOR_colorText_B',0])",1};
                };
                class SideIndependent: SideBLUFOR {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscDisplayCurator_SideIndependent_colorText_R',0])","(missionnamespace getvariable ['A3ACC_Surf_RscDisplayCurator_SideIndependent_colorText_G',0.5])","(missionnamespace getvariable ['A3ACC_Surf_RscDisplayCurator_SideIndependent_colorText_B',0])",1};
                };
            };
        };
    };
};

class CfgMarkers {
    class Minefield {
        color[] = {"(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_Minefield_color_R',0.9])","(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_Minefield_color_G',0])","(missionnamespace getvariable ['A3ACC_Surf_CfgMarkers_Minefield_color_B',0])",1};
    };
};

class CfgWrapperUI {
    class Cursors {
        class Curator;
        class CuratorPlaceWaypoint: Curator { color[] = {"(missionnamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypoint_R',0.5])","(missionnamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypoint_G',1.0])","(missionnamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypoint_B',0.5])",1}; };
        class CuratorPlaceWaypointMulti: Curator { color[] = {"(missionnamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointMulti_R',0.5])","(missionnamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointMulti_G',1.0])","(missionnamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointMulti_B',0.5])",1}; };
        class CuratorPlaceWaypointCycle: Curator { color[] = {"(missionnamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointCycle_R',0.5])","(missionnamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointCycle_G',1.0])","(missionnamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointCycle_B',0.5])",1}; };
        class CuratorPlaceWaypointGetIn: Curator { color[] = {"(missionnamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointGetIn_R',0.5])","(missionnamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointGetIn_G',1.0])","(missionnamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointGetIn_B',0.5])",1}; };
        class CuratorPlaceWaypointDestroy: Curator { color[] = {"(missionnamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointDestroy_R',1.0])","(missionnamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointDestroy_G',0.0])","(missionnamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointDestroy_B',0.0])",1}; };
        class CuratorPlaceWaypointDestroyMulti: Curator { color[] = {"(missionnamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointDestroyMulti_R',1.0])","(missionnamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointDestroyMulti_G',0.0])","(missionnamespace getvariable ['A3ACC_Surf_Cursors_CuratorPlaceWaypointDestroyMulti_B',0.0])",1}; };
    };
};
