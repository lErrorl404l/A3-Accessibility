class A3ACC_Tests {
    palette = QPATHTOF(test_palette.sqf);
    config  = QPATHTOF(test_config.sqf);
    setting = QPATHTOF(test_setting.sqf);
    contrast = QPATHTOF(test_contrast.sqf);
    surface = QPATHTOF(test_surface.sqf);
    classify = QPATHTOF(test_classify.sqf);
    frame   = QPATHTOF(test_frame.sqf);
    walk    = QPATHTOF(test_walk.sqf);
    // The runner enumerates this one class, so a test from another component is
    // listed here by its own path rather than by a second registry class.
    clutter = "z\a3acc\addons\cognitive\test_clutter.sqf";
    lowvision = "z\a3acc\addons\lowvision\test_marker.sqf";
    // The cycle test is cross-addon and lives in main, which owns no setting.
    settings = "z\a3acc\addons\main\test_settings.sqf";
};
