#include "..\script_component.hpp"
params ["_display", "_baseTexture", "_container", "_isBackpack", "_unit", "_index"];

private _base = controlNull;
private _ctrl = controlNull;

if (isNull (_display displayCtrl IDC_BASE)) then {
    _base = _display ctrlCreate ["ctrlStaticPicture", IDC_BASE];
    _base ctrlSetPosition [0, 0, 1, 1];

    {
        _ctrl = _display ctrlCreate ["ctrlStaticPicture", _x select 2];
    } forEach GVAR(effectsHandlers)
};

_base = _display displayCtrl IDC_BASE;
_base ctrlSetText _baseTexture;
_base ctrlCommit 0;

private _rotation = _container getVariable QGVAR(rotation);
private _rotationOffset = _container getVariable QGVAR(rotationOffset);
private _customTextures = _container getVariable QGVAR(customTextures);

{
    _x params ["_name", "", "_idc", "_textures", "_affectBackpack"];

    _ctrl = _display displayCtrl _idc;
    private _useCustomTextures = false;

    if (_name in _customTextures) then {
        private _newTextures = _customTextures getOrDefault [_name, []];
        if (count _newTextures > _index) then {
            _newTextures = _newTextures select _index;
            if (_newTextures isNotEqualTo "") then {
                _textures = _newTextures;
                _useCustomTextures = true;
                _ctrl ctrlSetPosition [0, 0, 1, 1];
                _ctrl ctrlSetAngle [0, 0.5, 0.5, true];

                if !(_textures isEqualType []) then {
                    _textures = [_textures];
                };
            };
        };
    };

    if !(_useCustomTextures) then {
        _ctrl ctrlSetPosition [-0.21, -0.21, 1.42, 1.42];
        _ctrl ctrlSetAngle [_rotation + (_rotationOffset * _forEachIndex), 0.5, 0.5, true];
    };

    _ctrl ctrlSetText (_textures select (floor (_rotation mod (count _textures))));
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
