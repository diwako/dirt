#include "..\script_component.hpp"
if !(GVAR(explosionEH)) exitWith {};
params ["_projectile", "_pos"];

private _ammoConfig = configOf _projectile;
if ((getNumber (_ammoConfig >> "hit")) < 0.5) exitWith {};
private _maxRange = ((getNumber (_ammoConfig >> "indirectHit")) / 3) * (getNumber (_ammoConfig >> "indirectHitRange")) * (getNumber (_ammoConfig >> "explosive"));

private _units = (GVAR(unitsAll) inAreaArray [ASLToAGL _pos, _maxRange, _maxRange, 0, false, _maxRange]) select {
    simulationEnabled _x &&
    ({GVAR(affectAI) || {isPlayer _x}}) &&
    {!(_x getVariable ["dirt_ignore", false])}
};
if (_units isEqualTo []) exitWith {};

private _groundType = ["groundDirt", "groundSnow"] select (call FUNC(isRainOrSnow));
private _raisedPos = _pos vectorAdd [0, 0, 0.25];
private _result = lineIntersects [_units apply { [_raisedPos, eyePos _x, _x, _projectile] }];
_pos = ASLToAGL _pos;
{
    if (_result select _forEachIndex) then {continue};
    private _damage = linearConversion [1, _maxRange, (_x distance _pos), 1, 0, true];
    private _changes = [];
    private _currentValue = _x getVariable [format [QGVAR(%1Value), _groundType], 1];
    _changes pushBack [_groundType, _currentValue - _damage];

    if (_damage > 0.75) then {
        _currentValue = _x getVariable [format [QGVAR(%1Value), "burn"], 1];
        _changes pushBack ["burn", _currentValue - (_damage / 2)];
    };

    [QGVAR(adjustValues), [_x, _changes]] call CBA_fnc_localEvent;
} forEach _units;
