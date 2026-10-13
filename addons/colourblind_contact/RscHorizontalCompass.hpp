// The Contact DLC's horizontal compass, the only Contact surface the addon
// converts. DangerZone carries the dark red enemy warning and HQ the side red,
// so both map to OPFOR. The parents are declared at the file root as external.

class RscControlsGroupNoScrollbars;
class RscPicture;

class RscHorizontalCompass: RscControlsGroupNoScrollbars {
    class Controls {
        class Compass: RscControlsGroupNoScrollbars {
            class Controls {
                class DangerZone: RscPicture {
                    colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscHorizontalCompass_DangerZone_colorText_R',0.5])","(missionnamespace getvariable ['A3ACC_Surf_RscHorizontalCompass_DangerZone_colorText_G',0])","(missionnamespace getvariable ['A3ACC_Surf_RscHorizontalCompass_DangerZone_colorText_B',0])",1};
                };
                class Bar1: RscControlsGroupNoScrollbars {
                    class Controls {
                        class HQ: RscPicture {
                            colorText[] = {"(missionnamespace getvariable ['A3ACC_Surf_RscHorizontalCompass_HQ_colorText_R',1])","(missionnamespace getvariable ['A3ACC_Surf_RscHorizontalCompass_HQ_colorText_G',0])","(missionnamespace getvariable ['A3ACC_Surf_RscHorizontalCompass_HQ_colorText_B',0])",1};
                        };
                    };
                };
            };
        };
    };
};
