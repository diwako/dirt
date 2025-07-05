#include "..\script_component.hpp"
params ["_unit", "_curGroundValue"];
if ((stance _unit isEqualTo "PRONE" || !((lifeState _unit) in ["HEALTHY", "INJURED"])) && {(getPosATL _unit) select 2 < 0.1} && {
    private _surface = toLower (getText ((configFile >> "CfgSurfaces" >> ((surfaceType getPosASL _unit) select [1])) >> "soundEnviron"));
    [
        "dirt", "sand", "sand_exp", "grass", "snow", "drygrass", "gravel", "debris",
        "grass_exp", "forest_exp", "dirt_exp", "grasstall_exp", "seabed_exp", "mud_exp", "gravel_exp"
    ] findIf {_x in _surface} > -1
}) then {
    if (abs speed _unit > 0.1) then {
        _curGroundValue = (_curGroundValue - (GVAR(groundIncrease) + GVAR(groundIncrease) * 3 * humidity)) max 0;
    };
} else {
    _curGroundValue = (_curGroundValue + GVAR(groundDecrease)) min 1;
};

_curGroundValue
