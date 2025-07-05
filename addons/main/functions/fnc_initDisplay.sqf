#include "..\script_component.hpp"
params ["_display", "_baseTexture", "_rotation", "_rotationOffset", "_isBackpack"];

private _base = controlNull;
private _ctrl = controlNull;

if (isNull (_display displayCtrl IDC_BASE)) then {
    _base = _display ctrlCreate ["ctrlStaticPicture", IDC_BASE];
    _base ctrlSetPosition [0, 0, 1, 1];

    {
        _ctrl = _display ctrlCreate ["ctrlStaticPicture", _x select 2];
        _ctrl ctrlSetPosition [-0.5, -0.5, 1.5, 1.5];
    } forEach GVAR(effectsHandlers)
};

_base = _display displayCtrl IDC_BASE;
_base ctrlSetText _baseTexture;
_base ctrlCommit 0;

{
    _x params ["_name", "", "_idc", "_textures", "_affectBackpack"];

    _ctrl = _display displayCtrl _idc;
    _ctrl ctrlSetText (_textures select (floor (_rotation mod (count _textures))));
    _ctrl ctrlSetAngle [_rotation + (_rotationOffset * _forEachIndex), 0.5, 0.5, true];
    _ctrl ctrlSetFade (
        [
            1,
            _unit getVariable [format [QGVAR(%1Value), _name], 1]
        ] select (!_isBackpack || {_isBackpack && _affectBackpack})
    );
    _ctrl ctrlCommit 0;
} forEach GVAR(effectsHandlers);
_display setVariable [QGVAR(isForBackpack), _isBackpack];

displayUpdate _display;
