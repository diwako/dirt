#include "..\script_component.hpp"
params ["_unit", ["_force", false]];

if !(_force || _unit getVariable [QGVAR(updateTextures), false]) exitWith {};
{
    displayUpdate _x;
} forEach (_unit getVariable [QGVAR(displays), []]);
