#include "..\script_component.hpp"
params ["_unit", ["_saveGameLoaded", false]];

{
    _x setVariable [QGVAR(unit), nil];
    _x setVariable [QGVAR(container), nil];
    GVAR(freeDisplays) pushBackUnique _x;
} forEach (_unit getVariable [QGVAR(displays), []]);
[_unit getVariable [QGVAR(uniformContainer), objNull]] call FUNC(dressDownContainer);
[_unit getVariable [QGVAR(backpackContainer), objNull]] call FUNC(dressDownContainer);
_unit setVariable [QGVAR(displays), nil];
_unit setVariable [QGVAR(active), nil];

if (_saveGameLoaded) then {
    private _uniformBackup = _unit getVariable [format ["%1_backup", QGVAR(uniformContainer)], []];
    private _backpackBackup = _unit getVariable [format ["%1_backup", QGVAR(backpackContainer)], []];
    private _uniform = uniformContainer _unit;
    private _backPack = backpackContainer _unit;
    if (!isNull _uniform && _uniformBackup isNotEqualTo []) then {
        _uniform setVariable [QGVAR(textures), nil];
        {
            _x params ["_index", "_texture"];
            _uniform setObjectTexture [_index, _texture];
            _unit setObjectTexture [_index, _texture];
        } forEach _uniformBackup;
    };
    if (!isNull _backPack && _backpackBackup isNotEqualTo []) then {
        _backPack setVariable [QGVAR(textures), nil];
        {
            _x params ["_index", "_texture"];
            _backPack setObjectTexture [_index, _texture];
        } forEach _backpackBackup;
    };
};
