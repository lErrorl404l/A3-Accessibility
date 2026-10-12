// An accessibility help screen, opened from the pause menu. XAG 121: document
// the accessible features where a player will look for them.

class RscStructuredText;

class A3ACC_RscDisplayAccessibility {
    idd = 73001;
    movingEnable = 0;
    enableSimulation = 1;

    class controls {
        class Body: RscStructuredText {
            idc = 1001;
            x = 0.25;
            y = 0.2;
            w = 0.5;
            h = 0.6;
            colorText[] = {0.93, 0.93, 0.93, 1};
            colorBackground[] = {0.10, 0.10, 0.10, 1};
            text = "<t align='left' size='0.9'>A3 Accessibility<br/><br/>Colour blind mode: recolours the map markers, the HUD and 3D icon side colours, the scoreboard, the squad radar and the notification colours.<br/><br/>Reduce camera shake: for motion sensitivity.<br/><br/>Directional gunfire cues: an on-screen cue in the direction of nearby gunfire, for deaf and hard-of-hearing players.<br/><br/>Reduce HUD clutter: hides the kill feed and panels, the HUD group icons and the radio chatter.<br/><br/>Larger map markers: for low vision.<br/><br/>Always walk: no key is needed to change speed.</t>";
        };
    };
};
