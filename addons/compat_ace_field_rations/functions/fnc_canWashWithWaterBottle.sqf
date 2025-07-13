#include "..\script_component.hpp"
params ["_unit"];

GVAR(allowACEXWaterToCleanDirt) &&
{_unit getVariable [format [QEGVAR(main,%1Value), "groundDirt"], 1] < 0.75} &&
{!(_unit getVariable ["ace_captives_isSurrendering", false])} &&
{!(_unit getVariable ["ace_captives_isHandcuffed", false])} &&
{((_unit call ace_common_fnc_uniqueItems) findIf {
    private _config = configFile >> "CfgWeapons" >> _x;
    getNumber (_config >> "acex_field_rations_thirstQuenched") > 0 &&
    {getNumber (_config >> "acex_field_rations_hungerSatiated") isEqualTo 0}
}) isNotEqualTo -1}
