#include "script_component.hpp"
ADDON = false;
#include "XEH_PREP.hpp"

GVAR(modCache) = createHashMap;

#include "initSettings.inc.sqf"

if (hasInterface) then {
    [LSTRING(Category), QGVAR(reset), [LLSTRING(resetKeyBind), LLSTRING(resetKeyBind_desc)], {
        if !(GVAR(enable)) exitWith {false};

        systemChat LLSTRING(resetChatText);
        {
            [_x] call FUNC(resetUnit);
        } forEach GVAR(unitsAll);
        GVAR(unitsAll) = [];

        true
    },
    {false}] call CBA_fnc_addKeybind;
};

ADDON = true;
