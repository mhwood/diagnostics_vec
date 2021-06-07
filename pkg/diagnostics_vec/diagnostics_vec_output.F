C----&------------------------------------------------------------------xxxxxxx|
C                           diagnostics_vec_output
C----&------------------------------------------------------------------xxxxxxx|
C Contributors: Michael Wood, Ian Fenty, April Shin

#include "DIAGNOSTICS_VEC_OPTIONS.h"

C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: DIAGNOSTICS_VEC_OUTPUT

C !INTERFACE:
      SUBROUTINE DIAGNOSTICS_VEC_OUTPUT( myTime, myIter, myThid )

C     !DESCRIPTION:
C     Extracts virtual transects and slices of global model fields.

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "DYNVARS.h"
#include "DIAGNOSTICS_VEC.h"

C     !INPUT/OUTPUT PARAMETERS:
C     myThid ::  my Thread Id number
      _RL myTime
      INTEGER myThid
      INTEGER myIter

C     !LOCAL VARIABLES:
       CHARACTER*(MAX_LEN_MBUF) msgBuf
       INTEGER i,j, k, iG, jG, bi, bj, fld2D, fld3D, fld
       INTEGER fldSF
       INTEGER vec_id, sf_id
       INTEGER tag
       INTEGER total_valid
       REAL*8 buffer2D(sNx+sNy)
       REAL*8 buffer3D(sNx+sNy, Nr)
       REAL*8 bufferSF(sNx*sNy)

       INTEGER, PARAMETER :: debug = 0

       LOGICAL DIFFERENT_MULTIPLE

#ifndef ALLOW_USE_MPI
      INTEGER, PARAMETER :: mpiMyId = 0
#endif

CEOP
C----&------------------------------------------------------------------xxxxxxx|


#ifdef ALLOW_USE_MPI
       INTEGER pid, ierror, status(MPI_STATUS_SIZE)
       common / mpi_var / status, ierror
C  All MPI objects (e.g., MPI_Datatype, MPI_Comm) are of type INTEGER in Fortran.
       INTEGER full_dim(2), sub_dim(2), start_ind(2)
#endif

       COMMON / local_var / total_valid


       if (debug .eq. 1) then
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "  BEGIN DIAGNOSTICS_VEC_OUTPUT DEBUG "
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A,I10)') "     myIter: ", myIter
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A,I5)') "     mpiMyId: ",mpiMyId
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A,F9.3)') "     time_passed: ", time_passed
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A,F9.3)') "     nTimeSteps_vec: ",nTimeSteps_vec
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        endif

       IF ((time_passed.le.endTime_vec).AND.
     &     (time_passed.ge.startTime_vec)) then

C----&------------------------------------------------------------------xxxxxxx|
C      All Processes Tasks:
C         At each time step:
C          1. Extract field values on open boundary points
C          2. Accumulate extracted field values
C         At end of averaging period:
C          1. Generate time-averaged field values
C          2. Processes > 0 send time-averaged field values to master process
C             (Convert _RL array to R8 before sending. Send R8 array)
C----&------------------------------------------------------------------xxxxxxx|

C       Initializing local arrays
        DO i=1,sNx+sNy
          buffer2D(i) = 0.0
          DO k=1,Nr
            buffer3D(i,k) = 0.0
          ENDDO
        ENDDO

        DO i=1,sNx*sNy
          bufferSF(i) = 0.0
        ENDDO

C       Extracting field values on open boundary points at each time step
        CALL SET_SUBFIELDS(myThid, myIter)

        IF (nTimeSteps_vec .eq. 0) then
C        Initialize averages to zero
         CALL SET_TO_INI_STATE(myThid)
        ELSE
C        Cumulate diagnostics_vec fields and number of time steps (for time average)
         CALL CUMULATE_FLD_TIME(myThid)
        ENDIF

C      !ENDIF for IF myTime .le. endTIme_vec
       ENDIF


C----&------------------------------------------------------------------xxxxxxx|
C      Check if at end of averaging period:

      if (debug .eq. 1) then
        WRITE(msgBuf,'(A,A)') "  DIAGNOSTICS_VEC_OUTPUT: ",
     &                      "CHECKING IF OUTPUT REQUESTED: "
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A,F18.3)') "     myTime: ",myTime
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A,F18.3)') "     endTime_vec: ",endTime_vec
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A,F18.3)') "     startTime_vec: ",startTime_vec
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A,F9.3)') "     nTimeSteps_vec: ",nTimeSteps_vec
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A,F9.3)') "     avgPeriod_vec: ",avgPeriod_vec
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A,F9.3)') "     deltaTClock: ",deltaTClock
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A,L1)') "     (myTime .le. endTime_vec): ",
     &                         (myTime .le. endTime_vec)
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A,L1)') "     DIFFERENT_MULTIPLE: ",
     &          DIFFERENT_MULTIPLE(avgPeriod_vec,myTime,deltaTClock)
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A,L1)') "     Output Requested: ",
     &          (((nTimeSteps_vec .NE. 0)
     & .AND.DIFFERENT_MULTIPLE(avgPeriod_vec,time_passed,deltaTClock))
     &  .AND. (time_passed .le. endTime_vec))
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        endif


       IF (((nTimeSteps_vec .NE. 0)
     &  .AND.DIFFERENT_MULTIPLE(avgPeriod_vec,time_passed,deltaTClock))
     &  .AND. (time_passed .le. endTime_vec)
     &  .AND. (time_passed .ge. startTime_vec)) THEN

C----&------------------------------------------------------------------xxxxxxx|
C      If at end of averaging period:

C       Compute time average of all sub fields
        CALL TIMEAVE_FLDS(myThid, myTime)

C       Now looping through each boundary mask and communicating fields between master process and child processes
C       Each child sends their piece of the mask to the parent here
C       The parent node does the receiving in VEC_MASTER_PROC_TASKS
        DO vec_id=1, nVEC_mask

#ifdef ALLOW_USE_MPI

C         Processes 1 and onward send sub fields to master process
C         if they have open boundary points
         if (mpiMyId .gt. 0) then
          if (vec_numPnts_allproc(vec_id,mpiMyId+1) .ge. 1) then

           DO fld2D=1, vec_nFlds2D(vec_id)
C           Convert _RL array to R8 array
            call VEC_PASS_RL_to_R8(buffer2D,buffer3D,vec_id,2,fld2D)

            tag = vec_tags(vec_id, 1, fld2D)

C           Send R8 array to master process
            call MPI_SEND(buffer2D, sNx+sNy, MPI_REAL8, 0, tag,
     &                    MPI_COMM_MODEL, ierror)

           ENDDO


           DO fld3D=1, vec_nFlds3D(vec_id)
            
C           Convert _RL array to R8 array
            call VEC_PASS_RL_to_R8(buffer2D,buffer3D,vec_id,3,fld3D)

            tag = vec_tags(vec_id, 2, fld3D)

C           Send R8 array to master process
           call MPI_SEND(buffer3D, vec_levels3D(fld3D,vec_id)*(sNx+sNy),
     &                    MPI_REAL8, 0, tag, MPI_COMM_MODEL, ierror)

           ENDDO

          end if
         end if

#endif

C         Processes 0 receives all of the points
         IF (mpiMyId .eq. 0) then
          DO fld2D=1, vec_nFlds2D(vec_id)
          call VEC_MASTER_PROC_TASKS(fld2D, vec_id, 2, myThid, myTime,
     &                                myIter)
          ENDDO
          DO fld3D=1, vec_nFlds3D(vec_id)
          call VEC_MASTER_PROC_TASKS(fld3D, vec_id, 3, myThid, myTime,
     &                                myIter)
          ENDDO
         ENDIF

C       !ENDDO for vec_id
        ENDDO




C ---- Surface Masks --------------------------------------------------------------------

C       Now looping through each surface mask and communicating fields between master process and child processes
C       Each child sends their piece of the mask to the parent here
C       The parent node does the receiving in SF_MASTER_PROC_TASKS
        DO sf_id=1, nSURF_mask

#ifdef ALLOW_USE_MPI

C         Processes 1 and onward send sub fields to master process
C         if they have surface points
         if (mpiMyId .gt. 0) then
          if (sf_numPnts_allproc(sf_id,mpiMyId+1) .ge. 1) then

           DO fldSF=1, sf_nFlds(sf_id)
C           Convert _RL array to R8 array
            call SF_PASS_RL_to_R8(bufferSF,sf_id,fldSF)

            tag = sf_tags(sf_id, 1, fldSF)

C           Send R8 array to master process
            call MPI_SEND(bufferSF, sNx*sNy, MPI_REAL8, 0, tag,
     &                    MPI_COMM_MODEL, ierror)
           ENDDO

          end if
         end if

#endif

         IF (mpiMyId .eq. 0) then
          DO fldSF=1, sf_nFlds(sf_id)
          call SF_MASTER_PROC_TASKS(fldSF, sf_id, myThid, myTime,
     &                                myIter)
          ENDDO
C         !ENDIF for mpiMyId .eq. 0
         ENDIF

C       !ENDDO for sf_id
        ENDDO

C      Set averages back to zero
       CALL SET_TO_INI_STATE(myThid)

C      Incrementing number of time levels passed
       time_level = time_level + 1

C     !ENDIF for end of averaging period

      ENDIF 

C      Move on to next time step
       nTimeSteps_vec = nTimeSteps_vec + 1
       time_passed = time_passed + deltaTClock

       if (debug .eq. 1) then
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "  END DIAGNOSTICS_VEC_OUTPUT DEBUG "
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        endif

      RETURN

      

      END








C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|

      SUBROUTINE VEC_MASTER_PROC_TASKS(fld, vec_id, nDim, myThid, myTime,
     &                             myIter)
C     Appending subFields to final global_vec array
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "DIAGNOSTICS_VEC.h"

C     Input Parameters:
C     fld :: current field number
C     vec_id :: current mask number
C     nDim :: number of dimensions of field to output
C     myThid :: thread number
C     myTime :: current time in model
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER fld, vec_id, nDim, myThid, myIter
      _RL myTime
      REAL*8 buffer2D(sNx+sNy)
      REAL*8 buffer3D(sNx+sNy, Nr)
      _RS dummyRS(1)
      INTEGER total_valid, i, k, count
      INTEGER, PARAMETER :: debug = 0
#ifndef ALLOW_USE_MPI
      INTEGER, PARAMETER :: mpiMyId = 0   
#else
      INTEGER pid, status(MPI_STATUS_SIZE), ierror, tag
      common / mpi_var / status, ierror
#endif
      common / local_var / total_valid
      

      DO i=1,sNx+sNy
        buffer2D(i) = 0.0
        DO k=1,Nr
          buffer3D(i,k) = 0.0
        ENDDO
      ENDDO

      total_valid = 0

C-----Append Local Array--------------------------------------------------------
C     - First append process 0 local arrays to final global array if number of
C          valid elements in those local arrays > 0
C     - Indices referring to process IDs begin with 1 in vec_numPnts_allproc and
C          subFieldOnMask_2Davg
C-------------------------------------------------------------------------------

      if (debug .eq. 1) then
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "  BEGIN VEC_MASTER_PROC_TASKS DEBUG "
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        endif

      if (debug .eq. 1) then
        WRITE(msgBuf,'(A,I5,A,I5)') "vec_numPnts_allproc ",
     &            vec_numPnts_allproc(vec_id,1), " at vec_id",vec_id
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

      IF (vec_numPnts_allproc(vec_id,1).ge.1) then
       if (nDim .eq. 2) then

C       Append process 0's 2D time-averaged field value on VEC points to final array
        call VEC_PASS_RL_to_R8(buffer2D, buffer3D, vec_id, 2,fld)
        call APPEND_VEC_VALUE2D(vec_id, 0, buffer2D)

C       Add onto total number of VEC points
        total_valid = total_valid + vec_numPnts_allproc(vec_id, 1)

        if (debug .eq. 1) then
          WRITE(msgBuf,'(A,I5,A,A)') "mask number:", vec_id, ",field",
     &            vec_flds2D(fld,vec_id)
          CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
          WRITE(msgBuf,'(A,A,I5,A)') "appended local field to global ",
     &          "array with ",vec_numPnts_allproc(vec_id, 1),
     &          "valid elements:"
          CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        endif

       else if (nDim .eq. 3) then

C       Append process 0's 3D time-averaged field value on VEC points to final array
        call VEC_PASS_RL_to_R8(buffer2D, buffer3D, vec_id, 3,fld)
        call APPEND_VEC_VALUE3D(vec_id, 0, fld, buffer3D)

C       Add onto total number of VEC points
        total_valid = total_valid + vec_numPnts_allproc(vec_id, 1)

        if (debug .eq. 1) then
          WRITE(msgBuf,'(A,I5,A,A)') "mask number:", vec_id, ",field",
     &            vec_flds3D(fld,vec_id)
          CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
          WRITE(msgBuf,'(A,A,I5,A)') "appended local field to global ",
     &          "array with ",vec_numPnts_allproc(vec_id, 1),
     &          "valid elements:"
          CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        endif
       end if

      ENDIF

C-----End of appending local array----------------------------------------------


C------Receiving arrays through MPI and appending-------------------------------
C      - Receive all sub arrays from processes with pid>0 and valid elements>0.
C      - Append receive sub arrays to final array.
C-------------------------------------------------------------------------------
#ifdef ALLOW_USE_MPI

       DO pid=1, mpiNprocs-1

C       If number of valid elements is greater than or equal to 1
        IF (vec_numPnts_allproc(vec_id,pid+1) .ge. 1) then

          if (debug .eq. 1) then
            WRITE(msgBuf,'(A,I5,A,I5,A,I5)') "receiving ",
     &       vec_numPnts_allproc(vec_id,pid+1), " elements from proc ",
     &       pid, " on mask number",vec_id
            CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
          endif

         IF (nDim .eq. 2) then

          tag = vec_tags(vec_id, 1, fld)

C         MPI_RECV params: received_data, receive_count, receive_type, sender_ID, tag, comm, status, ierror
C         Master process receiving time-averaged 2D field values on VEC points from process pid
          call MPI_RECV(buffer2D, sNx+sNy, MPI_REAL8,
     &                   pid, tag ,MPI_COMM_MODEL, status, ierror)

C         Appending the received time-averaged 2D field values on VEC points from process pid
          call APPEND_VEC_VALUE2D(vec_id, pid, buffer2D)

         ELSE IF (nDim .eq. 3) then

          tag = vec_tags(vec_id, 2, fld)

C         MPI_RECV params: received_data, receive_count, receive_type, sender_ID, tag, comm, status, ierror
C         Master process receiving time-averaged 3D field values on VEC points from process pid
          call MPI_RECV(buffer3D(:,1:vec_levels3D(fld,vec_id)),
     &           vec_levels3D(fld,vec_id)*(sNx+sNy), MPI_REAL8, pid,
     &           tag ,MPI_COMM_MODEL, status, ierror)

C         append_vec_values3D params: vec_id, pid, fld, vec_values
          call APPEND_VEC_VALUE3D(vec_id,pid, fld, buffer3D)

         ENDIF
C        Keeping count of total number of VEC points for each mask
         total_valid = total_valid + vec_numPnts_allproc(vec_id, pid+1)

C       ENDIF for number of valid elements
        ENDIF

C      ENDDO for pid
       ENDDO
#endif
C------End of receiving arrays through MPI and appending------------------------

C      Writing final output to binary file
       call WRITE_GLOBAL_BIN_VEC(total_valid,fld,vec_id,myIter,nDim)


       if (debug .eq. 1) then
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "  END VEC_MASTER_PROC_TASKS DEBUG "
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        endif

      END
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|











C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|

      SUBROUTINE SF_MASTER_PROC_TASKS(fld, sf_id, myThid, myTime,
     &                             myIter)
C     Appending subFields to final global_vec array
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "DIAGNOSTICS_VEC.h"

C     Input Parameters:
C     fld :: current field number
C     sf_id :: current mask number
C     nDim :: number of dimensions of field to output
C     myThid :: thread number
C     myTime :: current time in model
      INTEGER fld, sf_id, myThid, myIter
      _RL myTime
      REAL*8 bufferSF(sNx*sNy)
      _RS dummyRS(1)
      INTEGER total_valid, i, k, count
      INTEGER, PARAMETER :: debug = 0

#ifndef ALLOW_USE_MPI
      INTEGER, PARAMETER :: mpiMyId = 0   
#else
      INTEGER pid, status(MPI_STATUS_SIZE), ierror, tag
      common / mpi_var / status, ierror
#endif
      common / local_var / total_valid

      DO i=1,sNx*sNy
        bufferSF(i) = 0.0
      ENDDO

      total_valid = 0

C-----Append Local Array--------------------------------------------------------
C     - First append process 0 local arrays to final global array if number of
C          valid elements in those local arrays > 0
C     - Indices referring to process IDs begin with 1 in sf_numPnts_allproc and
C          subFieldOnMask_SFavg
C-------------------------------------------------------------------------------


      IF (sf_numPnts_allproc(sf_id,1).ge.1) then

        call SF_PASS_RL_to_R8(bufferSF, sf_id, fld)
C       Append process 0's SF time-averaged field value on SF points to final array
        call APPEND_SF_VALUE(sf_id, 0, bufferSF)
C       Add onto total number of SF points
        total_valid = total_valid + sf_numPnts_allproc(sf_id, 1)

      ENDIF

C-----End of appending local array----------------------------------------------


C------Receiving arrays through MPI and appending-------------------------------
C      - Receive all sub arrays from processes with pid>0 and valid elements>0.
C      - Append receive sub arrays to final array.
C-------------------------------------------------------------------------------
#ifdef ALLOW_USE_MPI

       DO pid=1, mpiNprocs-1
C       If number of valid elements is greater than or equal to 1
        IF (sf_numPnts_allproc(sf_id,pid+1) .ge. 1) then

          tag = sf_tags(sf_id, 1, fld)
C         !MPI_RECV params: received_data, receive_count, receive_type, sender_ID, tag, comm, status, ierror
C         Master process receiving time-averaged surface field values on SF points from process pid
          call MPI_RECV(bufferSF, sNx*sNy, MPI_REAL8,
     &                   pid, tag ,MPI_COMM_MODEL, status, ierror)

C         Appending the received time-averaged SF field values on SF points from process pid
          call APPEND_SF_VALUE(sf_id, pid, bufferSF)

C        Keeping count of total number of VEC points for each mask
         total_valid = total_valid + sf_numPnts_allproc(sf_id, pid+1)

C       !ENDIF for number of valid elements
        ENDIF

C      !ENDDO for pid
       ENDDO
#endif
C------End of receiving arrays through MPI and appending------------------------

C      Writing final output to binary file
       call WRITE_GLOBAL_BIN_SF(total_valid,fld,sf_id,myIter,nDim)


      END
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|









C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
      SUBROUTINE APPEND_VEC_VALUE2D(vec_id, pid, vec_values)
C       Appends field value corresponding to open boundary points to final global array global_vec.

#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "DIAGNOSTICS_VEC.h"

         REAL*8 vec_values(sNx+sNy)
         INTEGER num_valid, i, vec_index, vec_id, pid
         INTEGER, PARAMETER :: debug = 0
C------------------------------------------------------------------------------|
C------------------------------------------------------------------------------|

         num_valid = vec_numPnts_allproc(vec_id,pid+1)

         do i=1, num_valid
C          Extracting vec_index from list for VEC point i in process pid
           vec_index = vec_mask_index_list(vec_id,pid+1,i)

C          Inserting time-averaged field value on VEC point i in index vec_index of the final array, global_vec2D
           global_vec2D(vec_index) = vec_values(i)

         end do
         

       END
C------------------------------------------------------------------------------|
C------------------------------------------------------------------------------|








C------------------------------------------------------------------------------|
C------------------------------------------------------------------------------|
       SUBROUTINE APPEND_VEC_VALUE3D(vec_id, pid, fld, vec_values)
C       Appends field value corresponding to open boundary points to final global array global_vec.

#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "DIAGNOSTICS_VEC.h"

        REAL*8 vec_values(sNx+sNy, Nr)
        INTEGER num_valid, i, k, vec_index, vec_id, pid, fld
        INTEGER, PARAMETER :: debug = 0
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
        num_valid = vec_numPnts_allproc(vec_id,pid+1)

        do i=1, num_valid
C        Extracting vec_index from list for VEC point i in process pid
         vec_index = vec_mask_index_list(vec_id,pid+1,i)

C        Inserting time-averaged field value on VEC point i in index vec_index of
C        the final array, global_vec3D for each depth
         do k=1, vec_levels3D(fld,vec_id)
          global_vec3D(vec_index,k) = vec_values(i,k)
         enddo
       enddo

       END
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|





C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
      SUBROUTINE APPEND_SF_VALUE(sf_id, pid, sf_values)
C       Appends field value corresponding to surface boundary points to final global array global_vec.

#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "DIAGNOSTICS_VEC.h"

         REAL*8 sf_values(sNx*sNy)
         INTEGER num_valid, i, sf_index, sf_id, pid
         INTEGER, PARAMETER :: print_debug = 0
C------------------------------------------------------------------------------|
C------------------------------------------------------------------------------|
         sf_index = 1
         num_valid = sf_numPnts_allproc(sf_id,pid+1)

         do i=1, num_valid
C          Extracting vec_index from list for SF point i in process pid
           sf_index = sf_mask_index_list(sf_id,pid+1,i)

C          Inserting time-averaged field value on SF point i in index sf_index of the final array, global_SF
           global_SF(sf_index) = sf_values(i)
         end do


       END
C------------------------------------------------------------------------------|
C------------------------------------------------------------------------------|








C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
       SUBROUTINE VEC_PASS_RL_to_R8(buffer2D,buffer3D,vec_id,nDim,fld)
#include "SIZE.h"
#include "EEPARAMS.h"
#include "DIAGNOSTICS_VEC.h"

         REAL*8 buffer2D(sNx + sNy)
         REAL*8 buffer3D(sNx + sNy, Nr)
         INTEGER vec_id, nDim, fld
         INTEGER i,k
         INTEGER, PARAMETER :: debug = 0
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
         IF (nDim .eq. 2) then
           DO i=1, sNx+sNy
             buffer2D(i) = subFieldOnMask_2Davg(vec_id,fld,i)
           ENDDO

         ELSE IF (nDim .eq. 3) then
           DO i=1, sNx+sNy
             DO k=1,vec_levels3D(fld,vec_id)
               buffer3D(i,k) = subFieldOnMask_3Davg(vec_id,fld,i,k)
             ENDDO
           ENDDO

         ENDIF

       END
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|






C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
       SUBROUTINE SF_PASS_RL_to_R8(bufferSF, sf_id,fld)
#include "SIZE.h"
#include "EEPARAMS.h"
#include "DIAGNOSTICS_VEC.h"

         REAL*8 bufferSF(sNx * sNy)
         INTEGER sf_id, fld
         INTEGER i
         INTEGER, PARAMETER :: debug = 0
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
           DO i=1, sNx*sNy
             bufferSF(i) = subFieldOnMask_SFavg(sf_id,fld,i)
           ENDDO

       END
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|





