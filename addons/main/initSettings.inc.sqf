
#define CBA_SETTINGS_CAT LSTRING(Category)
#define GENERAL_SUB_CAT format ["1: %1", localize "str_general"]
#define TEXTURES_SUB_CAT format ["2: %1", LLSTRING(subcategoryTextures)]

[
    QGVAR(enable),
    "CHECKBOX",
    [LSTRING(enable), ""],
    [CBA_SETTINGS_CAT, GENERAL_SUB_CAT],
    true,
    false
] call cba_settings_fnc_init;
[
    QGVAR(affectAI),
    "CHECKBOX",
    [LSTRING(affectAI), LSTRING(affectAI_desc)],
    [CBA_SETTINGS_CAT, GENERAL_SUB_CAT],
    true,
    false
] call cba_settings_fnc_init;
[
    QGVAR(updateFrequency),
    "SLIDER",
    [LSTRING(updateFrequency), LSTRING(updateFrequency_desc)],
    [CBA_SETTINGS_CAT, GENERAL_SUB_CAT],
    [0.1, 10, 2, 1],
    false
] call cba_settings_fnc_init;
[
    QGVAR(maxDynTextures),
    "SLIDER",
    [LSTRING(maxDynTextures), LSTRING(maxDynTextures_desc)],
    [CBA_SETTINGS_CAT, GENERAL_SUB_CAT],
    [1, 500, 100, 0],
    false
] call cba_settings_fnc_init;
[
    QGVAR(maxDistance),
    "SLIDER",
    [LSTRING(maxDistance), LSTRING(maxDistance_desc)],
    [CBA_SETTINGS_CAT, GENERAL_SUB_CAT],
    [1, 1000, 500, 0],
    false
] call cba_settings_fnc_init;
[
    QGVAR(maxDistanceAnimations),
    "SLIDER",
    [LSTRING(maxDistanceAnimations), LSTRING(maxDistanceAnimations_desc)],
    [CBA_SETTINGS_CAT, GENERAL_SUB_CAT],
    [1, 200, 50, 0],
    false
] call cba_settings_fnc_init;
[
    QGVAR(groundIncrease),
    "SLIDER",
    [LSTRING(groundIncrease), LSTRING(groundIncrease_desc)],
    [CBA_SETTINGS_CAT, TEXTURES_SUB_CAT],
    [0.0001, 1, 0.02, 4],
    false
] call cba_settings_fnc_init;
[
    QGVAR(groundDecrease),
    "SLIDER",
    [LSTRING(groundDecrease), LSTRING(groundDecrease_desc)],
    [CBA_SETTINGS_CAT, TEXTURES_SUB_CAT],
    [0.0001, 1, 0.003, 4],
    false
] call cba_settings_fnc_init;
[
    QGVAR(precipitationIncrease),
    "SLIDER",
    [LSTRING(precipitationIncrease), LSTRING(precipitationIncrease_desc)],
    [CBA_SETTINGS_CAT, TEXTURES_SUB_CAT],
    [0.0001, 1, 0.02, 4],
    false
] call cba_settings_fnc_init;
[
    QGVAR(precipitationDecrease),
    "SLIDER",
    [LSTRING(precipitationDecrease), LSTRING(precipitationDecrease_desc)],
    [CBA_SETTINGS_CAT, TEXTURES_SUB_CAT],
    [0.0001, 1, 0.003, 4],
    false
] call cba_settings_fnc_init;
[
    QGVAR(burnIncrease),
    "SLIDER",
    [LSTRING(burnIncrease), LSTRING(burnIncrease_desc)],
    [CBA_SETTINGS_CAT, TEXTURES_SUB_CAT],
    [0.0001, 1, 0.2, 4],
    false
] call cba_settings_fnc_init;
[
    QGVAR(burnDecrease),
    "SLIDER",
    [LSTRING(burnDecrease), LSTRING(burnDecrease_desc)],
    [CBA_SETTINGS_CAT, TEXTURES_SUB_CAT],
    [0.0001, 1, 0.003, 4],
    false
] call cba_settings_fnc_init;
