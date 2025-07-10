#include "..\script_component.hpp"

params ["_unit"];

private _fnc_container = {
    params ["_unit", "_container", "_var"];
    if (isNull _container) exitWith {
        _unit setVariable [_var, _container];
    };
    if ((_container getVariable [QGVAR(rotation), -1]) isEqualTo -1) then {
        _container setVariable [QGVAR(rotation), random 360];
        _container setVariable [QGVAR(rotationOffset), random 360];
    };
    private _textures = (_container getObjectTextures CAMO_IDS) select {!isNil "_x"};
    if (_textures isEqualTo [] || {"#(argb,2048,2048,1)ui(" in (_textures select 0)}) then {
        if ("uniform" in _var) then {
            // systemChat format ["(Uniform) Could not find shit for %1", uniform _unit];
            _textures = (_unit getObjectTextures CAMO_IDS) select {!isNil "_x"};
            if (_textures isEqualTo [] || {"#(argb,2048,2048,1)ui(" in (_textures select 0)}) then {
                _textures = [];
                // systemChat format ["(Uniform) Could not find shit for %1 the second!", uniform _unit];
                private _texturesSelections = getArray (configFile >> "CfgWeapons" >> (uniform _unit) >> "hiddenSelections");
                if (_texturesSelections isNotEqualTo []) then {
                    {
                        if ("camo" in (toLower (_texturesSelections select _forEachIndex))) then {
                            _textures pushBack _x;
                        };
                    } forEach (getArray (configFile >> "CfgWeapons" >> (uniform _unit) >> "hiddenSelectionsTextures"));
                } else {
                    _texturesSelections = getArray (configFile >> "CfgVehicles" >> (uniform _unit) >> "hiddenSelections");
                    {
                        if ("camo" in (toLower (_texturesSelections select _forEachIndex))) then {
                            _textures pushBack _x;
                        };
                    } forEach (getArray (configFile >> "CfgVehicles" >> (uniform _unit) >> "hiddenSelectionsTextures"));
                };
                // if (_textures isEqualTo []) then {
                //     systemChat format ["(Uniform) Could not find shit for %1 even in hidden selections", uniform _unit];
                // };
            };
        } else {
            // systemChat format ["(Backpack) Could not find shit for %1", backpack _unit];
            _textures = getArray ((configOf _container) >> "hiddenSelectionsTextures");
        };
    };
    _container setVariable [QGVAR(displays), []];
    _container setVariable [QGVAR(textures), _textures];

    {
        if (_x isEqualTo "") then {continue};
        if (GVAR(freeDisplays) isEqualTo []) then {
            // generate a new display
            if (GVAR(displaysTotal) >= GVAR(maxDynTextures)) then {continue};
            if ((getTextureInfo _x) select 0 <= 0) then {continue};

            // spawn a helper object, the player needs to look at the object that gets the ui2texture display applied
            private _helperObject = createSimpleObject ["Sign_Sphere10cm_F", [0,0,0], true];
            _helperObject setObjectMaterial [0, "a3\structures_f_bootcamp\vr\coverobjects\data\vr_coverobject_basic.rvmat"];
            _helperObject setObjectScale 0.1;

            private _displayName = format["dirt_textures§%1", GVAR(displaysTotal)];
            private _displayDef = format ['#(argb,2048,2048,1)ui("RscDisplayEmpty","%1","ca")', _displayName];
            _helperObject setObjectTexture [0, _displayDef];
            GVAR(displaysTotal) = GVAR(displaysTotal) + 1;
            [{
                params ["", "", "_displayName", "", "_helperObject"];

                _helperObject setPosASL (AGLToASL positionCameraToWorld [0,0.5,1]);
                !(isNull findDisplay _displayName)
            }, {
                params ["_unit", "_container", "_displayName", "_baseTexture", "_helperObject", "_displayDef", "_index", "_var"];
                private _display = findDisplay _displayName;
                (_unit getVariable QGVAR(displays)) pushBack _display;
                (_container getVariable QGVAR(displays)) pushBack _display;
                GVAR(displays) pushBack _display;
                _display setVariable [QGVAR(name), _displayName];
                _display setVariable [QGVAR(unit), _unit];
                _display setVariable [QGVAR(container), _container];
                _display setVariable [QGVAR(definition), _displayDef];
                [_display, _baseTexture, _container getVariable QGVAR(rotation), _container getVariable QGVAR(rotationOffset), "backpack" in _var, _unit] call FUNC(initDisplay);
                _container setObjectTexture [_index, _displayDef];
                deleteVehicle _helperObject;
            }, [_unit, _container, _displayName, _x, _helperObject, _displayDef, _forEachIndex, _var], 10, {
                params ["", "", "_displayName"];
                // systemChat format ["%1 could not find %2", time, _displayName];
                GVAR(orphanedDisplays) pushBack _displayName;
            }] call CBA_fnc_waitUntilAndExecute
        } else {
            // reuse an old display
            private _display = GVAR(freeDisplays) deleteAt 0;
            if (isNull _display) then {continue;};
            (_unit getVariable QGVAR(displays)) pushBack _display;
            (_container getVariable QGVAR(displays)) pushBack _display;
            _display setVariable [QGVAR(unit), _unit];
            _display setVariable [QGVAR(container), _container];
            [_display, _x, _container getVariable QGVAR(rotation), _container getVariable QGVAR(rotationOffset), "backpack" in _var, _unit] call FUNC(initDisplay);
            _container setObjectTexture [_forEachIndex, _display getVariable QGVAR(definition)];
        };
    } forEach _textures;

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
    [{
        params ["_unit", "_fnc_container"];
        if (backpack _unit isNotEqualTo "") then {
            [_unit, backpackContainer _unit, QGVAR(backpackContainer)] call _fnc_container;
        };
    }, [_unit, _fnc_container]] call CBA_fnc_execNextFrame;
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
    if (_unit getVariable [QGVAR(uniformContainer), objNull] isNotEqualTo (uniformContainer _unit)) then {
        [_unit, uniformContainer _unit, QGVAR(uniformContainer)] call _fnc_Handle;
    };
    if (_unit getVariable [QGVAR(backpackContainer), objNull] isNotEqualTo (backpackContainer _unit)) then {
        [_unit, backpackContainer _unit, QGVAR(backpackContainer)] call _fnc_Handle;
    };
};
