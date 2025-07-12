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
#define CAMO_IDS ["camo","camo_1","camo_2","camo_3","camo_4","camo_5","camo_6","camo_7","camo_launcher","camo_lod","camo_tube","camo_veil","camo01","camo1","camo1a","camo2","camo02","camo3_nutsack","camo03","camo3","camo4","camo05","camo5","camo6","camo7","camo8","camo9","camo10","camo11","camo12","camo13","camob","camogl","camomag","tex_01","tex_02","tex_03","tex_04","tex_05","tex_06","tex_07","tex_08","tex1","tex2","tex3","tex4","tex5","cmao","camo_01","camo_02","camo_03"]
