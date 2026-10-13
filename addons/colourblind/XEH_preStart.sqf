#include "script_component.hpp"
#include "XEH_PREP.hpp"

// Write the saved mode's colour variables before any display is built, so a
// screen created during startup reads the right colours.
//
// The CBA setting cannot be read here. CBA publishes a setting into
// missionNamespace from its own postInit, one frame after that, so
// "A3ACC_CVDMode" is nil at preStart. Read the mode this addon saved on its
// last apply instead. The CBA value is authoritative and replaces this one a
// frame after postInit.
[profileNamespace getVariable ["A3ACC_CVDModeSaved", 0]] call FUNC(applyVars);

// Log the state this phase starts from, so a client RPT shows whether the
// setting callback ever ran and what the engine sees.
["preStart"] call FUNC(logState);
