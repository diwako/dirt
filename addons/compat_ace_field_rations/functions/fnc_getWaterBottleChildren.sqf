#include "..\script_component.hpp"
params ["_unit"];

private _fnc_getActions = {
    private _actions = [];
    private _cfgWeapons = configFile >> "CfgWeapons";

    {
        private _config = _cfgWeapons >> _x;
        if (getNumber (_config >> "acex_field_rations_thirstQuenched") > 0 &&
            {getNumber (_config >> "acex_field_rations_hungerSatiated") isEqualTo 0}) then {
            private _displayName = getText (_config >> "displayName");
            private _picture = getText (_config >> "picture");

            private _action = [_x, _displayName, _picture, {
                params ["", "_unit", "_item"];
                [FUNC(washWithWaterBottle), [_unit, _item]] call CBA_fnc_execNextFrame;
            }, {true}, {}, _x] call ace_interact_menu_fnc_createAction;
            _actions pushBack [_action, [], _unit];
        };
    } forEach (_unit call ace_common_fnc_uniqueItems);

    _actions
};

[[], _fnc_getActions, _unit, QGVAR(washingBottleActionsCache), 9999, "cba_events_loadoutEvent"] call ace_common_fnc_cachedCall
