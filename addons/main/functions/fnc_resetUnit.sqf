#include "..\script_component.hpp"
params ["_unit"];

{
    _x setVariable [QGVAR(unit), nil];
    _x setVariable [QGVAR(container), nil];
    GVAR(freeDisplays) pushBack _x;
} forEach (_unit getVariable [QGVAR(displays), []]);
[_unit getVariable [QGVAR(uniformContainer), objNull]] call FUNC(dressDownContainer);
[_unit getVariable [QGVAR(backpackContainer), objNull]] call FUNC(dressDownContainer);
_unit setVariable [QGVAR(displays), nil];
_unit setVariable [QGVAR(active), nil];
