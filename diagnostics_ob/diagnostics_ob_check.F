C----&------------------------------------------------------------------xxxxxxx|
C                           diagnostics_ob_check
C----&------------------------------------------------------------------xxxxxxx|

#include "DIAGNOSTICS_OB_OPTIONS.h"

C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: DIAGNOSTICS_OB_CHECK

C !INTERFACE:
      SUBROUTINE DIAGNOSTICS_OB_CHECK( myThid )

C     !DESCRIPTION:
C     Check dependances with other packages

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "DIAGNOSTICS_OB.h"

C     !INPUT PARAMETERS:
C     myThid   :: my Thread Id number
      INTEGER myThid

C     !LOCAL VARIABLES:
C     msgBuf   :: Informational/error message buffer
      CHARACTER*(MAX_LEN_MBUF) msgBuf
CEOP
C----&------------------------------------------------------------------xxxxxxx|
CBOC

#ifdef ALLOW_DIAGNOSTICS_OB


      _BEGIN_MASTER(myThid)

       WRITE(msgBuf,'(A)')
     &      'DIAGNOSTICS_OB_CHECK: #define DIAGNOSTICS_OB'
       CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT , 1)


      _END_MASTER(myThid)

#endif /* ALLOW_DIAGNOSTICS_OB */

      RETURN
      END
CEOC
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|