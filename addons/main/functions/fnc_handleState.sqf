#include "..\script_component.hpp"
params ["_unit"];

private _updateArr = [];
{
    _x params ["_name", "_fnc", "_idc", "", "_affectBackpack", "_condition"];
    if !(_unit call _condition) then {continue};
    private _curValue = _unit getVariable [format [QGVAR(%1Value), _name], 1];
    private _newValue = 0 max ([_unit, _curValue] call _fnc) min 1;
    if (_curValue isNotEqualTo _newValue) then {
        _unit setVariable [format [QGVAR(%1Value), _name], _newValue];
        _updateArr pushBack [_idc, _newValue, _affectBackpack];
    };
} forEach GVAR(effectsHandlers);
if (_updateArr isNotEqualTo []) then {
    {
        private _display = _x;
        {
            if (_display getVariable [QGVAR(isForBackpack), false] && !(_x select 2)) then {
                continue
            };
            private _ctrl = _display displayCtrl (_x select 0);
            _ctrl ctrlSetFade (_x select 1);
            _ctrl ctrlCommit GVAR(updateFrequency);
        } forEach _updateArr;
    } forEach (_unit getVariable [QGVAR(displays), []]);
    _unit setVariable [QGVAR(updateTextures), true];
} else {
    _unit setVariable [QGVAR(updateTextures), nil];
};
