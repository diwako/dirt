#include "script_component.hpp"
class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"cba_main"};
        author = "diwako";
        url = "https://github.com/diwako/dirt";
        authorUrl = "https://github.com/diwako/dirt";
        license = "https://www.bohemia.net/community/licenses/arma-public-license-share-alike";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"

class dirt_textures_man {
    class burn {
        textures[] = {QPATHTOF(textures\burnt_ca.paa)};
        function = QFUNC(effectBurnChange);
        condition = "";
        affectBackpack = 1;
    };
    class groundDirt : burn {
        textures[] = {QPATHTOF(textures\dirtierer_ca.paa)};
        function = QFUNC(effectGroundChange);
        condition = "!(rainParams select 15)";
    };
    class groundSnow : groundDirt {
        textures[] = {QPATHTOF(textures\snow_ca.paa)};
        function = QFUNC(effectGroundChange);
        condition = "rainParams select 15";
    };
    class precipitationRain : groundDirt {
        textures[] = {QPATHTOF(textures\water_ca.paa)};
        function = QFUNC(effectPrecipitationChange);
    };
    class precipitationSnow : groundSnow {
        textures[] = {QPATHTOF(textures\snowfall_ca.paa)};
        function = QFUNC(effectPrecipitationChange);
    };
};
