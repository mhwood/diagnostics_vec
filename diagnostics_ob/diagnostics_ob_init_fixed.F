C----&------------------------------------------------------------------xxxxxxx|
C                         diagnostics_ob_init_fixed
C----&------------------------------------------------------------------xxxxxxx|

#include "DIAGNOSTICS_OB_OPTIONS.h"






C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: DIAGNOSTICS_OB_INIT_FIXED

C !INTERFACE:
      SUBROUTINE DIAGNOSTICS_OB_INIT_FIXED( myThid )

C     !DESCRIPTION:
C     Initialize DIAGNOSTICS_OB variables that are kept fixed during the run.

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "DIAGNOSTICS_OB.h"

C     !INPUT/OUTPUT PARAMETERS:
C     myThid ::  my Thread Id number
      INTEGER myThid

C     !LOCAL VARIABLES:
C     i, j, k, l :: domain counters
C     bi, bj :: mpi counters
      INTEGER i,j,k,l, bi,bj, fld, ob_id, counter, pid
      INTEGER sf_id
      INTEGER, PARAMETER :: debug = 1
CEOP
C----&------------------------------------------------------------------xxxxxxx|


#ifdef ALLOW_MNC
      IF (useMNC) THEN
        CALL DIAGNOSTICS_OB_MNC_INIT( myThid )
      ENDIF
#endif /* ALLOW_MNC */

#ifdef ALLOW_DIAGNOSTICS
      IF ( useDiagnostics ) THEN
        CALL DIAGNOSTICS_OB_INIT( myThid )
      ENDIF
#endif

C----&------------------------------------------------------------------xxxxxxx|
C     Initialize diagnostics_ob COMMON block variables:
C----&------------------------------------------------------------------xxxxxxx|

C     /==================================================================\
C     | Note: The variables below are defined within DIAGNOSTICS_OB.h    |
C     \==================================================================/


#ifdef ALLOW_DIAGNOSTICS_OB

C     This is in the initialization of the boundary variables

      DO i=1, (sNy+sNx)*(nPx*nPy)
        global_ob2D(i) = 0.0
        DO k=1, Nr
          global_ob3D(i,k) = 0.0
        ENDDO
      ENDDO

      DO ob_id=1, nOB_mask

        DO l = 1, Ny*Nx
          ob_lookup_table(ob_id,l) = 0
        ENDDO

        DO pid=1, nPx*nPy
          ob_numPnts_allproc(ob_id,pid) = 0
        ENDDO

        DO i=1,2
          DO j=1, sNx+sNy
            ob_sub_local_ij(ob_id, i, j) = 0
          ENDDO
        ENDDO

        DO i=1, sNx+sNy
          DO fld=1, MAX_NFLDS
            subFieldOnMask_2D(ob_id, fld, i) = 0.0
            subFieldOnMask_2Davg(ob_id, fld, i) = 0.0
            DO k=1, Nr
              subFieldOnMask_3D(ob_id, fld, i, k) = 0.0
              subFieldOnMask_3Davg(ob_id, fld, i, k) = 40.0
            ENDDO
          ENDDO
        ENDDO

        DO bj = myByLo(myThid), myByHi(myThid)
         DO bi = myBxLo(myThid), myBxHi(myThid)
          DO i=1, Nx
            DO j=1, Ny
              global_ob_mask(ob_id,i,j,bi,bj) = 0.0
            ENDDO
          ENDDO

          DO j=1-OLy,sNy+OLy
            DO i=1-OLx,sNx+OLx
                ob_subMask(ob_id,i,j,bi,bj)   = 0.0
            ENDDO
          ENDDO
         ENDDO
        ENDDO

        DO i=1, nPx*nPy
          ob_numPnts_allproc(ob_id, i) = 0
          DO j=1, sNx+sNy
            ob_sub_glo_indices_allproc(ob_id,i,j) = 0
          ENDDO
        ENDDO

      ENDDO

C     This is in the initialization of the surface variables

      DO i=1, (sNy+sNx)*(nPx*nPy)
        global_SF(i) = 0.0
      ENDDO

      DO sf_id=1, nSF_mask

        DO l = 1, Ny*Nx
          sf_lookup_table(sf_id,l) = 0
        ENDDO

        DO pid=1, nPx*nPy
          sf_numPnts_allproc(sf_id,pid) = 0
        ENDDO

        DO i=1,2
          DO j=1, sNx+sNy
            sf_sub_local_ij(sf_id, i, j) = 0
          ENDDO
        ENDDO

        DO i=1, sNx+sNy
          DO fld=1, MAX_NFLDS
            subFieldOnMask_SF(sf_id, fld, i) = 0.0
            subFieldOnMask_SFavg(sf_id, fld, i) = 0.0
          ENDDO
        ENDDO

        DO bj = myByLo(myThid), myByHi(myThid)
         DO bi = myBxLo(myThid), myBxHi(myThid)
          DO i=1, Nx
            DO j=1, Ny
              global_sf_mask(sf_id,i,j,bi,bj) = 0.0
            ENDDO
          ENDDO

          DO j=1-OLy,sNy+OLy
            DO i=1-OLx,sNx+OLx
                sf_subMask(sf_id,i,j,bi,bj)   = 0.0
            ENDDO
          ENDDO
         ENDDO
        ENDDO

        DO i=1, nPx*nPy
          sf_numPnts_allproc(sf_id, i) = 0
          DO j=1, sNx+sNy
            sf_sub_glo_indices_allproc(sf_id,i,j) = 0
          ENDDO
        ENDDO

      ENDDO


C     Initializing number of time level passed to 1
      time_level = 1
      time_passed = 0.0

C----&------------------------------------------------------------------xxxxxxx|
C     Read in the masks
C----&------------------------------------------------------------------xxxxxxx|

C     Looping through each open boundary mask
      DO ob_id=1, nOB_mask

        print *,"INIT_FIXED: boundary mask number", ob_id
        print *,"OB_FNAME: ",ob_fnames(ob_id)

C       Read open boundary mask files and assign portion of open boundary mask to each process
        CALL READ_REC_XY_RL( ob_fnames(ob_id),
     &               ob_subMask(ob_id,:,:,:,:),1, 0, myThid )
C       Filling in halo regions of sub masks
        _EXCH_XY_RL(ob_subMask(ob_id,:,:,:,:), myThid)

C       Plotting for debugging
        CALL PLOT_FIELD_XYRL( ob_subMask(ob_id,:,:,:,:),
     &                'INIT_FIXED: Open Boundary Submask', -1, myThid )

#ifdef ALLOW_USE_MPI
        CALL IDENTIFY_OB_POINTS(ob_id, myThid)
#endif
      ENDDO


C     Looping through each surface mask
      DO sf_id=1, nSF_mask

        print *,"INIT_FIXED: surface mask number", sf_id
        print *,"SF_FNAME: ",sf_fnames(sf_id)

C       Read surface mask files and assign portion of surface mask to each process
        CALL READ_REC_XY_RL( sf_fnames(sf_id),
     &               sf_subMask(sf_id,:,:,:,:),1, 0, myThid )
C       Filling in halo regions of sub masks
        _EXCH_XY_RL(sf_subMask(sf_id,:,:,:,:), myThid)

C       Plotting for debugging
        CALL PLOT_FIELD_XYRL( sf_subMask(sf_id,:,:,:,:),
     &                'INIT_FIXED: Surface Submask', -1, myThid )

#ifdef ALLOW_USE_MPI
        CALL IDENTIFY_SF_POINTS(sf_id, myThid)
#endif
      ENDDO



#ifdef ALLOW_USE_MPI
      CALL SEND_CHILD_TO_MASTER()
#endif


C----&------------------------------------------------------------------xxxxxxx|
C     Initialize the lookup table
C----&------------------------------------------------------------------xxxxxxx|

C /==========================================================================\
C | Note: The master process stores all global open boundary masks into the  |
C |       lookup table.                                                      |
C |                                                                          |
C | Method Overview:                                                         |
C | 1. Uses GATHER_2D_R8 to correctly combine sub masks in to a single       | 
C |    global mask because when the open boundary mask is read it is only    |
C |    saved as sub masks for each child process.                            |
C |                                                                          |
C | 2. Stores each global mask into each ROW of lookup table                 |
C |    - Doing so essentially rehapes the global mask into a one dimensional |
C |      array in the lookup table.                                          |
C |    - The indices of the elements of the global mask in each row of the   |
C |      lookup table starts from 1 and ends at Nx*Ny.                       |
C |    - These indices are equivalent to the global indices each child       |
C |      process computes for the open boundaries in their sub masks.        |
C |      (Explained in detail in subroutineIDENTIFY_OB_POINTS)               |
C |                                                                          |
C \==========================================================================/


#ifdef ALLOW_USE_MPI

C ---- The Boundary Masks ---------------------------------------------------

      DO ob_id=1, nOB_mask

C ---- Using GATHER_2D_R8 to correctly combine sub masks into a global mask
C ---- Plotting for debugging

        CALL GATHER_2D_R8(global_ob_mask(ob_id,:,:,1,1),
     &                  ob_subMask(ob_id,1:sNx,1:sNy,1,1),
     &                  Nx, Ny, .true., .true., myThid)
        CALL PLOT_GLO_FIELD_XYRL(global_ob_mask(ob_id,:,:,:,:),
     &                    "INIT_FIXED: global ob mask", myThid)

C ---- Storing global_ob_masks into lookup table
C ---- Loops stores elements of each mask in global_ob_mask into each row 
C      of ob_lookup_table

C       Store global_ob_masks into lookup table
      IF (mpiMyId .eq. 0) then
        counter = 1
        DO bj = myByLo(myThid), myByHi(myThid)
         DO bi = myBxLo(myThid), myBxHi(myThid)
          do j=1, Ny, 1
            do i=1, Nx, 1
              ob_lookup_table(ob_id,counter) =
     &         int(global_ob_mask(ob_id,i,j,bi,bj))
              counter = counter + 1
            end do
           end do
          end do
        end do
      ENDIF

      ENDDO

#endif


#ifdef ALLOW_USE_MPI

C ---- The Surface Masks ---------------------------------------------------

      DO sf_id=1, nSF_mask

C ---- Using GATHER_2D_R8 to correctly combine sub masks into a global mask
C ---- Plotting for debugging

        CALL GATHER_2D_R8(global_sf_mask(sf_id,:,:,1,1),
     &                  sf_subMask(sf_id,1:sNx,1:sNy,1,1),
     &                  Nx, Ny, .true., .true., myThid)
        CALL PLOT_GLO_FIELD_XYRL(global_sf_mask(sf_id,:,:,:,:),
     &                    "INIT_FIXED: global sf mask", myThid)

C ---- Storing global_sf_masks into lookup table
C ---- Loops stores elements of each mask in global_sf_mask into each row 
C      of sf_lookup_table

C       Store global_sf_masks into lookup table
      IF (mpiMyId .eq. 0) then
        counter = 1
        DO bj = myByLo(myThid), myByHi(myThid)
         DO bi = myBxLo(myThid), myBxHi(myThid)
          do j=1, Ny, 1
            do i=1, Nx, 1
              sf_lookup_table(sf_id,counter) =
     &         int(global_sf_mask(sf_id,i,j,bi,bj))
              counter = counter + 1
            end do
           end do
          end do
        end do
      ENDIF

      ENDDO


#endif

C----&------------------------------------------------------------------xxxxxxx|

#endif /* ALLOW_DIAGNOSTICS_OB */


      RETURN
      END

CEOC
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|






C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: IDENTIFY_OB_POINTS

C !INTERFACE:
      SUBROUTINE IDENTIFY_OB_POINTS(ob_id, myThid)

C     !DESCRIPTION:
C     Locate open boundary points within global domain, see below for 
C     detailed explanation

#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "DIAGNOSTICS_OB.h"

C     !INPUT PARAMETERS:
      INTEGER ob_id, myThid

C     !LOCAL VARIABLES:     
      INTEGER global_index
      INTEGER counter, num_valid, iG, jG, i, j, bi, bj, ob
CEOP
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|

C     Located open boundary points
C     Saved local i j indices and global indices
C     Saved count of open boundary points in process' piece of global mask
C
C     Global Indices:
C     - Global indices are the positions of elements in a Nx by Ny array.
C       Position number starts from 1 and ends at Nx*Ny
C
C       [ 1,     2,     3,     4     ...     ,Nx]
C       [ Nx+1,  Nx+2,  Nx+3,  Nx+4, ...  ,Nx+Nx]
C       [ 2Nx+1, 2Nx+2, 2Nx+3, 2Nx+4,... ,2Nx+Nx]
C       [ 3Nx+1, 3Nx+2, 3Nx+3, 3Nx+4,... ,3Nx+Nx]
C       [ :                                     ]
C       [ :                                     ]
C       [ :                                     ]
C       [ (Ny-1)*Nx+1,        ...         ,Nx*Ny]
C
C     - We compute the global indices of open boundary points we find in each
C       child process in their assigned sub mask.
C
C       To do so, we essentially count the number of elements starting from the
C       first row and column of the Nx by Ny array until the element right before
C       the current element we are computing the global index for.
C
C       Example:
C       [ 1,     2,     3,               4,    ...    ,Nx]
C       [ Nx+1,  Nx+2,  Nx+3,            Nx+4, ... ,Nx+Nx]
C       [ 2Nx+1, 2Nx+2, current element                  ]
C       [                                                ]
C       [                                                ]
C       [                                                ]
C       [                                                ]
C
C       Total count of elements before current element = 2Nx+2.
C       Therefore, global index of current element is 2Nx+3.
C
C       However, we must compute the global indices of elements only located in
C       a submask without iterating through the entire Nx by Ny array (need to
C       reduce runtime).
C       Therefore, we first identify the i,j indices of the row 1 and column 1
C       of the sub mask in the Nx by Ny global mask with MITgcm's mpi_myXGlobalLo
C       and mpi_myYGlobalLo.
C       With the aid of these i,j indices in addition to knowing the dimensions
C       of the sub mask, we are able to know the number of rows before the row
C       containing point P of example with respect to the Nx by Ny global mask
C       as well as the number of elements before P in the same row.
C
C       Example: * are elements of sub mask inside Nx by Ny global mask:
C                P is an open boundary point for which we compute the global index
C       [               |                        ]
C       [            r rows                      ]
C       [               |                        ]
C       [           * * | * * * * *              ]
C       [---c points--- P * * * * *              ]
C       [           * * * * * * * *              ]
C       [           * * * * * * * *              ]
C       [           * * * * * * * *              ]
C       [           * * * * * * * *              ]
C       [                                        ]
C       [                                        ] :Nx by Ny array
C
C       Then, as we iterate through the points in sNx by sNy sub mask to locate
C       the open boundary points, we can apply the following formula to compute
C       the corresponding global indices:
C       where i denotes the point along the x axis of sNx by sNy submask
C             j denotes the point along the y axis of sNx by sNy submask
C             iG denotes the global i index of row 1 col 1 of submask
C             jG denotes the global j index of row 1 col 1 of submask
C
C       global_index = (r * Nx) + (c + 1)
C
C       Total number of elements from all rows above: r * Nx = (jG + (j-2))*Nx
C       Number of points including P in th same row: c + 1 = iG + (i-1)
C
C       Therefore,
C               global_index = (jG + (j-2))*Nx + iG + (i-1)
C
C     - These global indices will be used to extract values from the lookup table.
C
C
C----&------------------------------------------------------------------xxxxxxx|
CBOC

C     /==================================================================\
C     | Note: The variables below are defined within (?)                 |
C     \==================================================================/

      iG = mpi_myXGlobalLo(mpiMyId+1)
      jG = mpi_myYGlobalLo(mpiMyId+1)

      counter = 1
      num_valid = 0
      DO bj = myByLo(myThid), myByHi(myThid)
       DO bi = myBxLo(myThid), myBxHi(myThid)
         DO j=1,sNy
           DO i=1,sNx

             if (ob_subMask(ob_id,i,j,bi,bj) .ge. 1.0 ) then
C              Computing global index
C              old formula: works correctly, just too complicated
C              global_index = int(((j-1)*sNx+(j-1)*(Nx-(iG+sNx-1))+
C     &                       j*(iG-1)+i)+((jG-1)*Nx))
C              new formula: works correctly, simple
               global_index = int((jG + (j-2))*Nx + iG + (i-1))

C              First row contains local i's. Second row contains local j's.
               ob_sub_local_ij(ob_id, 1, counter) = i
               ob_sub_local_ij(ob_id, 2, counter) = j

C              Indices referring to process IDs begin with 1
               ob_sub_glo_indices_allproc(ob_id,mpiMyId+1,counter) =
     &           global_index

               counter = counter + 1
               num_valid = num_valid + 1
             end if
            ENDDO
          ENDDO
        ENDDO
      ENDDO

      ob_numPnts_allproc(ob_id,mpiMyId+1) = num_valid 
      END

CEOC
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|



C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: IDENTIFY_OB_POINTS

C !INTERFACE:
      SUBROUTINE IDENTIFY_SF_POINTS(sf_id, myThid)

C     !DESCRIPTION:
C     Locate open boundary points within global domain, see below for 
C     detailed explanation

#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "DIAGNOSTICS_OB.h"

C     !INPUT PARAMETERS:
      INTEGER sf_id, myThid

C     !LOCAL VARIABLES:     
      INTEGER global_index
      INTEGER counter, num_valid, iG, jG, i, j, bi, bj, ob
CEOP
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOC

C     /==================================================================\
C     | Note: The variables below are defined within (?)                 |
C     \==================================================================/

      iG = mpi_myXGlobalLo(mpiMyId+1)
      jG = mpi_myYGlobalLo(mpiMyId+1)

      counter = 1
      num_valid = 0
      DO bj = myByLo(myThid), myByHi(myThid)
       DO bi = myBxLo(myThid), myBxHi(myThid)
         DO j=1,sNy
           DO i=1,sNx

             if (sf_subMask(sf_id,i,j,bi,bj) .ge. 1.0 ) then
C              Computing global index
               global_index = int((jG + (j-2))*Nx + iG + (i-1))

C              First row contains local i's. Second row contains local j's.
               sf_sub_local_ij(sf_id, 1, counter) = i
               sf_sub_local_ij(sf_id, 2, counter) = j

C              Indices referring to process IDs begin with 1
               sf_sub_glo_indices_allproc(sf_id,mpiMyId+1,counter) =
     &           global_index

               counter = counter + 1
               num_valid = num_valid + 1
             end if
            ENDDO
          ENDDO
        ENDDO
      ENDDO

      sf_numPnts_allproc(sf_id,mpiMyId+1) = num_valid 
      END

CEOC
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|








C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: SUBROUTINE SEND_CHILD_TO_MASTER

C !INTERFACE:
      SUBROUTINE SEND_CHILD_TO_MASTER()

C     !DESCRIPTION:
C     Sending global indices and number of open boundary points from processes 
C     > 0 to master process

#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "DIAGNOSTICS_OB.h"

C     !LOCAL VARIABLES:
      INTEGER pid, ob_id, i, status(MPI_STATUS_SIZE), ierror
      INTEGER sf_id
      INTEGER g_ob_indices(sNx+sNy)
      INTEGER g_sf_indices(sNx+sNy)
      INTEGER num_pts
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


C---------------------------------------------------------------------------
C ---- This section is for the open boundaries

C ---- Here child process send global indices of ob points, and then
C      the count of the ob points

        IF (mpiMyId .gt. 0) then
          DO ob_id=1, nOB_mask
            print *,"INIT_FIXED: on_numPnts_allproc from proc",
     &              mpiMyId,":", ob_numPnts_allproc
            print *,"INIT_FIXED: BEFORE sub_glo_indices_allproc",
     &              ob_sub_glo_indices_allproc(ob_id,mpiMyId+1,:)
            call MPI_SEND(ob_sub_glo_indices_allproc(ob_id,mpiMyId+1,:),
     &             sNx+sNy, MPI_INT,0, ob_id, MPI_COMM_MODEL, ierror)
            call MPI_SEND(ob_numPnts_allproc(ob_id,mpiMyId+1),
     &             1, MPI_INT,0, ob_id*100, MPI_COMM_MODEL, ierror)
          ENDDO
        ENDIF

C ---- Here master process receives global indices from child process pid, 
C      and then the count of OB points from child process pid

        IF (mpiMyId .eq. 0) then
          DO pid=1, nPx*nPy-1
            DO ob_id=1, nOB_mask
              call MPI_RECV(g_ob_indices, sNx+sNy, MPI_INT,
     &                   pid, ob_id ,MPI_COMM_MODEL, status, ierror)
              call MPI_RECV(num_pts, 1, MPI_INT,
     &                   pid, ob_id*100 ,MPI_COMM_MODEL, status, ierror)

              DO i=1, sNx+sNy
               ob_sub_glo_indices_allproc(ob_id,pid+1,i) 
     &                   = g_ob_indices(i)
              ENDDO
              ob_numPnts_allproc(ob_id,pid+1) = num_pts
            ENDDO
          ENDDO
         ENDIF


C---------------------------------------------------------------------------
C ---- This section is for the surface

C ---- Here child process send global indices of sf points, and then
C      the count of the sf points

        IF (mpiMyId .gt. 0) then
          DO sf_id=1, nSF_mask
            print *,"INIT_FIXED: sf_numPnts_allproc from proc",
     &              mpiMyId,":", sf_numPnts_allproc
            print *,"INIT_FIXED: BEFORE sf_sub_glo_indices_allproc",
     &              sf_sub_glo_indices_allproc(sf_id,mpiMyId+1,:)
            call MPI_SEND(sf_sub_glo_indices_allproc(sf_id,mpiMyId+1,:),
     &             sNx+sNy, MPI_INT,0, sf_id, MPI_COMM_MODEL, ierror)
            call MPI_SEND(sf_numPnts_allproc(sf_id,mpiMyId+1),
     &             1, MPI_INT,0, sf_id*100, MPI_COMM_MODEL, ierror)
          ENDDO
        ENDIF

C ---- Here master process receives global indices from child process pid, 
C      and then the count of SF points from child process pid

        IF (mpiMyId .eq. 0) then
          DO pid=1, nPx*nPy-1
            DO sf_id=1, nSF_mask
              call MPI_RECV(g_sf_indices, sNx+sNy, MPI_INT,
     &                   pid, sf_id ,MPI_COMM_MODEL, status, ierror)
              call MPI_RECV(num_pts, 1, MPI_INT,
     &                   pid, sf_id*100 ,MPI_COMM_MODEL, status, ierror)

              DO i=1, sNx+sNy
               sf_sub_glo_indices_allproc(sf_id,pid+1,i) 
     &                   = g_sf_indices(i)
              ENDDO
              sf_numPnts_allproc(sf_id,pid+1) = num_pts
            ENDDO
          ENDDO
         ENDIF

       END

CEOC
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|