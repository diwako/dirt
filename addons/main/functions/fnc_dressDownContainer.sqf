#include "..\script_component.hpp"

params [["_container", objNull]];
if (isNull _container) exitWith {};
{
    _x params ["_index", "_texture"];
    _container setObjectTexture [_index, _texture];
} forEach (_container getVariable [QGVAR(textures), []]);
_container setVariable [QGVAR(textures), nil];
_container setVariable [QGVAR(displays), []];
_container setVariable [QGVAR(unit), nil];
_container setVariable [QGVAR(active), nil];
