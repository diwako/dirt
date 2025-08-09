#include "..\script_component.hpp"

/*

Returns true for Snow
Returns false for Rain

*/

rainParams select 15 || {"snow" in (toLowerANSI (rainParams select 0))}
