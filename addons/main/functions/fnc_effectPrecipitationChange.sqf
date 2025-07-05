#include "..\script_component.hpp"
params ["_unit", "_curValue"];
private _multiplier = 1;
if (
    (rain > 0 && {lineIntersectsSurfaces [getPosWorld _unit vectorAdd [0, 0, 0.5], getPosWorld _unit vectorAdd [0, 0, 50], _unit, objNull, true, 1, "GEOM", "FIRE"] isEqualTo []} && {_multiplier = rain; true}) ||
    {getPosASLW _unit select 2 < -0.6 && {_multiplier = 5; true}} ||
    {getPosASLW _unit select 2 < -0.1 && {(stance _unit isNotEqualTo "STAND")} && {_multiplier = 3; true} }
) then {
    _curValue = (_curValue - (GVAR(precipitationIncrease) * _multiplier)) max 0;
} else {
    _curValue = (_curValue + GVAR(precipitationDecrease)) min 1;
};
_curValue
