#include "..\script_component.hpp"
params ["_unit", "_curBurnValue"];
if (_unit getVariable ["ace_fire_intensity", 0] > 0) then {
    _curBurnValue = (_curBurnValue - (linearConversion [0, 10, _unit getVariable ["ace_fire_intensity", 0], 0, GVAR(burnIncrease), true])) max 0;
} else {
    _curBurnValue = (_curBurnValue + GVAR(burnDecrease)) min 1;
};

_curBurnValue
