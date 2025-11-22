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
        INFO(_text);
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

if (GVAR(sortByDistance)) then {
    _units = _units apply {[_x distanceSqr _camPos, _x]};
    _units sort true;
    _units = _units apply {_x select 1};
};

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

if (GVAR(sortByDistance) && {GVAR(displaysTotal) >= GVAR(maxDynTextures)} && {GVAR(freeDisplays) isEqualTo []}) then {
    private _offIndex = _units findIf {(_x getVariable [QGVAR(partial), false])};
    if (_offIndex isNotEqualTo -1) then {
        private _offSetUnits = _units select [_offIndex, 9999];
        private _newUnits = _offSetUnits select {
            _x getVariable [QGVAR(active), false] &&
            !(_x getVariable [QGVAR(partial), false])
        };
        if (_newUnits isNotEqualTo []) then {
            // systemChat format ["%1: Found partial units beyond inactive units, resetting inactive units to free up displays.", time];
            [{
                {
                    [_x] call FUNC(resetUnit);
                } forEach _this;
            }, _newUnits, GVAR(updateFrequency) / 3] call CBA_fnc_waitAndExecute;
            [{
                {
                    [_x] call FUNC(handleUnit);
                } forEach _this;
            }, _offSetUnits, GVAR(updateFrequency) / 2] call CBA_fnc_waitAndExecute;
        };
    };
};

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
    _x params ["_displayName", "_helperObject"];
    private _display = findDisplay _displayName;
    if (isNull _display) then {
        _helperObject setPosASL (AGLToASL positionCameraToWorld [0,random 1, random 1]);
        continue
    };
    private _text = format ["Orphaned display has been found: %1", _displayName];
    // systemChat _text;
    INFO(_text);
    _display setVariable [QGVAR(name), _displayName];
    _display setVariable [QGVAR(unit), nil];
    _display setVariable [QGVAR(container), nil];
    _display setVariable [QGVAR(definition), format ['#(argb,2048,2048,1)ui("RscDisplayEmpty","%1","ca")', _displayName]];
    GVAR(displays) pushBackUnique _display;
    deleteVehicle _helperObject;
    GVAR(orphanedDisplays) deleteAt _forEachIndex;
} forEachReversed GVAR(orphanedDisplays);
