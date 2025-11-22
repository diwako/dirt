#include "script_component.hpp"
if (is3DEN) exitWith {};

{
    _x addEventHandler ["Explode", {
    params ["_projectile"];
    if ((netId _projectile) == "0:0") then {
        [QGVAR(explosionEH), _this] call CBA_fnc_localEvent;
    } else {
        [QGVAR(explosionEH), _this] call CBA_fnc_globalEvent;
    };
}];
} forEach ((8 allObjects 2) select {local _x});
addMissionEventHandler ["ProjectileCreated", {
    params ["_projectile"];
    if !(local _projectile) exitWith {};
    _projectile addEventHandler ["Explode", {
        params ["_projectile"];
        if ((netId _projectile) == "0:0") then {
            [QGVAR(explosionEH), _this] call CBA_fnc_localEvent;
        } else {
            [QGVAR(explosionEH), _this] call CBA_fnc_globalEvent;
        };
    }];
}];

if !(hasInterface) exitWith {};

GVAR(unitsAll) = [];
GVAR(unitsFar) = [];
GVAR(unitsClose) = [];

GVAR(displays) = [];
GVAR(freeDisplays) = [];
GVAR(displaysTotal) = 0;
GVAR(orphanedDisplays) = [];

GVAR(closePFH) = -1;
GVAR(farPFH) = -1;

GVAR(effectsHandlers) = [];

GVAR(textureCache) = createHashMap;

private _fnc_evaluateCondition = {
    params ["_text"];
    if (_text isEqualTo "") exitWith { {true} };
    if (isNil _text) then {
        compile _text;
    } else {
        missionNamespace getVariable _text;
    };
};
private _effectIndex = 2;
{
    GVAR(effectsHandlers) pushBack [
        configName _x,
        missionNamespace getVariable [getText (_x >> "function"), {1}],
        _effectIndex,
        getArray (_x >> "textures"),
        (getNumber (_x >> "affectBackpack")) isEqualTo 1,
        (getText (_x >> "condition")) call _fnc_evaluateCondition,
        getNumber (_x >> "conditionRefresh")
    ];
    _effectIndex = _effectIndex + 1;
} forEach ("true" configClasses (configFile >> "dirt_textures_man"));
{
    GVAR(effectsHandlers) pushBack [
        configName _x,
        missionNamespace getVariable [getText (_x >> "function"), {1}],
        _effectIndex,
        (getArray (_x >> "textures")) apply {getMissionPath _x},
        (getNumber (_x >> "affectBackpack")) isEqualTo 1,
        (getText (_x >> "condition")) call _fnc_evaluateCondition,
        getNumber (_x >> "conditionRefresh")
    ];
    _effectIndex = _effectIndex + 1;
} forEach ("true" configClasses (missionConfigFile >> "dirt_textures_man"));

["CAManBase", "Respawn", {
    params ["_unit"];
    if !(local _unit) exitWith {};
    private _arr = GVAR(effectsHandlers) apply {[_x select 0]};
    [QGVAR(adjustValues), [_unit, _arr]] call CBA_fnc_globalEvent;
    _unit setVariable [QGVAR(displays), nil];
    _unit setVariable [QGVAR(uniformContainer), nil];
    _unit setVariable [QGVAR(backpackContainer), nil];
    _unit setVariable [QGVAR(active), nil];
}] call CBA_fnc_addClassEventHandler;

[QGVAR(adjustValues), {
    params ["_unit", "_values"];
    {
        _x params ["_name", ["_newValue", 1]];
        private _index = GVAR(effectsHandlers) findIf {(_x select 0) == _name};
        if (_index isEqualTo -1) then {
            private _text = format ["Refused to set new texture effect value, no effect handler found: %1", _name];
            INFO(_text);
            continue;
        };
        (GVAR(effectsHandlers) select _index) params ["", "", "_idc", "", "_affectBackpack", ""];
        _newValue = 0 max _newValue min 1;
        _unit setVariable [format [QGVAR(%1Value), _name], _newValue];
        {
            if (_x getVariable [QGVAR(isForBackpack), false] && !_affectBackpack) then {
                continue
            };
            private _ctrl = _x displayCtrl _idc;
            _ctrl ctrlSetFade _newValue;
            _ctrl ctrlCommit GVAR(updateFrequency);
        } forEach (_unit getVariable [QGVAR(displays), []]);
    } forEach _values;
    _unit setVariable [QGVAR(updateTextures), true];
}] call CBA_fnc_addEventHandler;

[QGVAR(explosionEH), {call FUNC(handleExplosionEH)}] call CBA_fnc_addEventHandler;

if (GVAR(preWarmUp)) then {
    for "_i" from 0 to (GVAR(maxDynTextures) - 1) do {
        [{
            params ["_i"];
            private _helperObject = createSimpleObject ["Sign_Sphere10cm_F", [0,0,0], true];
            _helperObject setObjectMaterial [0, "a3\structures_f_bootcamp\vr\coverobjects\data\vr_coverobject_basic.rvmat"];
            _helperObject setObjectScale 0.1;

            private _displayName = format["dirt_textures§%1", _i];
            _helperObject setObjectTexture [0, format ['#(argb,2048,2048,1)ui("RscDisplayEmpty","%1","ca")', _displayName]];
            [{
                params ["_displayName", "_helperObject"];

                // _helperObject setPosASL (AGLToASL positionCameraToWorld [0,0.5,1]);
                _helperObject setPosASL (AGLToASL positionCameraToWorld [0,random 1, random 1]);
                !(isNull findDisplay _displayName)
            }, {
                params ["_displayName", "_helperObject"];
                private _display = findDisplay _displayName;
                GVAR(displays) pushBack _display;
                _display setVariable [QGVAR(name), _displayName];
                _display setVariable [QGVAR(definition), format ['#(argb,2048,2048,1)ui("RscDisplayEmpty","%1","ca")', _displayName]];
                deleteVehicle _helperObject;
                GVAR(displaysTotal) = GVAR(displaysTotal) + 1;
            }, [_displayName, _helperObject], 10, {
                params ["_displayName", "_helperObject"];
                private _text = format ["Display has not been found in time, is now orphaned: %1", _displayName];
                // systemChat _text;
                INFO(_text);
                GVAR(orphanedDisplays) pushBack [_displayName, _helperObject];
                GVAR(displaysTotal) = GVAR(displaysTotal) + 1;
            }] call CBA_fnc_waitUntilAndExecute
        }, [_i], 0.03 * _i] call CBA_fnc_waitAndExecute;
    };
    [{
        // systemChat format ["textures: %1 (%3) | %2", GVAR(displaysTotal), GVAR(maxDynTextures), count GVAR(displays)];
        GVAR(maxDynTextures) isEqualTo GVAR(displaysTotal)
    }, {
        [FUNC(loop), [], 1] call CBA_fnc_waitAndExecute;
    }] call CBA_fnc_waitUntilAndExecute
} else {
    [FUNC(loop), [], 1] call CBA_fnc_waitAndExecute;
};
