C CPP options file for DIAGNOSTICS_VEC
C Use this file for selecting options within package "DIAGNOSTICS_VEC"

#ifndef DIAGNOSTICS_VEC_OPTIONS_H
#define DIAGNOSTICS_VEC_OPTIONS_H
#include "PACKAGES_CONFIG.h"
#include "CPP_OPTIONS.h"

#ifdef ALLOW_DIAGNOSTICS_VEC

C to reduce memory storage, disable unused array with these CPP flags:
#define DIAGNOSTICS_VEC_3D_STATE
#define DIAGNOSTICS_VEC_2D_STATE
#define DIAGNOSTICS_SF_STATE

#endif /* ALLOW_DIAGNOSTICS_VEC */
#endif /* DIAGNOSTICS_VEC_OPTIONS_H */

CEH3 ;;; Local Variables: ***
CEH3 ;;; mode:fortran ***
CEH3 ;;; End: ***
