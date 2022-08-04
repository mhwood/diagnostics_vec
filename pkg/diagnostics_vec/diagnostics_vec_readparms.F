C----&------------------------------------------------------------------xxxxxxx|
C                           diagnostics_vec_readparms
C----&------------------------------------------------------------------xxxxxxx|
C Contributors: Michael Wood, Ian Fenty, April Shin

#include "DIAGNOSTICS_VEC_OPTIONS.h"

C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: DIAGNOSTICS_VEC_READPARMS

C !INTERFACE:
      SUBROUTINE DIAGNOSTICS_VEC_READPARMS( myThid )

C     !DESCRIPTION:
C     Initialize DIAGNOSTICS_VEC parameters and constants.

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "DIAGNOSTICS_VEC.h"

C     !INPUT PARAMETERS:
      INTEGER myThid

C     !LOCAL VARIABLES:
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER iUnit
      INTEGER i,j, vec_count
      INTEGER sf
      INTEGER, PARAMETER :: debug = 0

CEOP
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOC

C     /==================================================================\
C     | Variable Definitions by Source                                   |
C     |==================================================================|
C     | LOCAL:                                                           |
C     | - msgBuf     :: Informational/error message buffer               |
C     | - iUnit      :: Work variable for IO unit number                 |
C     | - i,j        :: Indices used in variable definition loops        |
C     | - undefRL  :: Undefined number to check if parameters were given |
C     |                                                                  |
C     | Defined by user in data.diagnostics_vec:                         |
C     | - nml_avgPeriod :: averaging period (frequency) of output        |
C     | - nml_startTime :: start time for output                         |
C     | - nml_endTime :: end time for output                             |
C     | - nml_vecFiles :: filenames for the boundary masks               |
C     | - nml_sfFiles :: filenames for the surface masks                 |
C     | - nml_fields2D :: 2D field names for ocean state and             |
C     |                   flux variables                                 |
C     | - nml_fields3D :: 3D field names for ocean state and             |
C     |                   flux variables                                 |
C     | - nml_levels3D :: depths starting from surface for each 3D field |
C     |                   (chosen by user)                               |
C     | - nml_fieldsSF :: surface field names for ocean state and        |
C     |                   flux variables                                 |
C     | - nml_filePrec :: precision of output variables (32 or 64)       |
C     \==================================================================/

#ifdef ALLOW_DIAGNOSTICS_VEC

C----&------------------------------------------------------------------xxxxxxx|
C     Define the diagnostics_vec variables
C----&------------------------------------------------------------------xxxxxxx|
      
      _RL undefRL
      _RL nml_startTime
      _RL nml_endTime
      _RL nml_vec_avg_periods(nVEC_mask)
      _RL nml_sf_avg_periods(nSURF_mask)
      CHARACTER*30 nml_vecFiles(nVEC_mask)
      CHARACTER*30 nml_sfFiles(nSURF_mask)
      CHARACTER*8 nml_fields2D(MAX_NFLDS, nVEC_mask)
      CHARACTER*8 nml_fields3D(MAX_NFLDS, nVEC_mask)
      INTEGER nml_vec_iters_per_file(nVEC_mask)
      INTEGER nml_sf_iters_per_file(nSURF_mask)
      INTEGER nml_levels3D(MAX_NFLDS, nVEC_mask)
      CHARACTER*8 nml_fieldsSF(MAX_NFLDS, nSURF_mask)
      INTEGER nml_filePrec, nml_debugLevel

      NAMELIST / DIAG_VEC_INPUT_VARS /
     &     nml_startTime, nml_endTime,
     &     nml_vec_avg_periods, nml_sf_avg_periods,
     &     nml_vecFiles,
     &     nml_sfFiles,
     &     nml_vec_iters_per_file, nml_sf_iters_per_file,
     &     nml_fields2D,
     &     nml_fields3D, nml_levels3D,
     &     nml_fieldsSF,
     &     nml_filePrec
    

      if (debug .eq. 1) then
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "  BEGIN DIAGNOSTICS_VEC_READPARMS DEBUG "
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        endif

C----&------------------------------------------------------------------xxxxxxx|
C   Initialize local variables and variables from DIAG_VEC_INPUT_VARS NAMELIST
C   with default values
C----&------------------------------------------------------------------xxxxxxx|

      _BEGIN_MASTER(myThid)

      nml_startTime = startTime
      nml_endTime = endTime
      nml_filePrec = 64
      nml_debugLevel = 0

      DO j=1, nVEC_mask
        DO i=1, MAX_NFLDS
          nml_fields2D(i,j) = ' '
          nml_fields3D(i,j) = ' '
          nml_levels3D(i,j) = 0
        ENDDO
        nml_vecFiles(j) = ' '
        nml_vec_iters_per_file(j) = 0
        nml_vec_avg_periods(j) = deltaT
      ENDDO


      DO j=1, nVEC_mask
        DO i=1, MAX_NFLDS
          vec_flds2D(i,j) = ' '
          vec_flds3D(i,j) = ' '
          vec_levels3D(i,j) = 0
        ENDDO
        vec_fnames(j) = ' '
        vec_nFlds2D(j) = 0
        vec_nFlds3D(j) = 0
      ENDDO

C ----  Surface section is here

      DO j=1, nSURF_mask
        DO i=1, MAX_NFLDS
          nml_fieldsSF(i,j) = ' '
        ENDDO
        nml_sfFiles(j) = ' '
      ENDDO

      DO j=1, nSURF_mask
        DO i=1, MAX_NFLDS
          sf_flds(i,j) = ' '
        ENDDO
        sf_fnames(j) = ' '
        nml_sf_iters_per_file(j) = 0
        nml_sf_avg_periods(j) = deltaT
      ENDDO

C----&------------------------------------------------------------------xxxxxxx|
C     Write out status to main output and fill in the parameters
C----&------------------------------------------------------------------xxxxxxx|

      WRITE(msgBuf,'(A)')
     &      'DIAGNOSTICS_VEC_READPARMS: opening data.diagnostics_vec'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT , 1)
      CALL OPEN_COPY_DATA_FILE(
     I             'data.diagnostics_vec', 'DIAGNOSTICS_VEC_READPARMS',
     O              iUnit,
     I              myThid )

C     Read parameters from open data file
      WRITE(msgBuf,'(2A)') 'S/R DIAGNOSTICS_READPARMS,',
     &     ' read namelist "DIAG_VEC_INPUT_VARS": start'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT , 1)
      READ  (UNIT=iUnit,NML=DIAG_VEC_INPUT_VARS)
      WRITE(msgBuf,'(2A)') 'S/R DIAGNOSTICS_READPARMS,',
     &     ' read namelist "DIAG_VEC_INPUT_VARS": OK'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT , 1)

C     Close the open data file
#ifdef SINGLE_DISK_IO
      CLOSE(iUnit)
#else
      CLOSE(iUnit,STATUS='DELETE')
#endif /* SINGLE_DISK_IO */

C----&------------------------------------------------------------------xxxxxxx|
C     Fill DIAGNOSTICS_VEC.h COMMON Block with information provided by
C     data.diagnostics_vec
C----&------------------------------------------------------------------xxxxxxx|

      DO vec_count=1, nVEC_mask
        vec_fnames(vec_count) = nml_vecFiles(vec_count)
        vec_iters_per_file(vec_count) = 
     &   nml_vec_iters_per_file(vec_count)
        vec_avg_periods(vec_count) = nml_vec_avg_periods(vec_count)

        DO i=1, MAX_NFLDS
          vec_flds2D(i,vec_count) = nml_fields2D(i,vec_count)
          if (nml_fields2D(i,vec_count) .ne. ' ') then
            vec_nFlds2D(vec_count) = vec_nFlds2D(vec_count) + 1
          endif
          vec_flds3D(i,vec_count) = nml_fields3D(i,vec_count)
          if (nml_fields3D(i,vec_count) .ne. ' ') then
            vec_nFlds3D(vec_count) = vec_nFlds3D(vec_count) + 1
          endif
          vec_levels3D(i,vec_count) = nml_levels3D(i,vec_count)
        ENDDO
      ENDDO

      DO sf=1, nSURF_mask
        sf_fnames(sf) = nml_sfFiles(sf)
        sf_iters_per_file(sf) = nml_sf_iters_per_file(sf)
        sf_avg_periods(sf) = nml_sf_avg_periods(sf)

        DO i=1, MAX_NFLDS
          sf_flds(i,sf) = nml_fieldsSF(i,sf)
          if (nml_fieldsSF(i,sf) .ne. ' ') then
            sf_nFlds(sf) = sf_nFlds(sf) + 1
          endif
        ENDDO
      ENDDO

      startTime_vec = nml_startTime
      endTime_vec = nml_endTime
      vec_filePrec = nml_filePrec
      vec_debugLevel = nml_debugLevel

C----&------------------------------------------------------------------xxxxxxx|
C     Wrap up the code
C----&------------------------------------------------------------------xxxxxxx|

      _END_MASTER(myThid)

C--   Everyone must wait for the parameters to be loaded
      _BARRIER

#endif /* ALLOW_DIAGNOSTICS_VEC */

      if (debug .eq. 1) then
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "  END DIAGNOSTICS_VEC_READPARMS DEBUG "
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        endif

      RETURN



      END
CEOC
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|