#include "script_component.hpp"
#include "XEH_PREP.hpp"

// Write the stored mode's colour variables before any display is built.
[missionNamespace getVariable ["A3ACC_CVDMode", 0]] call FUNC(applyVars);
