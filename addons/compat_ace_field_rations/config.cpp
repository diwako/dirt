#include "script_component.hpp"
class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"dirt_main", "ace_common", "ace_field_rations"};
        author = "diwako";
        url = "https://github.com/diwako/dirt";
        authorUrl = "https://github.com/diwako/dirt";
        skipWhenMissingDependencies = 1;
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgVehicles.hpp"
