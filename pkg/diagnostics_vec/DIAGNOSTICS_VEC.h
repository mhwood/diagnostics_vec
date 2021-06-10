C------------------------------------------------------------------------------|
C                           DIAGNOSTICS_VEC.h
C------------------------------------------------------------------------------|
C Contributors: Michael Wood, Ian Fenty, April Shin

#ifdef ALLOW_DIAGNOSTICS_VEC

#include "DIAGNOSTICS_VEC_SIZE.h"

C------------------------------------------------------------------------------|
C     Define the global diagnostics_vec variables
C------------------------------------------------------------------------------|

      INTEGER, PARAMETER :: MAX_NFLDS = 20  

C     These are the name of the fields requested for output
      CHARACTER*8 vec_flds2D(MAX_NFLDS, nVEC_mask)
      CHARACTER*8 vec_flds3D(MAX_NFLDS, nVEC_mask)
      CHARACTER*8 sf_flds(MAX_NFLDS, nSURF_mask)

C     These are the file names of the input masks
      CHARACTER*30 vec_fnames(nVEC_mask)
      CHARACTER*30 sf_fnames(nSURF_mask)

C     This is the number of fields for each mask
      INTEGER vec_levels3D(MAX_NFLDS, nVEC_mask)
      INTEGER vec_nFlds2D(nVEC_mask)
      INTEGER vec_nFlds3D(nVEC_mask)
      INTEGER sf_nFlds(nSURF_mask)

C     These tags keep labels for MPI SEND/RECV   
      INTEGER vec_tags(nVEC_mask, 2, MAX_NFLDS)
      INTEGER sf_tags(nSURF_mask, 2, MAX_NFLDS)

C     These are some i/o parameters
      LOGICAL combineMaskTimeLevels
      INTEGER vec_filePrec
      INTEGER vec_debugLevel

C     These are times controlling when the averaging is done
      _RL avgPeriod_vec
      _RL startTime_vec
      _RL endTime_vec
      _RL nTimeSteps_vec
      _RL time_passed
      INTEGER time_level

C     This is where the input masks are stored after they are read in
      _RL vec_subMask(nVEC_mask, 1-Olx:sNx+Olx,1-Oly:sNy+Oly,nSx,nSy)
      _RL sf_subMask(nSURF_mask,1-Olx:sNx+Olx,1-Oly:sNy+Oly,nSx,nSy)

C     These store the rows/cols of valid mask locations within the masks
      INTEGER vec_sub_local_ij(nVEC_mask, 4, sNx + sNy)
      INTEGER sf_sub_local_ij(nSURF_mask, 4, sNx * sNy)

C     These arrays map the above counters to ordered points in the mask
      INTEGER vec_mask_index_list(nVEC_mask, nPx*nPy, sNx + sNy)
      INTEGER sf_mask_index_list(nSURF_mask, nPx*nPy, sNx * sNy)

C     These store a list of mask points that each proc has
      INTEGER vec_numPnts_allproc(nVEC_mask, nPx*nPy)
      INTEGER sf_numPnts_allproc(nSURF_mask, nPx*nPy)

C     These arrays store data at each model time step
      _RL subFieldOnMask_2D(nVEC_mask,MAX_NFLDS, sNx + sNy)
      _RL subFieldOnMask_3D(nVEC_mask,MAX_NFLDS, sNx + sNy, Nr)
      _RL subFieldOnMask_2Davg(nVEC_mask,MAX_NFLDS, sNx + sNy)
      _RL subFieldOnMask_3Davg(nVEC_mask,MAX_NFLDS, sNx + sNy, Nr)
      _RL subFieldOnMask_SF(nSURF_mask,MAX_NFLDS, sNx * sNy)
      _RL subFieldOnMask_SFavg(nSURF_mask,MAX_NFLDS, sNx * sNy)

C     This is a buffer where the main output on the mask is stored
C     Used in diagnostics_vec_output
      REAL*8 global_vec2D((sNy+sNx)*(nPx*nPy))
      REAL*8 global_vec3D((sNy+sNx)*(nPx*nPy), Nr)
      REAL*8 global_SF((sNy*sNx)*(nPx*nPy))



C------------------------------------------------------------------------------|
C     Create COMMON blocks for the diagnostics_vec variables
C------------------------------------------------------------------------------|

      COMMON / DIAG_VEC_VARS_R /
     &     vec_subMask, sf_subMask,
     &     nTimeSteps_vec, time_passed,
     &     startTime_vec, endTime_vec, avgPeriod_vec,
     &     global_vec2D, global_vec3D, global_SF,
     &     subFieldOnMask_2D, subFieldOnMask_2Davg,
     &     subFieldOnMask_3D, subFieldOnMask_3Davg,
     &     subFieldOnMask_SF, subFieldOnMask_SFavg

      COMMON / DIAG_VEC_VARS_I /
     &     vec_levels3D, 
     &     vec_sub_local_ij, sf_sub_local_ij,
     &     vec_mask_index_list, sf_mask_index_list,
     &     vec_numPnts_allproc, sf_numPnts_allproc,
     &     vec_nFlds2D, vec_nFlds3D, sf_nFlds, 
     &     vec_tags,sf_tags, 
     &     vec_filePrec, time_level,
     &     vec_debugLevel

      COMMON / DIAG_VEC_VARS_C /
     &     vec_flds2D, vec_flds3D, vec_fnames, sf_flds, sf_fnames,
     &     combineMaskTimeLevels

#endif /* ALLOW_DIAGNOSTICS_VEC */
