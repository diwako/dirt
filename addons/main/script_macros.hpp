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
#define CAMO_IDS ["camo","camo2","camo1","Camo3","Camo2","Camo1","Camo_1","Camo_2","camo_launcher","camo_tube","camo3","Camo","camo4","camo5","camo6","camo8","CamoMag","Camo4","CamoB","camo01","camo02","camo03","camo05","Camo_3","camo_1","camo_2","camo_3","camo3_nutsack","camo1a","Camo5","camo7","camo9","camo10","camoB","camob","Camo6","Camo7","camo_veil","CamoGL","camo_lod"]
