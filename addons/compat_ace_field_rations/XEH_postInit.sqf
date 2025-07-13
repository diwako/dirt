#include "script_component.hpp"
if (is3DEN || !hasInterface) exitWith {};

private _washCondition = [
    {true},
    {
        params ["_unit", "", "_item"];

        GVAR(allowACEXWaterToCleanDirt) &&
        {_unit getVariable [format [QEGVAR(main,%1Value), "groundDirt"], 1] < 0.75} &&
        {
            private _config = _item call CBA_fnc_getItemConfig;
            getNumber (_config >> "acex_field_rations_thirstQuenched") > 0
            && {getNumber (_config >> "acex_field_rations_hungerSatiated") isEqualTo 0}
            && {!(_unit call ace_common_fnc_isSwimming)}
        }
    }
];
private _washStatement = {
    params ["_unit", "", "_item"];
    [_unit, _item] call FUNC(washWithWaterBottle);
    closeDialog 0;
    false // Close context menu
};

{
    [_x, ["CONTAINER"], LSTRING(washWithBottle), [], "z\ace\addons\field_rations\ui\icon_water_tap.paa",
        _washCondition, _washStatement
    ] call CBA_fnc_addItemContextMenuOption;
} forEach ["ACE_ItemCore", "CA_Magazine"];
