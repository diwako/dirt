#include "..\script_component.hpp"
params ["_unit", "_curValue"];
private _multiplier = 1;
private _posASLW = getPosASLW _unit;
if (
    _posASLW select 2 < -0.6 && {_multiplier = 5; true} ||
    {_posASLW select 2 < -0.1 && {(stance _unit isNotEqualTo "STAND")} && {_multiplier = 3; true} } ||
    {(rain > 0 && {lineIntersectsSurfaces [getPosWorld _unit vectorAdd [0, 0, 0.5], getPosWorld _unit vectorAdd [0, 0, 50], _unit, objNull, true, 1, "GEOM", "FIRE"] isEqualTo []} && {_multiplier = rain; true})}
) then {
    _curValue = (_curValue - (GVAR(precipitationIncrease) * _multiplier)) max 0;
    _unit setVariable [QGVAR(precitipationModifier), _multiplier];
} else {
    _curValue = (_curValue + GVAR(precipitationDecrease)) min 1;
    _unit setVariable [QGVAR(precitipationModifier), nil];
};
_curValue
