//D.I.R.T. script macros
#include "\x\cba\addons\main\script_macros_common.hpp"
#define DFUNC(var1) TRIPLES(ADDON,fnc,var1)
#ifdef DISABLE_COMPILE_CACHE
  #undef PREP
  #define PREP(fncName) DFUNC(fncName) = compileScript [QPATHTOF(functions\DOUBLES(fnc,fncName).sqf)]
#else
  #undef PREP
  #define PREP(fncName) [QPATHTOF(functions\DOUBLES(fnc,fncName).sqf), QFUNC(fncName)] call CBA_fnc_compileFunction
#endif

#define IDC_BASE 1
#define CAMO_IDS ["camo","camo_1","camo_2","camo_3","camo_launcher","camo_lod","camo_tube","camo_veil","camo01","camo1","camo1a","camo2","camo02","camo3_nutsack","camo03","camo3","camo4","camo05","camo5","camo6","camo7","camo8","camo9","camo10","camob","camogl","camomag"]
