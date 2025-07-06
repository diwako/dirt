#include "..\script_component.hpp"

params [["_container", objNull]];
if (isNull _container) exitWith {};
{
    _container setObjectTexture [_forEachIndex, _x];
} forEach (_container getVariable [QGVAR(textures), []]);
_container setVariable [QGVAR(textures), nil];
_container setVariable [QGVAR(displays), []];
_container setVariable [QGVAR(unit), nil];
