C CPP options file for DIAGNOSTICS_OB
C Use this file for selecting options within package "DIAGNOSTICS_OB"

#ifndef DIAGNOSTICS_OB_OPTIONS_H
#define DIAGNOSTICS_OB_OPTIONS_H
#include "PACKAGES_CONFIG.h"
#include "CPP_OPTIONS.h"

#ifdef ALLOW_DIAGNOSTICS_OB
C Place CPP define/undef flag here

C to reduce memory storage, disable unused array with those CPP flags :
#define DIAGNOSTICS_OB_3D_STATE
#define DIAGNOSTICS_OB_2D_STATE
#define DIAGNOSTICS_SURF_STATE
#define DIAGNOSTICS_OB_TENDENCY

#undef DIAGOB_SPECIAL_COMPILE_OPTION1
#define DIAGOB_SPECIAL_COMPILE_OPTION2

#endif /* ALLOW_DIAGNOSTICS_OB */
#endif /* DIAGNOSTICS_OB_OPTIONS_H */

CEH3 ;;; Local Variables: ***
CEH3 ;;; mode:fortran ***
CEH3 ;;; End: ***
