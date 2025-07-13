class CfgVehicles {
    class Man;

    class CAManBase: Man {
        class ACE_SelfActions {
            class ACE_Equipment {
                class GVAR(ACEXWaterToCleanDirt) {
                    displayName = CSTRING(washWithBottle);
                    condition = QUOTE(call FUNC(canWashWithWaterBottle));
                    exceptions[] = {"isNotInside", "isNotSitting", "isNotOnLadder", "isNotSwimming"};
                    statement = "true";
                    showDisabled = 0;
                    insertChildren = QUOTE(_player call FUNC(getWaterBottleChildren));
                    icon = "z\ace\addons\field_rations\ui\icon_water_tap.paa";
                };
            };
        };
    };
};
