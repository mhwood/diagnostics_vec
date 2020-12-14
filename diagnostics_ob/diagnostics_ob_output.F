C----&------------------------------------------------------------------xxxxxxx|
C                           diagnostics_ob_output
C----&------------------------------------------------------------------xxxxxxx|

#include "DIAGNOSTICS_OB_OPTIONS.h"


C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: DIAGNOSTICS_OB_OUTPUT

C !INTERFACE:
      SUBROUTINE DIAGNOSTICS_OB_OUTPUT( myTime, myIter, myThid )

C     !DESCRIPTION:
C     Extracts virtual transects and slices of global model fields.

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "DYNVARS.h"
#ifdef ALLOW_OBCS
C#include "OBCS_FIELDS.h"
#endif
#ifdef ALLOW_SEAICE
#include "SEAICE_SIZE.h"
#include "SEAICE.h"
#endif
#include "DIAGNOSTICS_OB.h"

C     !INPUT/OUTPUT PARAMETERS:
C     myThid ::  my Thread Id number
      _RL myTime
      INTEGER myThid
      INTEGER myIter

C     !LOCAL VARIABLES:
       CHARACTER*(MAX_LEN_MBUF) msgBuf
       INTEGER i,j, k, iG, jG, bi, bj, fld2D, fld3D, fld
       INTEGER fldSF
       INTEGER ob_subMask_size, ob_id
       INTEGER sf_subMask_size, sf_id
       INTEGER ob_tag
       INTEGER sf_tag
       INTEGER total_valid
       REAL*8 buffer2D(sNx+sNy)
       REAL*8 buffer3D(sNx+sNy, Nr)
       REAL*8 bufferSF(sNx*sNy)

       INTEGER, PARAMETER :: debug = 0
       INTEGER, PARAMETER :: print_debug = 0
       INTEGER, PARAMETER :: send_debug = 0
       INTEGER, PARAMETER :: sf_send_debug = 1

       LOGICAL DIFFERENT_MULTIPLE

CEOP
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
C
C     /==================================================================\
C     | Description                                                      |
C     |==================================================================|
C     | DIAGNOSTICS_OB_OUTPUT:                                           |
C     | Extracts virtual transects and slices of global model fields.    | 
C     |                                                                  |
C     | The tiles over which the virtual transects span contain lateral  |
C     | open boundary conditions of ocean state variables and fluxes for |
C     | fluxes for regional ocean models. To reduce the runtime and      |
C     | memory usage, we divide each tile (open boundary mask input and  |
C     | fields) into multiple sub-tiles of equal dimension, use the      |
C     | Message Passage Interface (MPI) standard to assign each sub-mask |
C     | and sub-fields to a unique process. Each process will identify   |
C     | open boundary points in their assigned sub-mask and extract      |
C     | field values at open boundary points and sends to the master     |
C     | process. Master process combines these arrays and writes result  |
C     | to binary files.                                                 |
C     |                                                                  |
C     | Program outputs at the end of each averaging period.             |
C     \==================================================================/
C
C     /==================================================================\
C     | Variable Definitions by Source                                   |
C     |==================================================================|
C     | INPUTS:                                                          |
C     | - myTime :: Informational/error message buffer                   |
C     | - myThid :: Work variable for IO unit number                     |
C     | - myIter :: Indices used in variable definition loops            |
C     |                                                                  |
C     | LOCAL VARIABLES:                                                 |
C     |                                                                  |
C     | msgBuf           - Used to write statements into the output file |
C     | ob_subMask_size  - Integer size of ob_subMask                    |
C     | ob_id            - Integer used for do loop through each ob mask |
C     | sf_subMask_size  - Integer size of sf_subMask                    |
C     | sf_id            - Integer used for do loop through each sf mask |
C     | total_valid      - Integer value of total count of valid         |
C     |                    elements in each open boundary mask/ Count    |
C     |                    done when looping through arrays sent from    |
C     |                    processes + local field on mask array         |
C     | pid              - Integer value for process ID                  |
C     | ierror           - Error code for MPI functions                  |
C     | status           - Integer array with values characterizing MPI  |
C     |                    function i.e. message tag, recipient, sender, |
C     | debug            - Integer used to hold either 1 or 0, 1 to      |
C     |                    print debug statements or 0 to ignore         |
C     | print_debug      - Integer used to hold either 1 or 0, 1 to      |
C     |                    print debug statements or 0 to ignore         |
C     | buffer2D         - Real*8 array storing subFieldOnMask_2Davg     |
C     |                    values converted to Real*8                    |
C     |                    Also acts as buffer for MPI_RECV              |
C     | buffer3D         - Real*8 array storing subFieldOnMask_3Davg     |
C     |                    values converted to Real*8                    |
C     |                    Also acts as buffer for MPI_RECV              |
C     | bufferSF         - Real*8 array storing subFieldOnMask_SFavg     |
C     |                    values converted to Real*8                    |
C     |                    Also acts as buffer for MPI_RECV              |
C     |                                                                  |
C     | From PARAMS.h:                                                   |
C     | - startTime  endTime                                             |
C     | - deltaTClock                                                    |
C     |                                                                  |
C     | From EESUPPORT.h : all initialized by subroutine INI_PROCS:      |
C     | - mpiNprocs - No. of MPI processes.                              |
C     | - mpiMyId   - MPI process id of me.                              |
C     | - mpiPx     - My MPI proc. grid X coord                          |
C     | - mpiPy     - My MPI proc. grid Y coord                          |
C     | - mpiXGlobalLo - My bottom-left (south-west) x-coordinate in     |
C     |              global domain.                                      |
C     | - mpiYGlobalLo - My bottom-left (south-west) y-coordinate in     |
C     |              global domain.                                      |
C     \==================================================================/
C
C----&------------------------------------------------------------------xxxxxxx|

C----&------------------------------------------------------------------xxxxxxx|

#ifdef ALLOW_USE_MPI
       INTEGER pid, ierror, status(MPI_STATUS_SIZE)
       common / mpi_var / status, ierror
C  All MPI objects (e.g., MPI_Datatype, MPI_Comm) are of type INTEGER in Fortran.
       INTEGER full_dim(2), sub_dim(2), start_ind(2)
#endif

       COMMON / local_var / total_valid


       IF (myTime .le. endTime_ob) then

        if (debug .eq. 1) then
          print *, "DIAGNOSTICS_OB_OUTPUT timepassed:", time_passed
          print *, "DIAGNOSTICS_OB_OUTPUT nTimeSteps_ob:",
     &             nTimeSteps_ob
          print *, "DIAGNOSTICS_OB_OUTPUT deltaTClock:", deltaTClock
          print *, "DIAGNOSTICS_OB_OUTPUT avgPeriod_ob:", avgPeriod_ob
          print *, "DIAGNOSTICS_OB_OUTPUT myTime:", myTime
          print *, "DIAGNOSTICS_OB_OUTPUT startTime:",startTime
          print *, "DIAGNOSTICS_OB_OUTPUT model endTIme", endTime
          print *, "DIAGNOSTICS_OB_OUTPUT user start time:",
     &              startTime_ob
          print *, "DIAGNOSTICS_OB_OUTPUT user end time:",endTime_ob
          print *, "DIAGNOSTICS_OB_OUTPUT DIFFERENT_MULTIPLE",
     &          DIFFERENT_MULTIPLE(avgPeriod_ob,myTime,deltaTClock)
        end if

C----&------------------------------------------------------------------xxxxxxx|
c      All Processes Tasks:
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

c       ob_subMask initialized in diagnostics_readparms, dimensions match READ_REC_XY_RS field:
c       field(1-Olx:sNx+Olx,1-Oly:sNy+Oly,nSx,nSy)
        ob_subMask_size = (abs(1-OLx)+(sNx+OLx))*
     &                    (abs(1-OLy)+(sNy+OLy))*nSx*nSy
        sf_subMask_size = (abs(1-OLx)+(sNx+OLx))*
     &                    (abs(1-OLy)+(sNy+OLy))*nSx*nSy

C       Extracting field values on open boundary points at each time step
        CALL SET_SUBFIELDS(myThid, myIter)

        IF (nTimeSteps_ob .eq. 0) then
C        Initialize averages to zero
         CALL SET_TO_INI_STATE(myThid)
        ELSE
C        Cumulate Diagnostics_ob fields and number of time steps (for Time Average)
         CALL CUMULATE_FLD_TIME(myThid)
        ENDIF

C      !ENDIF for IF myTime .le. endTIme_ob
       ENDIF

C----&------------------------------------------------------------------xxxxxxx|
C      If at end of averaging period:

       IF (((nTimeSteps_ob .NE. 0)
     &       .AND.DIFFERENT_MULTIPLE(avgPeriod_ob,myTime,deltaTClock))
     &       .AND. (myTime .le. endTime_ob)) THEN

C       Compute time average of all sub fields (incl. surface)
        CALL TIMEAVE_OB_FLD(myThid, myTime)

C----&--------------------------------
C      Loop through the boundary masks

C       Now looping through each boundary mask and communicating fields between master process and child processes
        DO ob_id=1, nOB_mask

#ifdef ALLOW_USE_MPI
         if (mpiMyId .gt. 0) then
C         Processes 1 and onward send sub fields to master process
C         if they have open boundary points
          if (ob_numPnts_allproc(ob_id,mpiMyId+1) .ge. 1) then

           print *,"Yes going to send for ob mask", ob_id

           DO fld2D=1, ob_nFlds2D(ob_id)
C           Convert _RL array to R8 array
            call OB_PASS_RL_to_R8(buffer2D,buffer3D,ob_id,2,fld2D)

            ob_tag = ob_tags(ob_id, 1, fld2D)

            if (send_debug .eq. 1) then
             print *,"Sending field", ob_flds2D(fld2D,ob_id)
             print*,"Sending with ob_tag:",ob_tag,"for ob_id",ob_id,
     &             "fld2D",fld2D, "at myIter", myIter, "proc",mpiMyId
             print *,"Sending array"
             print *,buffer2D
            endif

            print *,"In MPI_SEND for 2D, sNx+sNy=",sNx+sNy
C           Send R8 array to master process
            call MPI_SEND(buffer2D, sNx+sNy, MPI_REAL8, 0, ob_tag,
     &                    MPI_COMM_MODEL, ierror)

           ENDDO


           DO fld3D=1, ob_nFlds3D(ob_id)
            ob_tag = ob_tags(ob_id, 2, fld3D)
C           Convert _RL array to R8 array
            call OB_PASS_RL_to_R8(buffer2D,buffer3D,ob_id,3,fld3D)

            if (send_debug .eq. 1) then
             print *,"Sending field", ob_flds3D(fld3D,ob_id), "for mask"
     &              , ob_id
             print*,"Sending with ob_tag:",ob_tag,"for ob_id",ob_id,
     &             "fld3D",fld3D, "at myIter", myIter, "proc",mpiMyId
             print *,"Sending array shape: ", shape(buffer3D)
            endif


C           Send R8 array to master process
            print *,"In MPI_SEND for 3D,",
     &              "ob_levels3D(fld3D,ob_id)*(sNx+sNy)=",
     &              ob_levels3D(fld3D,ob_id)*(sNx+sNy)
            call MPI_SEND(buffer3D, ob_levels3D(fld3D,ob_id)*(sNx+sNy),
     &                    MPI_REAL8, 0, ob_tag, MPI_COMM_MODEL, ierror)

            if (send_debug .eq. 1) then
             DO k=1, ob_levels3D(fld3D,ob_id)
              print *,"printing at level k",k, "with ob_tag", ob_tag
              print*,buffer3D(:,k)
             ENDDO
            endif

           ENDDO
          end if
         end if

#endif


C----&------------------------------------------------------------------xxxxxxx|
C           Master Process Tasks:
C           1. Append Local Arrays in process 0
C           2. Receive time-averaged field values on open boundary points from
C              child processes > 0 through MPI and append to final array.
C           3. Write final output to binary file
C----&------------------------------------------------------------------xxxxxxx|
         IF (mpiMyId .eq. 0) then


          DO fld2D=1, ob_nFlds2D(ob_id)
            call OB_MASTER_PROC_TASKS(fld2D, ob_id, 2, myThid, myTime,
     &                                myIter)
          ENDDO

          DO fld3D=1, ob_nFlds3D(ob_id)
            call OB_MASTER_PROC_TASKS(fld3D, ob_id, 3, myThid, myTime,
     &                                myIter)
          ENDDO


C         !ENDIF for mpiMyId .eq. 0
         ENDIF
C       !ENDDO for ob_id
        ENDDO

C----&--------------------------------
C      Loop through the surface masks

C       Now looping through each surface mask and communicating fields between master process and child processes
        DO sf_id=1, nSF_mask

#ifdef ALLOW_USE_MPI
         if (mpiMyId .gt. 0) then
C         Processes 1 and onward send sub fields to master process
C         if they have open boundary points
          if (sf_numPnts_allproc(sf_id,mpiMyId+1) .ge. 1) then

           print *,"Yes going to send for sf mask", sf_id

           DO fldSF=1, sf_nFlds(sf_id)
C           Convert _RL array to R8 array
                call SF_PASS_RL_to_R8(bufferSF,sf_id,fldSF)
    
            sf_tag = sf_tags(sf_id, 1, fld2D)

            if (sf_send_debug .eq. 1) then
             print *,"Sending field ", sf_flds(fldSF,sf_id)
             print*,"Sending with sf_tag:",sf_tag,"for sf_id",sf_id,
     &             "fldSF",fldSF, "at myIter", myIter, "proc",mpiMyId
             print *,"Sending array shape: ", shape(bufferSF)
C             print *,"Sending array"
C             print *,bufferSF
             print *,"Calling MPI_SEND for SF"
             print *,"In MPI_SEND for SF, sNx*sNy=",sNx*sNy
            endif

              
C           Send R8 array to master process
C-SF                call MPI_SEND(bufferSF, sNx*sNy, MPI_REAL8, 0, sf_tag,
C-SF     &                    MPI_COMM_MODEL, ierror)
    
           ENDDO

          end if
         end if

#endif


C----&------------------------------------------------------------------xxxxxxx|
C           Master Process Tasks:
C           1. Append Local Arrays in process 0
C           2. Receive time-averaged field values on open boundary points from
C              child processes > 0 through MPI and append to final array.
C           3. Write final output to binary file
C----&------------------------------------------------------------------xxxxxxx|
         IF (mpiMyId .eq. 0) then
              print *,"Calling SF_MASTER_PROC_TASKS"
          DO fldSF=1, sf_nFlds(sf_id)
            call SF_MASTER_PROC_TASKS(fldSF, sf_id, myThid, myTime,
     &                                myIter)
          ENDDO

C         !ENDIF for mpiMyId .eq. 0
         ENDIF
C       !ENDDO for sf_id
        ENDDO

C----------------------------------------------------


C      !ENDIF for end of averaging period

C      Set averages back to zero
       CALL SET_TO_INI_STATE(myThid)

C      Incrementing number of time levels passed
       time_level = time_level + 1

C     C     !ENDIF for end of averaging period
      ENDIF
C      Move on to next time step
       nTimeSteps_ob = nTimeSteps_ob + 1
       time_passed = time_passed + deltaTClock

      RETURN
      END








C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|

      SUBROUTINE OB_MASTER_PROC_TASKS(fld, ob_id, nDim, myThid, myTime,
     &                             myIter)
C     Appending subFields to final global_ob array
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "DIAGNOSTICS_OB.h"

C     Input Parameters:
C     fld :: current field number
C     ob_id :: current mask number
C     nDim :: number of dimensions of field to output
C     myThid :: thread number
C     myTime :: current time in model
      INTEGER fld, ob_id, nDim, myThid, myIter
      _RL myTime
      REAL*8 buffer2D(sNx+sNy)
      REAL*8 buffer3D(sNx+sNy, Nr)

      _RS dummyRS(1)
      INTEGER pid, status(MPI_STATUS_SIZE), ierror, tag
      INTEGER total_valid, i, k, count
      INTEGER, PARAMETER :: debug = 1
      INTEGER, PARAMETER :: recv_debug = 0
      INTEGER, PARAMETER :: write_to_binary = 0


      common / local_var / total_valid
      common / mpi_var / status, ierror

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
C     - Indices referring to process IDs begin with 1 in ob_numPnts_allproc and
C          subFieldOnMask_2Davg
C-------------------------------------------------------------------------------
      if (debug .eq. 1) then
       print *,"MASTER: ob_numPnts_allproc ",
     &            ob_numPnts_allproc(ob_id,1), "at ob_id",ob_id
      endif

      IF (ob_numPnts_allproc(ob_id,1).ge.1) then
       if (nDim .eq. 2) then

        call OB_PASS_RL_to_R8(buffer2D, buffer3D, ob_id, 2,fld)
C       Append process 0's 2D time-averaged field value on OB points to final array
        call APPEND_OB_VALUE2D(ob_id, 0, buffer2D)
C       Add onto total number of OB points
        total_valid = total_valid + ob_numPnts_allproc(ob_id, 1)

        if (debug .eq. 1) then
         print *,"MASTER 2D: mask number:", ob_id, ",field",
     &            ob_flds2D(fld,ob_id)
         print *,"MASTER 2D: appended local field to global array"
     &          ," with ",ob_numPnts_allproc(ob_id, 1),"valid elements:"
         print *,"MASTER 2D: global_ob2D: with total_valid",total_valid
         call PRINT_FLOAT_ARR(global_ob2D, total_valid)
        end if

       else if (nDim .eq. 3) then
        print *,"MASTER3D: 3 dimensional field appending local field",
     &           ob_flds3D(fld,ob_id)
        call OB_PASS_RL_to_R8(buffer2D, buffer3D, ob_id, 3,fld)
C       Append process 0's 3D time-averaged field value on OB points to final array
        call APPEND_OB_VALUE3D(ob_id, 0, fld, buffer3D)
C       Add onto total number of OB points
        total_valid = total_valid + ob_numPnts_allproc(ob_id, 1)

        if (debug .eq. 1) then
         print *,"MASTER 3D: mask number:", ob_id
         print *,"MASTER 3D: appended local field to global array"
     &          ," with ",ob_numPnts_allproc(ob_id, 1),"valid elements:"
         do k=1, ob_levels3D(fld,ob_id)
          print *,"MASTER 3D: global_ob3D at depth",k,"with total_valid"
     &            ,total_valid
C          call PRINT_FLOAT_ARR(global_ob3D(:,k), total_valid)
         enddo
        end if
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
        IF (ob_numPnts_allproc(ob_id,pid+1) .ge. 1) then

         if (debug .eq. 1) then
          print *,"MASTER: DO pid loop to receive with MPI"
          print*,"MASTER: ",ob_numPnts_allproc(ob_id,pid+1),
     &           "elements for mask", ob_id, "at pid",pid
          print *,"MASTER: time to receive",
     &                    ob_numPnts_allproc(ob_id,pid+1), "elements"
         endif

         IF (nDim .eq. 2) then
          tag = ob_tags(ob_id, 1, fld)
C         !MPI_RECV params: received_data, receive_count, receive_type, sender_ID, tag, comm, status, ierror
C         Master process receiving time-averaged 2Dfield values on OB points from process pid
          call MPI_RECV(buffer2D, sNx+sNy, MPI_REAL8,
     &                   pid, tag ,MPI_COMM_MODEL, status, ierror)

          if (recv_debug .eq. 1) then
           print *, "MASTER 2D Received from process", pid
           print *, "MASTER Received buffer2D for field ",
     &                ob_flds2D(fld, ob_id)
           print *, "MASTER buffer2D shape:", shape(buffer2D)
           print *, "MASTER Displaying FULL 2D array, beyond number of"
     &                       ," valid elements"
           print *,buffer2D
          end if
C         Appending the received time-averaged 2D field values on OB points from process pid
          call APPEND_OB_VALUE2D(ob_id, pid, buffer2D)

         ELSE IF (nDim .eq. 3) then

          tag = ob_tags(ob_id, 2, fld)
C         !MPI_RECV params: received_data, receive_count, receive_type, sender_ID, tag, comm, status, ierror
C         Master process receiving time-averaged 3Dfield values on OB points from process pid
          call MPI_RECV(buffer3D(:,1:ob_levels3D(fld,ob_id)),
     &           ob_levels3D(fld,ob_id)*(sNx+sNy), MPI_REAL8, pid,
     &           tag ,MPI_COMM_MODEL, status, ierror)

          if (recv_debug .eq. 1) then
            print *, "MASTER 3D Received from process",pid,"tag",tag
            print *, "MASTER Received buffer3D for field ",
     &                ob_flds3D(fld, ob_id)
            print *, "MASTER buffer3D shape:", shape(buffer3D)
            print *, "MASTER Displaying FULL 3D array, beyond number of"
     &                       ," valid elements"
            DO k=1, ob_levels3D(fld,ob_id)
             print *,"printing at level k", k
             print*,buffer3D(:,k)
            ENDDO
          end if

C         !append_ob_values3D params: ob_id, pid, fld, ob_values
          call APPEND_OB_VALUE3D(ob_id,pid, fld, buffer3D)

         ENDIF
C        Keeping count of total number of OB points for each mask
         total_valid = total_valid + ob_numPnts_allproc(ob_id, pid+1)

C       !ENDIF for number of valid elements
        ENDIF

C      !ENDDO for pid
       ENDDO
#endif
C------End of receiving arrays through MPI and appending------------------------

C      Plotting final output into a Nx by Ny array for debugging
       if (debug .eq. 1) then
        print *,"MASTER: For mask", ob_id
        print *,"Plotting final array at time", myTime
       end if
C       call PLOT_TEST_GLOBAL_OB(myThid, ob_id, fld, nDim, myIter)

C      Writing final output to binary file
       print *,"WRITE TO FILE FOR MASK",ob_id
       call WRITE_GLOBAL_BIN_OB(total_valid,fld,ob_id,myIter,nDim)


      END
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|











C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
      SUBROUTINE SF_MASTER_PROC_TASKS(fld, sf_id, myThid, myTime,
     & myIter)
C     Appending subFields to final global_ob array
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "DIAGNOSTICS_OB.h"

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
      INTEGER pid, status(MPI_STATUS_SIZE), ierror, tag
      INTEGER total_valid, i, k, count
      INTEGER, PARAMETER :: debug = 1
      INTEGER, PARAMETER :: recv_debug = 1
      INTEGER, PARAMETER :: write_to_binary = 0
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
      common / local_var / total_valid
      common / mpi_var / status, ierror

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
      call APPEND_SF_VALUE(sf_id,0,bufferSF)
      
      if (debug .eq. 1) then
       print *,"MASTER: sf_numPnts_allproc ",
     &            sf_numPnts_allproc(sf_id,1), "at sf_id",sf_id
      endif

      IF (sf_numPnts_allproc(sf_id,1).ge.1) then

        call SF_PASS_RL_to_R8(bufferSF, sf_id, fld)
C       Append process 0's 2D time-averaged field value on OB points to final array
        call APPEND_SF_VALUE(sf_id, 0, bufferSF)
C       Add onto total number of OB points
        total_valid = total_valid + sf_numPnts_allproc(sf_id, 1)

        if (debug .eq. 1) then
         print *,"MASTER SF: mask number:", sf_id, ",field",
     &            sf_flds(fld,sf_id)
         print *,"MASTER SF: appended local field to global array"
     &          ," with ",sf_numPnts_allproc(sf_id, 1),
     &          "valid elements:"
         print *,"MASTER SF: global_SF: with total_valid",total_valid
         call PRINT_FLOAT_ARR(global_SF, total_valid)
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
        IF (sf_numPnts_allproc(sf_id,pid+1) .ge. 1) then

         if (debug .eq. 1) then
          print *,"MASTER SF: DO pid loop to receive with MPI"
          print*,"MASTER SF: ",sf_numPnts_allproc(sf_id,pid+1),
     &           "elements for mask", sf_id, "at pid",pid
          print *,"MASTER SF: time to receive",
     &                    sf_numPnts_allproc(sf_id,pid+1), "elements"
         endif

         tag = sf_tags(sf_id, 1, fld)
C        !MPI_RECV params: received_data, receive_count, receive_type, sender_ID, tag, comm, status, ierror
C        Master process receiving time-averaged 2Dfield values on OB points from process pid
C-SF         call MPI_RECV(bufferSF, sNx*sNy, MPI_REAL8,
C-SF     &                  pid, tag ,MPI_COMM_MODEL, status, ierror)

         if (recv_debug .eq. 1) then
          print *, "MASTER SF Received from process", pid
          print *, "MASTER Received bufferSF for field ",
     &               sf_flds(fld, sf_id)
          print *, "MASTER bufferSF shape:", shape(bufferSF)
          print *, "MASTER Displaying FULL 2D array, beyond number of"
     &                      ," valid elements"
          print *,bufferSF
         end if
C        Appending the received time-averaged 2D field values on OB points from process pid
         call APPEND_SF_VALUE(sf_id, pid, bufferSF)

C        Keeping count of total number of OB points for each mas
         total_valid = total_valid + sf_numPnts_allproc(sf_id, pid+1)

C       !ENDIF for number of valid elements
        ENDIF

C      !ENDDO for pid
       ENDDO
#endif
C------End of receiving arrays through MPI and appending------------------------

C      Plotting final output into a Nx by Ny array for debugging
       if (debug .eq. 1) then
        print *,"MASTER: For mask", sf_id
        print *,"Plotting final array at time", myTime
       end if
       call PLOT_TEST_GLOBAL_SF(myThid, sf_id, fld, nDim, myIter)

C      Writing final output to binary file
       print *,"WRITE TO FILE FOR MASK",sf_id
       call WRITE_GLOBAL_BIN_SF(total_valid,fld,sf_id,myIter,nDim)


      END
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|








C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
      SUBROUTINE APPEND_OB_VALUE2D(ob_id, pid, ob_values)
C       Appends field value corresponding to open boundary points to final global array global_ob.
C       Use values of global_indices to extract value in lookup_table at position of value of global_indices.
C       Value in lookup_table used to identify position of current point on open boundary.
C       Store field value at position in final global array global_ob.
C       NOTE: for details on lookup table and global indices, look at diagnostics_ob_init_fixed.F

#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "DIAGNOSTICS_OB.h"

         REAL*8 ob_values(sNx+sNy)
         INTEGER num_valid, i, ob_index, ob_id, pid
         INTEGER, PARAMETER :: print_debug = 0
C------------------------------------------------------------------------------|
C------------------------------------------------------------------------------|
         ob_index = 1
         num_valid = ob_numPnts_allproc(ob_id,pid+1)


         do i=1, num_valid
C          Extracting ob_index from lookup table using global index for OB point i in process pid
           ob_index = ob_lookup_table(ob_id,
     &                 ob_sub_glo_indices_allproc(ob_id,pid+1,i))
C          Inserting time-averaged field value on OB point i in index ob_index of the final array, global_ob2D
           global_ob2D(ob_index) = ob_values(i)
         end do
         if (print_debug .eq. 1) then
           print *,"global_ob2D shape",shape(global_ob2D)
           print *, "APPEND_OB_VALUE2D: global_ob2D:"
           call PRINT_FLOAT_ARR(global_ob2D, (sNy+sNx)*(nPx*nPy))
         end if

       END
C------------------------------------------------------------------------------|
C------------------------------------------------------------------------------|








C------------------------------------------------------------------------------|
C------------------------------------------------------------------------------|
       SUBROUTINE APPEND_OB_VALUE3D(ob_id, pid, fld, ob_values)
C       Appends field value corresponding to open boundary points to final global array global_ob.
C       Use values of global_indices to extract value in lookup_table at position of value of global_indices.
C       Value in lookup_table used to identify position of current point on open boundary.
C       Store field value at position in final global array global_ob.
C       NOTE: for details on lookup table and global indices, look at diagnostics_ob_init_fixed.F

#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "DIAGNOSTICS_OB.h"

        REAL*8 ob_values(sNx+sNy, Nr)
        INTEGER num_valid, i, k, ob_index, ob_id, pid, fld, glo
        INTEGER, PARAMETER :: print_debug = 0
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
        ob_index = 1
        num_valid = ob_numPnts_allproc(ob_id,pid+1)

        if (print_debug .eq. 1) then
          print *,"APPEND_OB_VALUE3D: mask", ob_id
          print *,"APPEND_OB_VALUE3D: field", ob_flds3D(fld,ob_id)
          print *,"APPEND_OB_VALUE3D: pid",pid
          print *,"APPEND_OB_VALUE3D: subglo",
     &      ob_sub_glo_indices_allproc(ob_id,pid+1,:)

        endif

        do i=1, num_valid
C        Extracting ob_index from lookup table using global index for OB point i in process pid
         ob_index = ob_lookup_table(ob_id,
     &                 ob_sub_glo_indices_allproc(ob_id,pid+1,i))

         glo = ob_sub_glo_indices_allproc(ob_id,pid+1,i)

         if (print_debug .eq. 1) then
           print *,"APPEND_OB_VALUE3D: glo", glo
           print *, "APPEND_OB_VALUE3D: ob_index", ob_index
           print *, "APPEND_OB_VALUE3D: counter i",i
           print*,"ob_values at k=1",ob_values(i,1)
         endif
C        Inserting time-averaged field value on OB point i in index ob_index of
C        the final array, global_ob3D for each depth
         do k=1, ob_levels3D(fld,ob_id)
          global_ob3D(ob_index,k) = ob_values(i,k)
         enddo
       enddo

       if (print_debug .eq. 1) then
         do k=1, ob_levels3D(fld,ob_id)
          print*,"For fld",fld," and mask",ob_id
          print *, "APPEND_OB_VALUE: global_ob3D with total depth:",
     &       ob_levels3D(fld, ob_id), "printing for depth #",k
          print*,"APPEND_OB_VALUE ob_values:",ob_values(1:num_valid,k)
          print *,"APPEND_OB_VALUE global_ob3D",
     &      global_ob3D(1:num_valid,k)
         enddo
         print*,"FINAL: pid",pid,"obid:",ob_id
         print*,"FINAL 3D glo arr",
     &           ob_sub_glo_indices_allproc(ob_id,pid+1,:)
       end if

       END
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|







C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
      SUBROUTINE APPEND_SF_VALUE(sf_id, pid, sf_values)
C       Appends field value corresponding to surface points to final global 
C       array global_sf.

#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "DIAGNOSTICS_OB.h"

         REAL*8 sf_values(sNx*sNy)
         INTEGER num_valid, i, sf_index, sf_id, pid
         INTEGER, PARAMETER :: print_debug = 0

C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
         ob_index = 1
         num_valid = sf_numPnts_allproc(ob_id,pid+1)

         do i=1, num_valid
C          Extracting sf_index from lookup table using global index for SF point i in process pid
           sf_index = sf_lookup_table(sf_id,
     &                 sf_sub_glo_indices_allproc(sf_id,pid+1,i))
C          Inserting time-averaged field value on SF point i in index sf_index of the final array, global_SF
           global_SF(sf_index) = sf_values(i)
         end do
         if (print_debug .eq. 1) then
           print *,"global_SF shape",shape(global_SF)
           print *, "APPEND_SF_VALUE: global_SF:"
           call PRINT_FLOAT_ARR(global_SF, (sNy*sNx)*(nPx*nPy))
         end if

       END
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|








C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
       SUBROUTINE OB_PASS_RL_to_R8(buffer2D, buffer3D, ob_id, nDim,fld)
#include "SIZE.h"
#include "EEPARAMS.h"
#include "DIAGNOSTICS_OB.h"

         REAL*8 buffer2D(sNx + sNy)
         REAL*8 buffer3D(sNx + sNy, Nr)
         INTEGER ob_id, nDim, fld
         INTEGER i,k
         INTEGER, PARAMETER :: debug = 0
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
         IF (nDim .eq. 2) then
           DO i=1, sNx+sNy
             buffer2D(i) = subFieldOnMask_2Davg(ob_id,fld,i)
           ENDDO

         ELSE IF (nDim .eq. 3) then
           DO i=1, sNx+sNy
             DO k=1,ob_levels3D(fld,ob_id)
               buffer3D(i,k) = subFieldOnMask_3Davg(ob_id,fld,i,k)
             ENDDO
           ENDDO

           if (debug .eq. 1) then
            DO k=1, ob_levels3D(fld,ob_id)
             print *,"At level k:",k
             print*, "buffer3D:",buffer3D(:,k)
             print*,"subFieldOnMask_3Davg:",
     &                   subFieldOnMask_3Davg(ob_id,fld,:,k)
            ENDDO
           endif

         ENDIF

       END
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|







C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|

       SUBROUTINE SF_PASS_RL_to_R8(bufferSF, sf_id, fld)
#include "SIZE.h"
#include "EEPARAMS.h"
#include "DIAGNOSTICS_OB.h"

         REAL*8 bufferSF(sNx*sNy)
         INTEGER sf_id, nDim, fld
         INTEGER i,k
         INTEGER, PARAMETER :: debug = 0
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|

          DO i=1, sNx*sNy
            bufferSF(i) = subFieldOnMask_SFavg(sf_id,fld,i)
          ENDDO

       END
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|






C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|

       SUBROUTINE PLOT_TEST_GLOBAL_OB(myThid, ob_id, fld, nDim, myIter)
c      Unravels global_ob and plots onto an array with dimensions Nx by Ny

#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "DYNVARS.h"
#include "DIAGNOSTICS_OB.h"

       REAL*8 global_NxNy(Nx,Ny,nSx,nSy)
       _RS dummyRS(1)
       REAL*8 global_theta(Nx,Ny)

       INTEGER i,j, bi, bj, k, counter, ob_counter, correct
       INTEGER fld, total_valid, ob_id, myThid, nDim, myIter
       INTEGER, PARAMETER :: plot_on_NxNy = 1

       character*8 fldNm
       character*30 plotTitle
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|

C       common / local_var / global_mask, total_valid
       common / local_var / total_valid

       fldNm = ' '

       if (nDim .eq. 2) then
         fldNm = ob_flds2D(fld, ob_id)
       else if (nDim .eq. 3) then
         fldNm = ob_flds3D(fld, ob_id)
       endif


C       Initialize NxNy array:

        DO bj = myByLo(myThid), myByHi(myThid)
          DO bi = myBxLo(myThid), myBxHi(myThid)
            DO j=1, Ny
              DO i=1, Nx
                global_NxNy(i,j,bi,bj) = 0.0
              ENDDO
            ENDDO
          ENDDO
        ENDDO


C      If lookup table contains ob mask point location (1-90) then extract corresponding point in global_ob at location
       correct = 1
       counter = 1
       ob_counter = 1
       DO bj = myByLo(myThid), myByHi(myThid)
         DO bi = myBxLo(myThid), myBxHi(myThid)
           DO j=1, Ny
             DO i=1, Nx
               if (ob_counter .le. total_valid) then
                 if (ob_lookup_table(ob_id,counter).eq.ob_counter) then
C                 !Inserting field points into NxNy array
                  if (nDim .eq. 2) then
                   global_NxNy(i,j,bi,bj) = global_ob2D(ob_counter)
                  else if  (nDim .eq. 3) then
                   global_NxNy(i,j,bi,bj) =
     &             global_ob3D(ob_counter,(ob_levels3D(fld,ob_id)/2)+1)
                  endif
                  ob_counter = ob_counter + 1
                 end if
               end if
               counter = counter + 1
             ENDDO
           ENDDO
         ENDDO
       ENDDO

       if (plot_on_NxNy .eq. 1) then
         print *, "PLOT_TEST_GLOBAL_OB: plotting global_ob ",
     &              "on NxNy dimension array:"
         write(plotTitle, "(2A)") "PLOT_TEST_GLOBAL_OB: ", fldNm
         call PLOT_GLO_FIELD_XYRL(global_NxNy,plotTitle,myThid)

         write(plotTitle, "(A,I1)") "PLOT_TEST_GLOBAL_OB mask ",ob_id
         CALL PLOT_GLO_FIELD_XYRL(global_ob_mask(ob_id,:,:,:,:),
     &                    plotTitle, myThid)
       end if


       END
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|






C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|

       SUBROUTINE PLOT_TEST_GLOBAL_SF(myThid, sf_id, fld,myIter)
c      Unravels global_ob and plots onto an array with dimensions Nx by Ny

#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "DYNVARS.h"
#include "DIAGNOSTICS_OB.h"

       REAL*8 global_NxNy(Nx,Ny,nSx,nSy)
       _RS dummyRS(1)
       REAL*8 global_theta(Nx,Ny)

       INTEGER i,j, bi, bj, k, counter, sf_counter, correct
       INTEGER fld, total_valid, sf_id, myThid, myIter
       INTEGER, PARAMETER :: plot_on_NxNy = 1

       character*8 fldNm
       character*30 plotTitle
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|

C       common / local_var / global_mask, total_valid
       common / local_var / total_valid

       fldNm = ' '

       fldNm = sf_flds(fld, sf_id)


C       Initialize NxNy array:

        DO bj = myByLo(myThid), myByHi(myThid)
          DO bi = myBxLo(myThid), myBxHi(myThid)
            DO j=1, Ny
              DO i=1, Nx
                global_NxNy(i,j,bi,bj) = 0.0
              ENDDO
            ENDDO
          ENDDO
        ENDDO


C      If lookup table contains ob mask point location (1-90) then extract corresponding point in global_ob at location
       correct = 1
       counter = 1
       sf_counter = 1
       DO bj = myByLo(myThid), myByHi(myThid)
         DO bi = myBxLo(myThid), myBxHi(myThid)
           DO j=1, Ny
             DO i=1, Nx
               if (sf_counter .le. total_valid) then
                 if (sf_lookup_table(sf_id,counter).eq.sf_counter) then
C                 !Inserting field points into NxNy array
                  global_NxNy(i,j,bi,bj) = global_SF(sf_counter)
                  sf_counter = sf_counter + 1
                 end if
               end if
               counter = counter + 1
             ENDDO
           ENDDO
         ENDDO
       ENDDO

       if (plot_on_NxNy .eq. 1) then
         print *, "PLOT_TEST_GLOBAL_OB: plotting global_sf ",
     &              "on NxNy dimension array:"
         write(plotTitle, "(2A)") "PLOT_TEST_GLOBAL_OB: ", fldNm
         call PLOT_GLO_FIELD_XYRL(global_NxNy,plotTitle,myThid)

         write(plotTitle, "(A,I1)") "PLOT_TEST_GLOBAL_OB mask ",sf_id
         CALL PLOT_GLO_FIELD_XYRL(global_sf_mask(sf_id,:,:,:,:),
     &                    plotTitle, myThid)
       end if


       END
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|









C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
       SUBROUTINE PRINT_INT_ARR(array, arr_length)
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
c      Edit Descriptor:
c       w: the number of positions to be used
c       m: the minimum number of positions to be used
c       d: the number of digits to the right of the decimal point
c       e: the number of digits in the exponent part

c       Reading/writing REALs Decimal form Fw.d
        INTEGER arr_length, i
        INTEGER array(arr_length)
        do, i=1, arr_length
          write(*,"(I5,$)") array(i)
            if (i .EQ. arr_length) then
               write(*, '(A,/)') ''
            end if
        end do
        print *, " "
        END
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|





C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
       SUBROUTINE PRINT_FLOAT_ARR(array, arr_length)
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
c      Edit Descriptor:
c       w: the number of positions to be used
c       m: the minimum number of positions to be used
c       d: the number of digits to the right of the decimal point
c       e: the number of digits in the exponent part

c       Reading/writing REALs Decimal form Fw.d
        INTEGER arr_length, i
        _RL array(arr_length)
        do, i=1, arr_length
          write(*,"(F9.3,$)") array(i)
            if (i .EQ. arr_length) then
               write(*, '(A,/)') ''
            end if
        end do
        print *, " "
        END

CEOC
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|





C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP 0
C !ROUTINE: PLOT_GLO_FIELD_XYRL

C !INTERFACE:
      SUBROUTINE PLOT_GLO_FIELD_XYRL(fld, fldNam, myThid)

C     !DESCRIPTION:
C     [description here]

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"

C     !INPUT/OUTPUT PARAMETERS:
C     fld - Field to plot
C     fldNam - Name of field
C     myIter - Iteration number for plot
C     myThid - Thread id of thread instance calling plot_field
      _RL fld(Nx, Ny, nSx, nSy)
      CHARACTER*(*) fldNam
      INTEGER myThid

C     !LOCAL VARIABLES:
       CHARACTER*(MAX_LEN_MBUF) fldTitle
       INTEGER iStart, iEnd, iStride
       INTEGER jStart, jEnd, jStride
       INTEGER kStart, kEnd, kStride
       INTEGER biStart, biEnd, biStride
       INTEGER bjStart, bjEnd, bjStride

CEOP
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|

C      This subroutine builds off subroutine PLOT_FIELD_XYRS:
C     /==========================================================\
C     | SUBROUTINE PLOT_FIELD_XYRS                               |
C     | Print out an XY _RS field using text map.                |
C     |==========================================================|
C     | This routine references "numerical model" parameters     |
C     | like the integration time. It uses these to create a     |
C     | title for the field before calling a generic execution   |
C     | environment support routine.                             |
C     | This routine can also be edited to cause only some region|
C     | of a field to be printed by default, or every other      |
C     | point etc..                                              |
C     | Other plot formats can also be substituted here.         |
C     | _RS is usually REAL*4                                    |
C     \==========================================================/

C----&------------------------------------------------------------------xxxxxxx|
CBOC
       
C--   To get around synchronisation and multi-threaded I/O issues
C--   thread 1 will do all the writes.
       _BARRIER
C       IF ( myThid .EQ. 1 ) THEN
C--    Form name for identifying "plot"
        WRITE(fldTitle,'(A,A)') '// Field ', fldNam
C       ENDIF
C--    Do "plot" using textual contour map "execution environment" routine
C      Substitute other plotting utilities here!
        iStart   =  1
        iEnd     =  Nx
        iStride  =  1
        jStart   =  Ny
        jEnd     =  1
        jStride  = -1
        kStart   =  1
        kEnd     =  1
        kStride  =  1
        biStart  =  1
        biEnd    =  nSx
        biStride =  1
        bjStart  =  nSy
        bjEnd    =  1
        bjStride = -1
        CALL PRINT_MAPRL(
     &        fld, fldTitle, PRINT_MAP_XY,
     &         1,Nx,1,Ny,1,1,  nSx,  nSy,
     &         iStart,   iEnd,  iStride,
     &         jStart,   jEnd,  jStride,
     &         kStart,   kEnd,  kStride,
     &        biStart,  biEnd, biStride,
     &        bjStart,  bjEnd, bjStride )

       _BARRIER

       RETURN
       END
CEOC
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|