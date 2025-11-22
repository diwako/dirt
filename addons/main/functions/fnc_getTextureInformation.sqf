#include "..\script_component.hpp"

params ["_unit", "_container", "_var"];
private _textureInfo = _container getVariable [QGVAR(textures), []];

if (_textureInfo isEqualTo []) then {
    private _textures = getObjectTextures _container;
    private _texturesSelections = [];
    private _customTextures = [];

    if ("uniform" in _var) then {
        // A3TI Compat
        if ((_unit getVariable ["A3TI_oldTextAndMat", []]) isNotEqualTo []) then {
            _textures = (_unit getVariable ["A3TI_oldTextAndMat",[]]) select 0;
        };
        if (_textures isEqualTo []) then {
            _textures = getObjectTextures _unit;
        };

        private _cache = GVAR(textureCache) getOrDefaultCall [uniform _unit, {
            private _uniformVehicle = getText (configFile >> "CfgWeapons" >> (uniform _unit) >> "ItemInfo" >> "uniformClass");
            private _texturesSelections = getArray (configFile >> "CfgVehicles" >> _uniformVehicle >> "hiddenSelections");
            private _customTextures = createHashMapFromArray (getArray (configFile >> "CfgVehicles" >> _uniformVehicle >> "dirt_customTextures"));

            if (_texturesSelections isEqualTo []) then {
                _texturesSelections = getArray (configFile >> "CfgWeapons" >> (uniform _unit) >> "hiddenSelections");
            };
            if ((count _customTextures) isEqualTo 0) then {
                _customTextures = createHashMapFromArray getArray (configFile >> "CfgWeapons" >> (uniform _unit) >> "dirt_customTextures");
            };
            [_texturesSelections, _customTextures]
        }, true];

        _texturesSelections = _cache select 0;
        _customTextures = _cache select 1;
    } else {
        private _cache = GVAR(textureCache) getOrDefaultCall [backpack _unit, {
            private _texturesSelections = getArray ((configOf _container) >> "hiddenSelections");
            private _customTextures = createHashMapFromArray (getArray ((configOf _container) >> "dirt_customTextures"));
            [_texturesSelections, _customTextures]
        }, true];

        _texturesSelections = _cache select 0;
        _customTextures = _cache select 1;
    };

    {
        if ((toLower _x) in CAMO_IDS && {(_textures select _forEachIndex) isNotEqualTo ""}) then {
            _textureInfo pushBack [_forEachIndex, _textures select _forEachIndex, displayNull];
        };
    } forEach (_texturesSelections select [0, (count _texturesSelections) min (count _textures)]);

    _container setVariable [QGVAR(textures), _textureInfo];
    _container setVariable [QGVAR(displays), []];
    _container setVariable [QGVAR(customTextures), _customTextures];
};

_textureInfo
