#include "..\script_component.hpp"

params ["_unit", "_name", "_condition", ["_refresh", 10]];

private _id = format [QGVAR(cachedCondition$%1), _name];
if ((_unit getVariable [_id, [-1]]) select 0 < time) then {
    _unit setVariable [_id, [time + _refresh, _unit call _condition]];
};

(_unit getVariable _id) select 1
