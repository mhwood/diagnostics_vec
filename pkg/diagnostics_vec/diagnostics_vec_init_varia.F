C------------------------------------------------------------------------------|
C                           diagnostics_vec_init_varia
C------------------------------------------------------------------------------|
C Contributors: Michael Wood, Ian Fenty, April Shin

#include "DIAGNOSTICS_VEC_OPTIONS.h"

C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: DIAGNOSTICS_VEC_INIT_VARIA

C !INTERFACE:
      SUBROUTINE DIAGNOSTICS_VEC_INIT_VARIA( myThid )

C     !DESCRIPTION:
C     Initialize DIAGNOSTICS_VEC variables

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DIAGNOSTICS_VEC.h"

C     !INPUT/OUTPUT PARAMETERS:
C     myThid ::  my Thread Id number
      INTEGER myThid
      

C     !LOCAL VARIABLES:
C      INTEGER i,j,k,l, bi,bj
      INTEGER, PARAMETER :: debug = 0
      CHARACTER*(MAX_LEN_MBUF) msgBuf

CEOP
C------------------------------------------------------------------------------|
CBOC

#ifdef ALLOW_DIAGNOSTICS_VEC

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  END DIAGNOSTICS_VEC_INIT_VARIA DEBUG "
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif


C     Currently nothing to be done in init varia


      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  END DIAGNOSTICS_VEC_INIT_VARIA DEBUG "
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

      RETURN

#endif /* ALLOW_DIAGNOSTICS_VEC */
      
      END
CEOC
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|