// Whole-game colour override for the fixed-name HUD, map and scoreboard classes.
//
// A fixed class name with fixed property names cannot carry per-mode variants the
// way CfgMarkerColors can, and the engine evaluates these arrays once, so a mode
// change cannot recolour them live. They therefore carry one universal palette,
// the gated Protan and Deutan table of docs/PLAN.md section 2.3. It is separated
// at 3:1 by luminance, so every deficiency type, including tritan and
// achromatopsia, can still separate the colours by brightness.

class CfgInGameUI {
    // Vanilla friendly is green and enemy is red, the classic confusion pair.
    class SideColors {
        colorFriendly[] = {0.00, 0.35, 0.85, 1};
        colorEnemy[]    = {1.00, 0.70, 0.00, 1};
        colorNeutral[]  = {0.00, 0.80, 0.80, 1};
        colorCivilian[] = {0.35, 0.35, 0.35, 1};
        colorUnknown[]  = {0.75, 0.75, 0.75, 1};
    };

    class MPTable {
        colorWest[] = {0.00, 0.35, 0.85, 1};
        colorEast[] = {1.00, 0.70, 0.00, 1};
        colorCiv[]  = {0.35, 0.35, 0.35, 1};
        colorRes[]  = {0.00, 0.80, 0.80, 1};
    };

    class SquadRadar {
        friendlyUnitColor[] = {0.00, 0.35, 0.85, 1};
        enemyUnitColor[]    = {1.00, 0.70, 0.00, 1};
        taskIconColor[]     = {1.00, 1.00, 1.00, 1};
    };

    // The vanilla side colours here are profile-driven, so a literal override
    // also removes the user's own map colour choice.
    class IslandMap {
        colorFriendly[]        = {0.00, 0.35, 0.85, 1};
        colorEnemy[]           = {1.00, 0.70, 0.00, 1};
        colorNeutral[]         = {0.00, 0.80, 0.80, 1};
        colorCivilian[]        = {0.35, 0.35, 0.35, 1};
        colorUnknown[]         = {0.75, 0.75, 0.75, 1};
        colorMe[]              = {0.00, 0.35, 0.85, 1};
        colorPlayable[]        = {0.00, 0.80, 0.80, 1};
        colorNonPlayable[]     = {0.35, 0.35, 0.35, 1};
        colorCamera[]          = {0.00, 0.80, 0.80, 1};
        colorSensor[]          = {0.00, 0.80, 0.80, 1};
        colorExposureEnemy[]   = {1.00, 0.70, 0.00, 0.5};
        colorExposureUnknown[] = {0.75, 0.75, 0.75, 0.5};
        colorGroups[]          = {0.00, 0.80, 0.80, 0.5};
        colorActiveGroup[]     = {1.00, 1.00, 1.00, 1};
        colorPath[]            = {1.00, 1.00, 1.00, 1};
        colorPathDone[]        = {0.00, 0.80, 0.80, 0.8};
        colorSync[]            = {0.00, 0.35, 0.85, 1};
        colorDetectorSync[]    = {0.00, 0.80, 0.80, 1};
        colorExplosive[]       = {1.00, 0.70, 0.00, 1};
        colorMissions[]        = {0.75, 0.75, 0.75, 0.5};
        colorActiveMission[]   = {1.00, 1.00, 1.00, 1};
    };
};
