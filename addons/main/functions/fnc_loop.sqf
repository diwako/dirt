#include "..\script_component.hpp"

[FUNC(loop), [], GVAR(updateFrequency)] call CBA_fnc_waitAndExecute;
if !(GVAR(enable)) exitWith {
    {
        [_x] call FUNC(resetUnit);
    } forEach GVAR(unitsAll);
    GVAR(unitsAll) = [];
};

// check for savegame load, displays become null then
if (GVAR(displays) isNotEqualTo [] && {isNull (GVAR(displays) select 0)}) exitWith {
    [{
        private _text = "Save game detected";
        LOG(_text);
        {
            [_x] call FUNC(resetUnit);
        } forEach GVAR(unitsAll);
        GVAR(displays) = [];
        GVAR(freeDisplays) = [];
        GVAR(displaysTotal) = 0;
        GVAR(orphanedDisplays) = [];
        GVAR(unitsAll) = [];
    }] call CBA_fnc_execNextFrame;
};

private _camPos = positionCameraToWorld [0,0,0];
private _units = allUnits;
_units append allDead;
_units = (_units inAreaArray [_camPos, GVAR(maxDistance), GVAR(maxDistance), 0, false, -1]) select {
    simulationEnabled _x &&
    ({GVAR(affectAI) || {isPlayer _x}}) &&
    {!(_x getVariable ["dirt_ignore", false])}
};

{
    [_x] call FUNC(resetUnit);
} forEach (GVAR(unitsAll) select {!(_x in _units)});

private _freeDisplays = GVAR(displays) select {
    !(_x in GVAR(freeDisplays)) && {(
        isNull (_x getVariable [QGVAR(unit), objNull]) ||
        {isNull (_x getVariable [QGVAR(container), objNull])}
    )}
};
if (_freeDisplays isNotEqualTo []) then {
    GVAR(freeDisplays) append _freeDisplays;
};

{
    [_x] call FUNC(handleState);
    [_x] call FUNC(handleUnit);
} forEach _units;

private _unitsClose = _units inAreaArray [_camPos, GVAR(maxDistanceAnimations), GVAR(maxDistanceAnimations), 0, false, -1];
GVAR(unitsAll) = _units;
GVAR(unitsClose) = _unitsClose;
GVAR(unitsFar) = _units - _unitsClose;

if (GVAR(closePFH) isEqualTo -1) then {
    GVAR(closePFH) = [{
        params ["", "_pfhHandle"];
        if !(GVAR(enable)) exitWith {
            [_pfhHandle] call CBA_fnc_removePerFrameHandler;
            GVAR(closePFH) = -1;
        };
        {
            [_x] call FUNC(updateTextures)
        } forEach GVAR(unitsClose);
    }] call CBA_fnc_addPerframeHandler;
};
if (GVAR(farPFH) isEqualTo -1) then {
    GVAR(farPFH) = [{
        params ["", "_pfhHandle"];
        if !(GVAR(enable)) exitWith {
            [_pfhHandle] call CBA_fnc_removePerFrameHandler;
            GVAR(farPFH) = -1;
        };
        {
            [_x, true] call FUNC(updateTextures)
        } forEach GVAR(unitsFar);
    }, GVAR(updateFrequency)] call CBA_fnc_addPerframeHandler;
};

// sometimes the displays take a while to initialize
// often the player was not looking at the unit
{
    private _display = findDisplay _x;
    if (isNull _display) then {continue};
    private _text = format ["Orphaned display has been found: %1", _x];
    LOG(_text);
    _display setVariable [QGVAR(name), _x];
    _display setVariable [QGVAR(unit), nil];
    _display setVariable [QGVAR(container), nil];
    _display setVariable [QGVAR(definition), format ['#(argb,2048,2048,1)ui("RscDisplayEmpty","%1","ca")', _x]];
    GVAR(displays) pushBackUnique _display;
    GVAR(orphanedDisplays) deleteAt _forEachIndex;
} forEachReversed GVAR(orphanedDisplays);
