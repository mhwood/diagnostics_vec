C------------------------------------------------------------------------------|
C                           diagnostics_ob_init_varia
C------------------------------------------------------------------------------|

#include "DIAGNOSTICS_OB_OPTIONS.h"

C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: DIAGNOSTICS_OB_INIT_VARIA

C !INTERFACE:
      SUBROUTINE DIAGNOSTICS_OB_INIT_VARIA( myThid )

C     !DESCRIPTION:
C     Initialize DIAGNOSTICS_OB variables

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DIAGNOSTICS_OB.h"

C     !INPUT/OUTPUT PARAMETERS:
C     myThid ::  my Thread Id number
      INTEGER myThid

C     !LOCAL VARIABLES:
C      INTEGER i,j,k,l, bi,bj

CEOP
C------------------------------------------------------------------------------|
CBOC

#ifdef ALLOW_DIAGNOSTICS_OB


      IF ( startTime.EQ.baseTime .AND. nIter0.EQ.0
     &                           .AND. pickupSuff.EQ.' ' ) THEN

C      ELSE
C--   restart from a pickup:
C         CALL DIAGNOSTICS_OB_READ_PICKUP( nIter0, myThid )

C--   end start-from-iter-zero if/else block
      ENDIF

#endif /* ALLOW_DIAGNOSTICS_OB */


      RETURN
      END
CEOC
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|