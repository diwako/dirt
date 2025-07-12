#include "..\script_component.hpp"

params ["_unit"];

private _fnc_container = {
    params ["_unit", "_container", "_var"];
    if (isNull _container) exitWith {
        _unit setVariable [_var, _container];
    };
    if (GVAR(displaysTotal) >= GVAR(maxDynTextures) && {GVAR(freeDisplays) isEqualTo []}) exitWith {};
    if ((_container getVariable [QGVAR(rotation), -1]) isEqualTo -1) then {
        _container setVariable [QGVAR(rotation), random 360];
        _container setVariable [QGVAR(rotationOffset), random 360];
    };
    private _textureInfo = _container getVariable [QGVAR(textures), []];
    if (_textureInfo isEqualTo []) then {
        private _textures = getObjectTextures _container;
        private _texturesSelections = [];

        if ("uniform" in _var) then {
            if (_textures isEqualTo []) then {
                _textures = getObjectTextures _unit;
            };
            _texturesSelections = getArray (configFile >> "CfgWeapons" >> (uniform _unit) >> "hiddenSelections");
            if (_texturesSelections isEqualTo []) then {
                _texturesSelections = getArray (configFile >> "CfgVehicles" >> (uniform _unit) >> "hiddenSelections");
            };
        } else {
            _texturesSelections = getArray ((configOf _container) >> "hiddenSelections");
        };


        {
            if ((toLower _x) in CAMO_IDS) then {
                _textureInfo pushBack [_forEachIndex, _textures select _forEachIndex, displayNull];
            };
        } forEach _texturesSelections;

        _container setVariable [QGVAR(textures), _textureInfo];
        _container setVariable [QGVAR(displays), []];
    };
    _container setVariable [QGVAR(active), true];

    {
        _x params ["_index", "_texture", ["_existingDisplay", displayNull]];
        if (!isNull _existingDisplay || {_texture isEqualTo ""} || {(getTextureInfo _texture) select 0 <= 0}) then {continue};
        if (GVAR(freeDisplays) isEqualTo []) then {
            // generate a new display
            if (GVAR(displaysTotal) >= GVAR(maxDynTextures)) then {
                _container setVariable [QGVAR(active), nil];
                continue
            };

            // spawn a helper object, the player needs to look at the object that gets the ui2texture display applied
            private _helperObject = createSimpleObject ["Sign_Sphere10cm_F", [0,0,0], true];
            _helperObject setObjectMaterial [0, "a3\structures_f_bootcamp\vr\coverobjects\data\vr_coverobject_basic.rvmat"];
            _helperObject setObjectScale 0.1;

            private _displayName = format["dirt_textures§%1", GVAR(displaysTotal)];
            _helperObject setObjectTexture [0, format ['#(argb,2048,2048,1)ui("RscDisplayEmpty","%1","ca")', _displayName]];
            GVAR(displaysTotal) = GVAR(displaysTotal) + 1;
            [{
                params ["", "", "_displayName", "", "_helperObject"];

                _helperObject setPosASL (AGLToASL positionCameraToWorld [0,0.5,1]);
                !(isNull findDisplay _displayName)
            }, {
                params ["_unit", "_container", "_displayName", "_baseTexture", "_helperObject", "_index", "_var"];
                private _display = findDisplay _displayName;
                (_unit getVariable QGVAR(displays)) pushBack _display;
                (_container getVariable QGVAR(displays)) pushBack _display;
                GVAR(displays) pushBack _display;
                _display setVariable [QGVAR(name), _displayName];
                _display setVariable [QGVAR(unit), _unit];
                _display setVariable [QGVAR(container), _container];
                _display setVariable [QGVAR(definition), format ['#(argb,2048,2048,1)ui("RscDisplayEmpty","%1","ca")', _displayName]];
                [_display, _baseTexture, _container getVariable QGVAR(rotation), _container getVariable QGVAR(rotationOffset), "backpack" in _var, _unit] call FUNC(initDisplay);
                _container setObjectTexture [_index, _display getVariable QGVAR(definition)];
                deleteVehicle _helperObject;
            }, [_unit, _container, _displayName, _texture, _helperObject, _index, _var], 10, {
                params ["", "_container", "_displayName"];
                // systemChat format ["%1 could not find %2", time, _displayName];
                private _text = format ["Display has not been found in time, is now orphaned: %1", _displayName];
                LOG(_text);
                GVAR(orphanedDisplays) pushBack _displayName;
                _container setVariable [QGVAR(active), nil];
            }] call CBA_fnc_waitUntilAndExecute
        } else {
            // reuse an old display
            private _display = GVAR(freeDisplays) deleteAt 0;
            _x set [2, _display];
            (_unit getVariable QGVAR(displays)) pushBackUnique _display;
            (_container getVariable QGVAR(displays)) pushBackUnique _display;
            _display setVariable [QGVAR(unit), _unit];
            _display setVariable [QGVAR(container), _container];
            [_display, _texture, _container getVariable QGVAR(rotation), _container getVariable QGVAR(rotationOffset), "backpack" in _var, _unit] call FUNC(initDisplay);
            _container setObjectTexture [_index, _display getVariable QGVAR(definition)];
        };
    } forEach _textureInfo;

    _unit setVariable [_var, _container];
    _unit setVariable [QGVAR(updateTextures), true];
};

if !(_unit getVariable [QGVAR(active), false]) then {
    _unit setVariable [QGVAR(active), true];
    _unit setVariable [QGVAR(displays), []];

    // step 2, add displays to containers
    if (uniform _unit isNotEqualTo "") then {
        [_unit, uniformContainer _unit, QGVAR(uniformContainer)] call _fnc_container;
    };
    if (backpack _unit isNotEqualTo "") then {
        [_unit, backpackContainer _unit, QGVAR(backpackContainer)] call _fnc_container;
    };
} else {
    // check if the backpack or uniform has changed
    private _fnc_Handle = {
        params ["_unit", "_container", "_var"];
        private _displays = (_unit getVariable [_var, objNull]) getVariable [QGVAR(displays), []];
        private _trackedDisplays = _unit getVariable [QGVAR(displays), []];
        _unit setVariable [QGVAR(displays), _trackedDisplays - _displays];
        [_unit getVariable [_var, objNull]] call FUNC(dressDownContainer);
        _unit setVariable [_var, nil];

        {
            _x setVariable [QGVAR(unit), nil];
        } forEach _displays;

        if !(isNull _container) then {
            [_unit, _container, _var] call _fnc_container;
        };
    };

    private _uniformContainer = uniformContainer _unit;
    if (_unit getVariable [QGVAR(uniformContainer), objNull] isNotEqualTo _uniformContainer) then {
        [_unit, _uniformContainer, QGVAR(uniformContainer)] call _fnc_Handle;
    } else {
        if (!isNull _uniformContainer && {!(_uniformContainer getVariable [QGVAR(active), false])}) then {
            [_unit, _uniformContainer, QGVAR(uniformContainer)] call _fnc_container;
        };
    };

    private _backpackContainer = backpackContainer _unit;
    if (_unit getVariable [QGVAR(backpackContainer), objNull] isNotEqualTo _backpackContainer) then {
        [_unit, _backpackContainer, QGVAR(backpackContainer)] call _fnc_Handle;
    } else {
        if (!isNull _backpackContainer && {!(_backpackContainer getVariable [QGVAR(active), false])}) then {
            [_unit, _backpackContainer, QGVAR(backpackContainer)] call _fnc_container;
        };
    };
};
