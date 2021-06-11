C----&------------------------------------------------------------------xxxxxxx|
C                           diagnostics_vec_check
C----&------------------------------------------------------------------xxxxxxx|
C Contributors: Michael Wood, Ian Fenty, April Shin

#include "DIAGNOSTICS_VEC_OPTIONS.h"

C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: DIAGNOSTICS_VEC_CHECK

C !INTERFACE:
      SUBROUTINE DIAGNOSTICS_VEC_CHECK( myThid )

C     !DESCRIPTION:
C     Check dependances with other packages

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "DIAGNOSTICS_VEC.h"

C     !INPUT PARAMETERS:
C     myThid   :: my Thread Id number
      INTEGER myThid

C     !LOCAL VARIABLES:
C     msgBuf   :: Informational/error message buffer
      INTEGER errCount
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER, PARAMETER :: debug = 0
CEOP
C----&------------------------------------------------------------------xxxxxxx|
CBOC

#ifdef ALLOW_DIAGNOSTICS_VEC

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  BEGIN DIAGNOSTICS_VEC_INIT_FIXED DEBUG "
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif


      _BEGIN_MASTER(myThid)

       WRITE(msgBuf,'(A)')
     &      'DIAGNOSTICS_VEC_CHECK: #define DIAGNOSTICS_VEC'
       CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT , 1)

      errCount = 0

C ---  The number of masks is less than 100
C      This requirement arises due to the labeling of tags in 
C      MPI SEND/RECV calls in diagnostics_vec_init_fixed    
      IF (nVEC_mask.GE.100) THEN
            errCount = errCount +1
            WRITE(msgBuf,'(A)')
     &      'The maximum number of masks is 99'
            CALL PRINT_ERROR( msgBuf, myThid )
            CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT , 1)
      ENDIF    

C ---  If there were any errors, kill the run
      IF ( errCount.GE.1 ) THEN
            WRITE(msgBuf,'(A,I5,A)')
     &     'DIAGNOSTICS_VEC_CHECK: detected', errCount,' fatal error(s)'
            CALL PRINT_ERROR( msgBuf, myThid )
            CALL ALL_PROC_DIE( 0 )
            STOP 'ABNORMAL END: S/R DIAGNOSTICS_VEC_CHECK'
      ENDIF

      _END_MASTER(myThid)

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  BEGIN DIAGNOSTICS_VEC_INIT_FIXED DEBUG "
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

#endif /* ALLOW_DIAGNOSTICS_VEC */

      RETURN
      END
CEOC
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|