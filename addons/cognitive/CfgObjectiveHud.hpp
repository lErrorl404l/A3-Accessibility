// A small always-on objective panel, for cognitive accessibility: a player who
// loses the brief can recover the current task. RscTitles exists in vanilla, so
// this merges one class into it.

class RscTitles {
    class A3ACC_ObjectiveHud {
        idd = -1;
        duration = 1e10;
        fadeIn = 0;
        fadeOut = 0;
        name = "A3ACC_ObjectiveHud";
        class controls {
            class Objective: RscStructuredText {
                idc = 1001;
                x = 0.4;
                y = 0.02;
                w = 0.2;
                h = 0.05;
                colorText[] = {0.93, 0.93, 0.93, 1};
                colorBackground[] = {0.10, 0.10, 0.10, 1};
                text = "";
            };
        };
    };
};
