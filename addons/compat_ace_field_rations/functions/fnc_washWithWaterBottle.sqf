#include "..\script_component.hpp"
params ["_unit", "_item"];

private _config = _item call CBA_fnc_getItemConfig;
private _amount = getNumber (_config >> "acex_field_rations_thirstQuenched");
if (_amount <= 0 || (getNumber (_config >> "acex_field_rations_hungerSatiated")) isNotEqualTo 0) exitWith {};
private _modifier = linearConversion [0, 20, _amount, 0, 1];
private _curValueDirt = _unit getVariable [format [QEGVAR(main,%1Value), "groundDirt"], 1];
private _newValueDirt = _modifier + _curValueDirt;

private _curValueWater = _unit getVariable [format [QEGVAR(main,%1Value), "precipitationRain"], 1];
private _newValueWater = _curValueWater - _modifier;


private _stanceIndex = ["STAND", "CROUCH", "PRONE"] find stance _unit;
if (!isNull objectParent _unit) then {_stanceIndex = 0};

[_unit, getArray (_config >> "acex_field_rations_consumeAnims") param [_stanceIndex, "", [""]], 1] call ace_common_fnc_doAnimation;

if (isClass (configFile >> "CfgMagazines" >> _item)) then {
    _unit removeMagazineGlobal _item;
} else {
    _unit removeItem _item;
};

private _replacementItem = getText (_config >> "acex_field_rations_replacementItem");
if (_replacementItem != "") then {
    [_unit, _replacementItem] call ace_common_fnc_addToInventory;
};

[QEGVAR(main,adjustValues), [_unit, [
    ["groundDirt", _newValueDirt],
    ["precipitationRain", _newValueWater]
]]] call CBA_fnc_globalEvent;
