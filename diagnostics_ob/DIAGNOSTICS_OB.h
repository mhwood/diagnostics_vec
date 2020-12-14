C------------------------------------------------------------------------------|
C                           DIAGNOSTICS_OB.h
C------------------------------------------------------------------------------|

#ifdef ALLOW_DIAGNOSTICS_OB

C     /==================================================================\
C     | Global variable definitions for diagnostics_ob                   |
C     |==================================================================|
C     |                                                                  |
C     | Default mask and field sizes                                     |
C     | - nOB_mask :: Number of open boundaries. Default is set to 12    |
C     | - nSF_mask :: Number of surface masks. Default is set to 3       |
C     | - MAX_NFLDS :: Int value for assumed maximum number of fields    |
C     |                                                                  |
C     | Variables derived from user input in data.diagnostics_ob:        |
C     | - ob_fnames :: Char array of filenames for open boundary mask    |
C     |                files.                                            |
C     | - ob_flds2D :: Char array of names of 2D fields for each open    |
C     |                boundary mask.                                    |
C     | - ob_flds3D :: Char array of names of 3D fields for each open    |
C     |                boundary mask.                                    |
C     | - ob_levels3D :: Int array of depths of 3D fields for each open  |
C     |                  boundary mask.                                  |
C     | - ob_nFlds2D :: Int array of number of 2D fields in each open    |
C     |                 boundary mask.                                   |
C     | - ob_nFlds3D :: Int array of number of 3D fields in each open    |
C     |                 boundary mask.                                   |
C     | - ob_tags :: Int array of unique tags assigned to every field    |
C     |              in every boundary mask.                             |
C     | - sf_fnames :: Char array of filenames for surface mask          |
C     |                files.                                            |
C     | - sf_flds :: Char array of names of surface fields for each      |
C     |                surface mask.                                     |
C     | - sf_nFlds :: Int array of number of surface fields in each      |
C     |                 surface mask.                                    |
C     | - sf_tags :: Int array of unique tags assigned to every field    |
C     |                in every surface mask.                            |
C     | - combineMaskTimeLevels :: Logical for whether all time levels   |
C     |                            should be written to a single bin     |
C     |                            file or to separate bin files         |
C     | - ob_filePrec :: file precision for binary file output           |
C     | - avgPeriod_ob :: averaging period                               |
C     | - startTime_ob :: start time for writing output                  |
C     | - endTime_ob :: end time for writing output                      |
C     |                                                                  |
C     |                                                                  |
C     | Variables containing information for all open boundary masks:    |
C     | - ob_subMask :: _RL array for portion of open boundary global    |
C     |                 mask assigned to process                         |
C     | - ob_sub_local_ij :: _RL array for i,j indices of open boundary  |
C     |                      points wrt ob_subMask domain                |
C     | - ob_sub_glo_indices_allproc :: _RL array for global indices of  |   
C     |                                 open boundary points for each    |
C     |                                 process                          |
C     | - ob_numPnts_allproc :: _RL array for number of open boundary    |
C     |                        points in each process                    |
C     | - subFieldOnMask_2D :: _RL array for 2D field values on open     |
C     |                        boundary points                           |
C     | - subFieldOnMask_3D :: _RL array for 3D field values on open     |
C     |                        boundary points                           |
C     | - subFieldOnMask_2Davg :: _RL array for time-averaged 2D field   |
C     |                           values on open boundary points         |
C     | - subFieldOnMask_3Davg :: _RL array for time-averaged 3D field   |
C     |                           values on open boundary points         |
C     | - ob_lookup_table :: _RL array containing all open boundary      |
C     |                       global masks                               |
C     | - global_ob_mask :: _RL array containing all open boundary masks |
C     |                                                                  |
C     |                                                                  |
C     | Variables containing information for all surface masks:          |
C     | - sf_subMask :: _RL array for portion of surface global          |
C     |                   mask assigned to process                       |
C     | - sf_sub_local_ij :: _RL array for i,j indices of surface        |
C     |                             points wrt surf_subMask domain       |
C     | - sf_sub_glo_indices_allproc :: _RL array for global indices     |   
C     |                                   of surface points for each     |
C     |                                   process                        |
C     | - sf_numPnts_allproc :: _RL array for number of surface          |
C     |                           points in each process                 |
C     | - subFieldOnMask_SF :: _RL array for field values on surface     |
C     |                          points                                  |
C     | - subFieldOnMask_SFavg :: _RL array for time-averaged field      |
C     |                             values on surface points             |
C     | - sf_lookup_table :: _RL array containing all surface global     |
C     |                        masks                                     |
C     | - global_sf_mask :: _RL array containing all surface masks       |
C     |                                                                  |
C     |                                                                  |
C     | - Other variables for output:                                    |
C     | - global_ob2D :: _RL array for final output of combined          |
C     |                  time-averaged 2D field values on OB points      |
C     | - global_ob3D :: _RL array for final output of combined          |
C     |                  time-averaged 3D field values on OB points      |
C     | - global_SF :: _RL array for final output of combined            |
C     |                  time-averaged field values on surface points    |
C     | - nTimeSteps_ob :: Integer value for number of time steps taken  |
C     |                    within averaging period                       |
C     | - time_passed :: total time passed                               |
C     | - time_level :: number of time levels passed i.e. number of      |
C     |                 averaging period passed                          |
C     \==================================================================/
C
C------------------------------------------------------------------------------|
C     Define the global diagnostics_ob variables
C------------------------------------------------------------------------------|

      INTEGER, PARAMETER :: nOB_mask = 4
      INTEGER, PARAMETER :: nSF_mask = 1
      INTEGER, PARAMETER :: MAX_NFLDS = 20  

      CHARACTER*8 ob_flds2D(MAX_NFLDS, nOB_mask)
      CHARACTER*8 ob_flds3D(MAX_NFLDS, nOB_mask)
      CHARACTER*30 ob_fnames(nOB_mask)
      INTEGER ob_levels3D(MAX_NFLDS, nOB_mask)
      INTEGER ob_nFlds2D(nOB_mask)
      INTEGER ob_nFlds3D(nOB_mask)
      INTEGER ob_tags(nOB_mask, 2, MAX_NFLDS)

      CHARACTER*8 sf_flds(MAX_NFLDS, nSF_mask)
      CHARACTER*30 sf_fnames(nSF_mask)
      INTEGER sf_nFlds(nSF_mask)
      INTEGER sf_tags(nSF_mask, 2, MAX_NFLDS)

      LOGICAL combineMaskTimeLevels
      INTEGER ob_filePrec
      _RL avgPeriod_ob
      _RL startTime_ob
      _RL endTime_ob

      _RL ob_subMask(nOB_mask,1-Olx:sNx+Olx,1-Oly:sNy+Oly,nSx,nSy)
      INTEGER ob_sub_local_ij(nOB_mask, 2, sNx + sNy)
      INTEGER ob_sub_glo_indices_allproc(nOB_mask, nPx*nPy, sNx + sNy)
      INTEGER ob_numPnts_allproc(nOB_mask, nPx*nPy)
      _RL subFieldOnMask_2D(nOB_mask,MAX_NFLDS, sNx + sNy)
      _RL subFieldOnMask_3D(nOB_mask,MAX_NFLDS, sNx + sNy, Nr)
      _RL subFieldOnMask_2Davg(nOB_mask,MAX_NFLDS, sNx + sNy)
      _RL subFieldOnMask_3Davg(nOB_mask,MAX_NFLDS, sNx + sNy, Nr)
      INTEGER ob_lookup_table(nOB_mask, Ny*Nx)
      _RL global_ob_mask(nOB_mask,Nx, Ny,nSx,nSy)

      _RL sf_subMask(nSF_mask,1-Olx:sNx+Olx,1-Oly:sNy+Oly,nSx,nSy)
      INTEGER sf_sub_local_ij(nSF_mask, 2, sNx*sNy)
      INTEGER sf_sub_glo_indices_allproc(nSF_mask, nPx*nPy, sNx*sNy)
      INTEGER sf_numPnts_allproc(nSF_mask, nPx*nPy)
      _RL subFieldOnMask_SF(nSF_mask,MAX_NFLDS, sNx*sNy)
      _RL subFieldOnMask_SFavg(nSF_mask,MAX_NFLDS, sNx*sNy)
      INTEGER sf_lookup_table(nSF_mask, Ny*Nx)
      _RL global_sf_mask(nSF_mask,Nx, Ny,nSx,nSy)

      REAL*8 global_ob2D((sNy+sNx)*(nPx*nPy))
      REAL*8 global_ob3D((sNy+sNx)*(nPx*nPy), Nr)
      REAL*8 global_SF((sNy*sNx)*(nPx*nPy))
      _RL nTimeSteps_ob
      _RL time_passed
      INTEGER time_level

C------------------------------------------------------------------------------|
C     Create COMMON blocks for the diagnostics_ob variables
C------------------------------------------------------------------------------|

      COMMON / DIAG_OB_VARS_R /
     &     ob_subMask, sf_subMask,
     &     global_ob_mask, global_sf_mask,
     &     nTimeSteps_ob, time_passed,
     &     startTime_ob, endTime_ob, avgPeriod_ob,
     &     global_ob2D, global_ob3D, global_SF,
     &     subFieldOnMask_2D, subFieldOnMask_2Davg,
     &     subFieldOnMask_3D, subFieldOnMask_3Davg,
     &     subFieldOnMask_SF, subFieldOnMask_SFavg

      COMMON / DIAG_OB_VARS_I /
     &     ob_lookup_table, ob_sub_local_ij,
     &     ob_sub_glo_indices_allproc,
     &     ob_numPnts_allproc, 
     &     ob_levels3D, ob_nFlds2D, ob_nFlds3D, ob_tags,
     &     sf_lookup_table, sf_sub_local_ij,
     &     sf_sub_glo_indices_allproc,
     &     sf_numPnts_allproc,
     &     sf_nFlds, sf_tags, 
     &     ob_filePrec, time_level

      COMMON / DIAG_OB_VARS_C /
     &     ob_flds2D, ob_flds3D, ob_fnames, sf_flds, sf_fnames,
     &     combineMaskTimeLevels

#endif /* ALLOW_DIAGNOSTICS_OB */
