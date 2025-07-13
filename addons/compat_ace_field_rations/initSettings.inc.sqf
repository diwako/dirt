#define CBA_SETTINGS_CAT ELSTRING(main,Category)
#define MISC_SUB_CAT format ["3: %1", LELSTRING(main,subcategoryMisc)]

[
    QGVAR(allowACEXWaterToCleanDirt),
    "CHECKBOX",
    [LSTRING(allowACEXWaterToCleanDirt), LSTRING(allowACEXWaterToCleanDirt_desc)],
    [CBA_SETTINGS_CAT, MISC_SUB_CAT],
    true,
    false
] call cba_settings_fnc_init;
