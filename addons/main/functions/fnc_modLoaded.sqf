#include "..\script_component.hpp"
params [["_mod", "", [""]]];

GVAR(modCache) getOrDefaultCall [toLower _mod, {isClass (configFile >> "CfgPatches" >> _mod)}, true]
