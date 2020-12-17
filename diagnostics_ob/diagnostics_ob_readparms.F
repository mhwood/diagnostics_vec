C----&------------------------------------------------------------------xxxxxxx|
C                           diagnostics_ob_readparms
C----&------------------------------------------------------------------xxxxxxx|

#include "DIAGNOSTICS_OB_OPTIONS.h"

C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: DIAGNOSTICS_OB_READPARMS

C !INTERFACE:
      SUBROUTINE DIAGNOSTICS_OB_READPARMS( myThid )

C     !DESCRIPTION:
C     Initialize DIAGNOSTICS_OB variables and constants.

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "DIAGNOSTICS_OB.h"

C     !INPUT PARAMETERS:
      INTEGER myThid

C     !LOCAL VARIABLES:
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER iUnit
      INTEGER i,j, ob
      INTEGER sf
      LOGICAL check_pkg

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
C     | - check_pkg  :: Boolean used to catch package-specific requests  |
C     | - undefRL  :: Undefined number to check if parameters were given |
C     |                                                                  |
C     | Defined by user in data.diagnostics_ob:                          |
C     | - nml_avgPeriod :: averaging period (frequency) of output        |
C     | - nml_startTime :: start time for output                         |
C     | - nml_endTime :: end time for output                             |
C     | - nml_obFiles :: filenames for the boundary masks          |
C     | - nml_sfFiles :: filenames for the surface masks            |
C     | - nml_fields2D :: 2D field names for ocean state and             |
C     |                   flux variables                                 |
C     | - nml_fields3D :: 3D field names for ocean state and             |
C     |                   flux variables                                 |
C     | - nml_levels3D :: depths starting from surface for each 3D field |
C     |                   (chosen by user)                               |
C     | - nml_fieldsSF :: surface field names for ocean state and      |
C     |                   flux variables                                 |
C     | - nml_filePrec :: precision of output variables (32 or 64)       |
C     | - nml_combMaskTimeLevels :: Logical for either writing all time  |
C     |                             levels to binary file or write in    |
C     |                             separate binary files                |
C     \==================================================================/

#ifdef ALLOW_DIAGNOSTICS_OB

C----&------------------------------------------------------------------xxxxxxx|
C     Define the diagnostics_ob variables
C----&------------------------------------------------------------------xxxxxxx|
      
      _RL undefRL
      _RL nml_avgPeriod
      _RL nml_startTime
      _RL nml_endTime
      CHARACTER*30 nml_obFiles(nOB_mask)
      CHARACTER*30 nml_sfFiles(nSF_mask)
      CHARACTER*8 nml_fields2D(MAX_NFLDS, nOB_mask)
      CHARACTER*8 nml_fields3D(MAX_NFLDS, nOB_mask)
      INTEGER nml_levels3D(MAX_NFLDS, nOB_mask)
      CHARACTER*8 nml_fieldsSF(MAX_NFLDS, nSF_mask)
      INTEGER nml_filePrec
      LOGICAL nml_combMaskTimeLevels

      NAMELIST / DIAG_OB_INPUT_VARS /
     &     nml_avgPeriod, nml_startTime, nml_endTime,
     &     nml_obFiles,
     &     nml_sfFiles,
     &     nml_fields2D,
     &     nml_fields3D, nml_levels3D,
     &     nml_fieldsSF,
     &     nml_filePrec, nml_combMaskTimeLevels
    

C----&------------------------------------------------------------------xxxxxxx|
C     Provide a weak warning if data.diagnostics_ob is found but
C     useDiagnostics_ob is not activated in data.pkg
C----&------------------------------------------------------------------xxxxxxx|

      IF ( .NOT.useDiagnostics_ob ) THEN
         CALL PACKAGES_UNUSED_MSG( 'useDiagnostics_ob', ' ', ' ' )
        RETURN
      ENDIF

C----&------------------------------------------------------------------xxxxxxx|
C   Initialize local variables and variables from DIAG_OB_INPUT_VARS NAMELIST
C   with default values
C----&------------------------------------------------------------------xxxxxxx|

      _BEGIN_MASTER(myThid)

      nml_startTime = endTime
      nml_endTime = startTime
      nml_filePrec = 64
      nml_combMaskTimeLevels = .TRUE.

      DO j=1, nOB_mask
        DO i=1, MAX_NFLDS
          nml_fields2D(i,j) = ' '
          nml_fields3D(i,j) = ' '
          nml_levels3D(i,j) = 0
        ENDDO
        nml_obFiles(j) = ' '
      ENDDO


      DO j=1, nOB_mask
        DO i=1, MAX_NFLDS
          ob_flds2D(i,j) = ' '
          ob_flds3D(i,j) = ' '
          ob_levels3D(i,j) = 0
        ENDDO
        ob_fnames(j) = ' '
        ob_nFlds2D(j) = 0
        ob_nFlds3D(j) = 0
      ENDDO

C ----  Surface section is here

      DO j=1, nSF_mask
        DO i=1, MAX_NFLDS
          nml_fieldsSF(i,j) = ' '
        ENDDO
        nml_sfFiles(j) = ' '
      ENDDO


      DO j=1, nSF_mask
        DO i=1, MAX_NFLDS
          sf_flds(i,j) = ' '
        ENDDO
        sf_fnames(j) = ' '
      ENDDO

C----&------------------------------------------------------------------xxxxxxx|
C     Write out status to main output and fill in the parameters
C----&------------------------------------------------------------------xxxxxxx|

      WRITE(msgBuf,'(A)')
     &      'DIAGNOSTICS_OB_READPARMS: opening data.diagnostics_ob'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT , 1)
      CALL OPEN_COPY_DATA_FILE(
     I             'data.diagnostics_ob', 'DIAGNOSTICS_OB_READPARMS',
     O              iUnit,
     I              myThid )

C     Read parameters from open data file
      WRITE(msgBuf,'(2A)') 'S/R DIAGNOSTICS_READPARMS,',
     &     ' read namelist "DIAG_OB_INPUT_VARS": start'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT , 1)
      READ  (UNIT=iUnit,NML=DIAG_OB_INPUT_VARS)
      WRITE(msgBuf,'(2A)') 'S/R DIAGNOSTICS_READPARMS,',
     &     ' read namelist "DIAG_OB_INPUT_VARS": OK'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT , 1)

C     Close the open data file
#ifdef SINGLE_DISK_IO
      CLOSE(iUnit)
#else
      CLOSE(iUnit,STATUS='DELETE')
#endif /* SINGLE_DISK_IO */

C----&------------------------------------------------------------------xxxxxxx|
C     Fill DIAGNOSTICS_OB.h COMMON Block with information provided by
C     data.diagnostics_ob
C----&------------------------------------------------------------------xxxxxxx|

      DO ob=1, nOB_mask
        ob_fnames(ob) = nml_obFiles(ob)

        DO i=1, MAX_NFLDS
          ob_flds2D(i,ob) = nml_fields2D(i,ob)
          if (nml_fields2D(i,ob) .ne. ' ') then
            ob_nFlds2D(ob) = ob_nFlds2D(ob) + 1
          endif
          ob_flds3D(i,ob) = nml_fields3D(i,ob)
          if (nml_fields3D(i,ob) .ne. ' ') then
            ob_nFlds3D(ob) = ob_nFlds3D(ob) + 1
          endif
          ob_levels3D(i,ob) = nml_levels3D(i,ob)
        ENDDO
      ENDDO

      DO sf=1, nSF_mask
        sf_fnames(sf) = nml_sfFiles(sf)

        DO i=1, MAX_NFLDS
          sf_flds(i,sf) = nml_fieldsSF(i,sf)
          if (nml_fieldsSF(i,sf) .ne. ' ') then
            sf_nFlds(sf) = sf_nFlds(sf) + 1
          endif
        ENDDO
      ENDDO


C----&------------------------------------------------------------------xxxxxxx|
C     If no times are provided, then fill them in with info from the model
C     time stepping regmine. Ditto for file precision and output style
C----&------------------------------------------------------------------xxxxxxx|

C     This is temporary for now, assuming all of the information is present:
      avgPeriod_ob = nml_avgPeriod
      startTime_ob = nml_startTime
      endTime_ob = nml_endTime
      ob_filePrec = nml_filePrec
      combineMaskTimeLevels = nml_combMaskTimeLevels


C----&------------------------------------------------------------------xxxxxxx|
C     Wrap up the code
C----&------------------------------------------------------------------xxxxxxx|

      _END_MASTER(myThid)

C--   Everyone else must wait for the parameters to be loaded
      _BARRIER

#endif /* ALLOW_DIAGNOSTICS_OB */

      RETURN
      END
CEOC
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|