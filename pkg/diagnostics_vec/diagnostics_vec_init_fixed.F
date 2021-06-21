C----&------------------------------------------------------------------xxxxxxx|
C                         diagnostics_vec_init_fixed
C----&------------------------------------------------------------------xxxxxxx|
C Contributors: Michael Wood, Ian Fenty, April Shin

#include "DIAGNOSTICS_VEC_OPTIONS.h"

C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: DIAGNOSTICS_VEC_INIT_FIXED

C !INTERFACE:
      SUBROUTINE DIAGNOSTICS_VEC_INIT_FIXED( myThid )

C     !DESCRIPTION:
C     Initialize DIAGNOSTICS_VEC variables that are kept fixed during the run.

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
C#ifdef ALLOW_USE_MPI
#include "EEPARAMS.h"
#include "EESUPPORT.h"
C#endif
#include "PARAMS.h"
#include "DIAGNOSTICS_VEC.h"

C     !INPUT/OUTPUT PARAMETERS:
C     myThid ::  my Thread Id number
      INTEGER myThid

C     !LOCAL VARIABLES:
C     i, j, k, l, bi, bj, fld :: iterables
      INTEGER xSize, ySize
      INTEGER i, j, k, l, bi, bj, fld, counter, pid
      INTEGER vec_id, sf_id
      INTEGER, PARAMETER :: debug = 0
      CHARACTER*(MAX_LEN_MBUF) msgBuf
#ifndef ALLOW_USE_MPI
      INTEGER, PARAMETER :: mpiMyId = 0
#endif
      
      
CEOP
C----&------------------------------------------------------------------xxxxxxx|

C----&------------------------------------------------------------------xxxxxxx|
C     Initialize diagnostics_vec COMMON block variables:
C----&------------------------------------------------------------------xxxxxxx|


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

C     This is in the initialization of the vector variables

      DO i=1, (sNy+sNx)*(nPx*nPy)*(nSx*nSy)
        global_vec2D(i) = 0.0
        DO k=1, Nr
          global_vec3D(i,k) = 0.0
        ENDDO
      ENDDO

      DO vec_id=1, nVEC_mask

        DO pid=1, nPx*nPy
          vec_numPnts_allproc(vec_id,pid) = 0
        ENDDO

        DO i=1,4
          DO j=1, sNx+sNy
            vec_sub_local_ij(vec_id, i, j) = 0
          ENDDO
        ENDDO

        DO i=1, (sNx+sNy)*(nSx*nSy)
          DO fld=1, MAX_NFLDS
            fldOnMsk_2D(vec_id, fld, i) = 0.0
            fldOnMsk_2Davg(vec_id, fld, i) = 0.0
            DO k=1, Nr
              fldOnMsk_3D(vec_id, fld, i, k) = 0.0
              fldOnMsk_3Davg(vec_id, fld, i, k) = 0.0
            ENDDO
          ENDDO
        ENDDO

        DO bj = myByLo(myThid), myByHi(myThid)
         DO bi = myBxLo(myThid), myBxHi(myThid)

          DO j=1-OLy,sNy+OLy
            DO i=1-OLx,sNx+OLx
                vec_subMask(vec_id,i,j,bi,bj)   = 0.0
            ENDDO
          ENDDO

         ENDDO
        ENDDO

        DO i=1, nPx*nPy
          vec_numPnts_allproc(vec_id, i) = 0
          DO j=1, (sNx+sNy)*(nSx*nSy)
            vec_mask_ind_list(vec_id,i,j) = 0
          ENDDO
        ENDDO

      ENDDO

C     This is in the initialization of the surface variables

      DO i=1, (sNy*sNx)*(nPx*nPy)*(nSx*nSy)
        global_SF(i) = 0.0
      ENDDO

      DO sf_id=1, nSURF_mask

        DO pid=1, nPx*nPy
          sf_numPnts_allproc(sf_id,pid) = 0
        ENDDO

        DO i=1,4
          DO j=1, sNx*sNy
            sf_sub_local_ij(sf_id, i, j) = 0
          ENDDO
        ENDDO

        DO i=1, (sNx*sNy)*(nSx*nSy)
          DO fld=1, MAX_NFLDS
            fldOnMsk_SF(sf_id, fld, i) = 0.0
            fldOnMsk_SFavg(sf_id, fld, i) = 0.0
          ENDDO
        ENDDO

        DO bj = myByLo(myThid), myByHi(myThid)
         DO bi = myBxLo(myThid), myBxHi(myThid)
          DO j=1-OLy,sNy+OLy
            DO i=1-OLx,sNx+OLx
                sf_subMask(sf_id,i,j,bi,bj)   = 0.0
            ENDDO
          ENDDO
         ENDDO
        ENDDO

        DO i=1, nPx*nPy
          sf_numPnts_allproc(sf_id, i) = 0
          DO j=1, (sNx*sNy)*(nSx*nSy)
            sf_mask_ind_list(sf_id,i,j) = 0
          ENDDO
        ENDDO

      ENDDO

C     Initializing number of time levels and time passed
      time_level = 1
      time_passed = startTime

C----&------------------------------------------------------------------xxxxxxx|
C     Read in the masks
C----&------------------------------------------------------------------xxxxxxx|

C     Looping through each vector mask
      DO vec_id=1, nVEC_mask

      if (debug .eq. 1) then
        WRITE(msgBuf,'(A,A,I1)') 'Identifying mask points for',
     &  ' mask number ',vec_id
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

C       Read open boundary mask files and assign portion of open boundary mask to each process
        CALL READ_REC_XY_RL( vec_fnames(vec_id),
     &               vec_subMask(vec_id,:,:,:,:), 1, 0, myThid )

C       Filling in halo regions of sub masks
        _EXCH_XY_RL(vec_subMask(vec_id,:,:,:,:), myThid)
      
C       Fill in the submask indices, global counts, and place in the ordered mask
        CALL IDENTIFY_VEC_POINTS(vec_id, myThid)

      ENDDO


C     Looping through each surface mask
      DO sf_id=1, nSURF_mask

C       Read surface mask files and assign portion of surface mask to each process
        CALL READ_REC_XY_RL( sf_fnames(sf_id),
     &               sf_subMask(sf_id,:,:,:,:),1, 0, myThid )

C       Filling in halo regions of sub masks
        _EXCH_XY_RL(sf_subMask(sf_id,:,:,:,:), myThid)
        
C       Fill in the submask indices, global counts, and place in the ordered mask
        CALL IDENTIFY_SF_POINTS(sf_id, myThid)

      ENDDO


#ifdef ALLOW_USE_MPI
C     When using MPI, proc 0 keeps track of who has which points
C       (wihout MPI, the main proc already knows this)
      CALL SEND_CHILD_TO_PARENT(myThid)
#endif

C----&------------------------------------------------------------------xxxxxxx|
C     Print out the number of points in each proc to verify that
C     each proc received points as expected

      IF ((debug.eq.1).and.(mpiMyId.eq.0)) THEN 
        DO vec_id=1,nVEC_mask
          WRITE(msgBuf,'(A,A,A)') "For mask ",vec_fnames(vec_id),","
          CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &        SQUEEZE_RIGHT, myThid )
        DO i=1,nPx*nPy
          WRITE(msgBuf,'(A,I5,A,I5,A)') 
     &   "    Proc ",i," sent ",vec_numPnts_allproc(vec_id,i),' points'
          CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &        SQUEEZE_RIGHT, myThid )
        ENDDO
        ENDDO

        DO sf_id=1,nSURF_mask
          WRITE(msgBuf,'(A,A,A)') "For mask ",sf_fnames(sf_id),","
          CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &        SQUEEZE_RIGHT, myThid )
        DO i=1,nPx*nPy
          WRITE(msgBuf,'(A,I5,A,I5,A)') 
     &   "    Proc ",i," sent ",sf_numPnts_allproc(sf_id,i),' points'
          CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &        SQUEEZE_RIGHT, myThid )
        ENDDO
        ENDDO
      ENDIF

C----&------------------------------------------------------------------xxxxxxx|


      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  END DIAGNOSTICS_VEC_INIT_FIXED DEBUG "
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif


      RETURN
      END

CEOC
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|










C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: IDENTIFY_VEC_POINTS

C !INTERFACE:
      SUBROUTINE IDENTIFY_VEC_POINTS(vec_id, myThid)

C     !DESCRIPTION:
C     Locate vector mask points within each subtile

      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "DIAGNOSTICS_VEC.h"

C     !INPUT PARAMETERS:
      INTEGER vec_id, myThid

C     !LOCAL VARIABLES:     
      INTEGER counter, i, j, bi, bj
      INTEGER, PARAMETER :: debug = 0
      CHARACTER*(MAX_LEN_MBUF) msgBuf

#ifndef ALLOW_USE_MPI
      INTEGER, PARAMETER :: mpiMyId = 0
#endif

CEOP
C----&------------------------------------------------------------------xxxxxxx|
CBOC

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  BEGIN IDENTIFY_VEC_POINTS DEBUG "
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

      counter = 1
      DO bj = myByLo(myThid), myByHi(myThid)
       DO bi = myBxLo(myThid), myBxHi(myThid)
         DO j=1,sNy
           DO i=1,sNx

             if (vec_subMask(vec_id,i,j,bi,bj) .ge. 1.0 ) then

C              First row contains local i's. 
C              Second row contains local j's.
C              Third row contains tile bi's
C              Fourth row contains tile bi's
               vec_sub_local_ij(vec_id, 1, counter) = i
               vec_sub_local_ij(vec_id, 2, counter) = j
               vec_sub_local_ij(vec_id, 3, counter) = bi
               vec_sub_local_ij(vec_id, 4, counter) = bj

        if (debug .eq. 1) then
        WRITE(msgBuf,'(A,I5,A,I5,A,I5,A,I5,A,I5,A,I5,A)') 
     &      "vec_sub_local_ij(",
     &      vec_id,",:,", counter,",) = (",i,',',j,",",bi,",",bj,")"
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &        SQUEEZE_RIGHT, myThid )
        endif

C              Save the mask index for this processor
               vec_mask_ind_list(vec_id,mpiMyId+1,counter) = 
     &           vec_subMask(vec_id,i,j,bi,bj)

        if ((debug .eq. 1).and.(vec_id.eq.1)) then
        WRITE(msgBuf,'(A,I5,A,I5,A,I5,A,I10)') 
     &   "vec_mask_ind_list(",vec_id,",",mpiMyId+1,',',
     &    counter,") = ",vec_mask_ind_list(vec_id,mpiMyId+1,counter)
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &        SQUEEZE_RIGHT, myThid )
        endif

               counter = counter + 1
             end if
            ENDDO
          ENDDO
        ENDDO
      ENDDO

      vec_numPnts_allproc(vec_id,mpiMyId+1) = counter-1 

      if (debug .eq. 1) then
      if (counter.eq.1) then 
        WRITE(msgBuf,'(A,I5,A)') 
     &   "Proc ",mpiMyId,' did not have any points from this mask'
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &        SQUEEZE_RIGHT, myThid )
      else
        WRITE(msgBuf,'(A,I5,A,I5,A)') 
     &   "Proc ",mpiMyId,' has ',counter-1,' points'
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &        SQUEEZE_RIGHT, myThid )
      endif
      endif

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  END IDENTIFY_VEC_POINTS DEBUG "
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

      END

CEOC
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|



C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: IDENTIFY_VEC_POINTS

C !INTERFACE:
      SUBROUTINE IDENTIFY_SF_POINTS(sf_id, myThid)

C     !DESCRIPTION:
C     Locate surface mask points within each subtile
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "DIAGNOSTICS_VEC.h"


C     !INPUT PARAMETERS:
      INTEGER sf_id, myThid

C     !LOCAL VARIABLES:     
      INTEGER counter, i, j, bi, bj
      INTEGER, PARAMETER :: debug = 0
      CHARACTER*(MAX_LEN_MBUF) msgBuf

#ifndef ALLOW_USE_MPI
      INTEGER, PARAMETER :: mpiMyId = 0
#endif
CEOP
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOC

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  BEGIN IDENTIFY_SF_POINTS DEBUG "
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

      counter = 1
      DO bj = myByLo(myThid), myByHi(myThid)
       DO bi = myBxLo(myThid), myBxHi(myThid)
         DO j=1,sNy
           DO i=1,sNx

             if (sf_subMask(sf_id,i,j,bi,bj) .ge. 1.0 ) then

C              First row contains local i's. 
C              Second row contains local j's.
C              Third row contains tile bi's
C              Fourth row contains tile bi's
               sf_sub_local_ij(sf_id, 1, counter) = i
               sf_sub_local_ij(sf_id, 2, counter) = j
               sf_sub_local_ij(sf_id, 3, counter) = bi
               sf_sub_local_ij(sf_id, 4, counter) = bj

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A,I5,A,I5,A,I5,A,I5,A,I5,A,I5,A)') 
     &      "sf_sub_local_ij(",
     &      sf_id,",:,", counter,",) = (",i,',',j,",",bi,",",bj,")"
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &        SQUEEZE_RIGHT, myThid )
      endif

              sf_mask_ind_list(sf_id,mpiMyId+1,counter) = 
     &           sf_subMask(sf_id,i,j,bi,bj)

      if ((debug .eq. 1).and.(sf_id.eq.1)) then
      WRITE(msgBuf,'(A,I5,A,I5,A,I5,A,I10)') 
     &   "sf_mask_ind_list(",sf_id,",",mpiMyId+1,',',
     &    counter,") = ",sf_mask_ind_list(sf_id,mpiMyId+1,counter)
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &        SQUEEZE_RIGHT, myThid )
      endif

               counter = counter + 1
             end if
            ENDDO
          ENDDO
        ENDDO
      ENDDO

      sf_numPnts_allproc(sf_id,mpiMyId+1) = counter-1


      if ((debug .eq. 1).and.(counter.eq.1)) then
        WRITE(msgBuf,'(A,I5,A)') 
     &   "Proc ",mpiMyId,' did not have any points from this mask'
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &        SQUEEZE_RIGHT, myThid )
      endif

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  END IDENTIFY_SF_POINTS DEBUG "
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

      
      END

CEOC
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|







#ifdef ALLOW_USE_MPI
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: SUBROUTINE SEND_CHILD_TO_PARENT

C !INTERFACE:
      SUBROUTINE SEND_CHILD_TO_PARENT(myThid)

C     !DESCRIPTION:
C     Sending global indices and number of open boundary points from processes 
C     > 0 to master process
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "DIAGNOSTICS_VEC.h"

C     !LOCAL VARIABLES:
      INTEGER vec_id, myThid
      INTEGER pid, i, status(MPI_STATUS_SIZE), ierror
      INTEGER sf_id
      INTEGER g_vec_indices((sNx+sNy)*(nSx*nSy))
      INTEGER g_sf_indices((sNx*sNy)*(nSx*nSy))
      INTEGER num_pts
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER, PARAMETER :: debug = 0
CEOP
C----&------------------------------------------------------------------xxxxxxx|
CBOC 

C     /==================================================================\
C     | Note: MPI_SEND params: data_to_send, send_count, send_type,      |
C     |                        destination_ID, tag, comm, ierror         |
C     \==================================================================/

C     /==================================================================\
C     | Note: MPI_RECV params: received_data, receive_count,             |
C     |                        receive_type, sender_ID, tag, comm,       |
C     |                        status, ierror                            |
C     \==================================================================/

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  BEGIN SEND_CHILD_TO_PARENT DEBUG "
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

C---------------------------------------------------------------------------
C ---- This section is for the vector masks

C ---- Here child process sends global indices of vec points, and then
C      the count of the vec points
      

        IF (mpiMyId .gt. 0) then
          if (debug .eq. 1) then
          WRITE(msgBuf,'(A,I5,A)') 'mpiMyId = ',mpiMyId,
     &     '>0  => Calling MPI_SEND'
          CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
          endif
          DO vec_id=1, nVEC_mask
            call MPI_SEND(vec_mask_ind_list(vec_id,mpiMyId+1,:),
     &  (sNx+sNy)*(nSx*nSy), MPI_INT,0, vec_id, MPI_COMM_MODEL, ierror)
            call MPI_SEND(vec_numPnts_allproc(vec_id,mpiMyId+1),
     &             1, MPI_INT,0, vec_id*100, MPI_COMM_MODEL, ierror)
          ENDDO
        ENDIF

C ---- Here master process receives global indices from child process pid, 
C      and then the count of vec points from child process pid

        IF (mpiMyId .eq. 0) then
          if (debug .eq. 1) then
          WRITE(msgBuf,'(A)')  'mpiMyId=0  => Calling MPI_RECV'
          CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
          endif
          DO pid=1, nPx*nPy-1
            DO vec_id=1, nVEC_mask
              call MPI_RECV(g_vec_indices,(sNx+sNy)*(nSx*nSy), MPI_INT,
     &                   pid, vec_id ,MPI_COMM_MODEL, status, ierror)

              call MPI_RECV(num_pts, 1, MPI_INT,
     &               pid, vec_id*100 ,MPI_COMM_MODEL, status, ierror)

              DO i=1, (sNx+sNy)*(nSx*nSy)
               vec_mask_ind_list(vec_id,pid+1,i) 
     &                   = g_vec_indices(i)
              ENDDO
              vec_numPnts_allproc(vec_id,pid+1) = num_pts
            ENDDO
          ENDDO
         ENDIF


C---------------------------------------------------------------------------
C ---- This section is for the surface

C ---- Here child process sends global indices of sf points, and then
C      the count of the sf points

        IF (mpiMyId .gt. 0) then
          DO sf_id=1, nSURF_mask
            call MPI_SEND(sf_mask_ind_list(sf_id,mpiMyId+1,:),
     &  (sNx*sNy)*(nSx*nSy), MPI_INT,0, sf_id, MPI_COMM_MODEL, ierror)
            call MPI_SEND(sf_numPnts_allproc(sf_id,mpiMyId+1),
     &             1, MPI_INT,0, sf_id*100, MPI_COMM_MODEL, ierror)
          ENDDO
        ENDIF

C ---- Here master process receives global indices from child process pid, 
C      and then the count of SF points from child process pid

        IF (mpiMyId .eq. 0) then
          DO pid=1, nPx*nPy-1
            DO sf_id=1, nSURF_mask
              call MPI_RECV(g_sf_indices,(sNx*sNy)*(nSx*nSy), MPI_INT,
     &                   pid, sf_id ,MPI_COMM_MODEL, status, ierror)
              call MPI_RECV(num_pts, 1, MPI_INT,
     &                   pid, sf_id*100 ,MPI_COMM_MODEL, status, ierror)

              DO i=1, (sNx*sNy)*(nSx*nSy)
               sf_mask_ind_list(sf_id,pid+1,i) 
     &                   = g_sf_indices(i)
              ENDDO
              sf_numPnts_allproc(sf_id,pid+1) = num_pts
            ENDDO
          ENDDO
         ENDIF


      if (debug .eq. 1) then
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "  END SEND_CHILD_TO_PARENT DEBUG "
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A)') "==========================================="
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif


       END

CEOC
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
#endif /* ALLOW_USE_MPI */