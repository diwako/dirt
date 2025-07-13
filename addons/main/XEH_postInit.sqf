#include "script_component.hpp"
if (is3DEN || !hasInterface) exitWith {};

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
        (getText (_x >> "condition")) call _fnc_evaluateCondition
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
        (getText (_x >> "condition")) call _fnc_evaluateCondition
    ];
    _effectIndex = _effectIndex + 1;
} forEach ("true" configClasses (missionConfigFile >> "dirt_textures_man"));

player addEventHandler ["Respawn", {
    params ["_unit"];
    {
        _unit setVariable [format [QGVAR(%1Value), _x select 0], nil];
    } forEach GVAR(effectsHandlers);
    _unit setVariable [QGVAR(displays), nil];
    _unit setVariable [QGVAR(uniformContainer), nil];
    _unit setVariable [QGVAR(backpackContainer), nil];
    _unit setVariable [QGVAR(active), nil];
}];

[QGVAR(adjustValues), {
    params ["_unit", "_values"];
    {
        _x params ["_name", "_newValue"];
        private _index = GVAR(effectsHandlers) findIf {(_x select 0) == _name};
        if (_index isEqualTo -1) then {
            private _text = format ["Refused to set new texture effect value, no effect handler found: %1", _name];
            LOG(_text);
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

[FUNC(loop), [], 1] call CBA_fnc_waitAndExecute;
