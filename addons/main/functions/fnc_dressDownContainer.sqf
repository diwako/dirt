#include "..\script_component.hpp"

params [["_container", objNull]];
if (isNull _container) exitWith {};
// A3TI Compat
private _a3ti = ((_container getVariable [QGVAR(unit), objNull]) getVariable ["A3TI_oldTextAndMat", []]) isNotEqualTo [] && {getText (configOf _container >> "vehicleClass") != "Backpacks" };

{
    _x params ["_index", "_texture"];
    if (_a3ti) then {
        (((_container getVariable [QGVAR(unit), objNull]) getVariable ["A3TI_oldTextAndMat", []]) select 0) set  [_index, _texture];
    } else {
        _container setObjectTexture [_index, _texture];
    };
} forEach (_container getVariable [QGVAR(textures), []]);
_container setVariable [QGVAR(textures), nil];
_container setVariable [QGVAR(displays), []];
_container setVariable [QGVAR(unit), nil];
_container setVariable [QGVAR(active), nil];
