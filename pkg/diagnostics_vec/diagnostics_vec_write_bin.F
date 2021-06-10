C----&------------------------------------------------------------------xxxxxxx|
C                           diagnostics_vec_write_bin
C----&------------------------------------------------------------------xxxxxxx|
C Contributors: Michael Wood, Ian Fenty, April Shin

#include "DIAGNOSTICS_VEC_OPTIONS.h"

C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: WRITE_GLOBAL_BIN_VEC

C !INTERFACE:
      SUBROUTINE WRITE_GLOBAL_BIN_VEC(total_valid,fld,
     &    vec_id,myIter,nDim)

C     !USES:
      IMPLICIT NONE

#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "DIAGNOSTICS_VEC.h"

C     !INPUT PARAMETERS:
       INTEGER total_valid, vec_id, fld, nDim, myIter

C     !LOCAL VARIABLES:

CEOP
C----&------------------------------------------------------------------xxxxxxx|
C
C     /==================================================================\
C     | Description                                                      |
C     |==================================================================|
C     | WRITE_GLOBAL_BIN_VEC:                                            |
C     | This program writes the final output (global final array) to a   |
C     | binary file.                                                     |
C     |                                                                  |
C     |  Writes either a 32 bit precision or 64 bit precision file.      |
C     |  Two ways to write output:                                       |
C     |   1. Write all times levels into a single binary files           |
C     |         - Each time level is written into its own record in the  |
C     |           binary file                                            |
C     |   2. Write a separates binary file for each time level           |
C     |         - File names consist of iter number:                     |
C     |               MASK_VEC_NN_FIELD_ITER.bin                         |
C     |                                                                  |
C     | input params:                                                    |
C     | total_valid - total number of open boundary points to write      | 
C     | fld - field number                                               |
C     | vec_id - open boundary number                                    |
C     | myIter - current iter number                                     |
C     | nDim - number of dimensions in field (either 2D or 3D)           |
C     \==================================================================/
C
C----&------------------------------------------------------------------xxxxxxx|
CBOC 
       character*2 dir
       character*50 filename
       real*4 bufferR4_2D((sNy+sNx)*(nPx*nPy))
       real*4 bufferR4_3D((sNy+sNx)*(nPx*nPy), Nr)
       real*8 temp((sNy+sNx)*(nPx*nPy), Nr)
       integer, parameter :: debug = 0
       logical exists
       integer LEN, i

       LEN = 1
       dir = "./"

       IF (vec_filePrec .eq. 32) then

        IF (nDim .eq. 2) then
C       -----------------------------------------------------------------------
C       File precision: 32
C       Field dimension: 2
C       -----------------------------------------------------------------------
         call VEC_R8_to_R4(bufferR4_2D, bufferR4_3D,2,fld,vec_id)
         call CREATE_FILENAME_VEC(dir, vec_flds2D(fld,vec_id), vec_id,
     &                      filename,0, myIter)
         IF (combineMaskTimeLevels) then
C         Writing all time levels into a single binary file
          INQUIRE (IOLENGTH = LEN) bufferR4_2D(1:total_valid)
          INQUIRE (FILE=filename, EXIST=exists)
C         If file already exists, set status as 'old'. Otherwise, 'replace'
          if (exists) then
           open(1, FILE=filename, STATUS='OLD', ACCESS='DIRECT',
     &          RECL = LEN )
          else
           open(1, FILE=filename, STATUS='REPLACE', ACCESS='DIRECT',
     &          RECL = LEN )
          endif
          write(1, REC=time_level) bufferR4_2D(1:total_valid)
         ELSE
C         Write each time level into its own binary file
          open(1, FILE=filename, FORM="unformatted",ACCESS='STREAM')
          write(1) bufferR4_2D(1:total_valid)
         ENDIF
         close(1)


        ELSE IF (nDim .eq. 3) then
C       -----------------------------------------------------------------------
C       File precision: 32
C       Field dimension: 3
C       -----------------------------------------------------------------------
         call VEC_R8_to_R4(bufferR4_2D, bufferR4_3D,3,fld,vec_id)
         call CREATE_FILENAME_VEC(dir, vec_flds3D(fld,vec_id), vec_id, 
     &                      filename,0, myIter)
         IF (combineMaskTimeLevels) then
C        Writing all time levels into a single binary file
          INQUIRE (IOLENGTH = LEN) bufferR4_3D(1:total_valid,
     &          1:vec_levels3D(fld,vec_id))
          INQUIRE (FILE=filename, EXIST=exists)
C         If file already exists, set status as 'old'. Otherwise, 'replace'
          if (exists) then
           open( 1, FILE=filename, STATUS='OLD', ACCESS='DIRECT',
     &          RECL = LEN)
          else
           open( 1, FILE=filename, STATUS='REPLACE', ACCESS='DIRECT',
     &          RECL =  LEN)
          endif
          write(1, REC=time_level) bufferR4_3D(1:total_valid,
     &          1:vec_levels3D(fld,vec_id))
         ELSE
C         Write each time level into its own binary file
          open(1, FILE=filename, FORM="unformatted",ACCESS='STREAM')
          write(1) bufferR4_3D(1:total_valid,1:vec_levels3D(fld,vec_id))
         ENDIF
         close(1)

        ENDIF


       ELSE IF (vec_filePrec .eq. 64) then

        IF (nDim .eq. 2) then
C       -----------------------------------------------------------------------
C       File precision: 64
C       Field dimension: 2
C       -----------------------------------------------------------------------
         call CREATE_FILENAME_VEC(dir, vec_flds2D(fld,vec_id), vec_id,
     &                      filename,0, myIter)
         IF (combineMaskTimeLevels) then
          INQUIRE (IOLENGTH = LEN) global_vec2D(1:total_valid)
          INQUIRE (FILE=filename, EXIST=exists)
C         If file already exists, set status as 'old'. Otherwise, 'replace'
          if (exists) then
           open( 1, FILE=filename, STATUS='OLD', ACCESS='DIRECT',
     &          RECL = LEN )
          else
           open( 1, FILE=filename, STATUS='REPLACE', ACCESS='DIRECT',
     &          RECL = LEN )
          endif

          write(1, REC=time_level) global_vec2D(1:total_valid)
         ELSE
          open(1, FILE=filename, FORM="unformatted",ACCESS='STREAM')
          write(1) global_vec2D(1:total_valid)
         ENDIF
         close(1)


        ELSE IF (nDim .eq. 3) then
C       -----------------------------------------------------------------------
C       File precision: 64
C       Field dimension: 3
C       -----------------------------------------------------------------------
         call CREATE_FILENAME_VEC(dir, vec_flds3D(fld,vec_id), vec_id,
     &                      filename,0, myIter)

         IF (combineMaskTimeLevels) then
          INQUIRE (IOLENGTH = LEN) global_vec3D(1:total_valid,
     &                                   1:vec_levels3D(fld,vec_id))
          INQUIRE (FILE=filename, EXIST=exists)
C         If file already exists, set status as 'old'. Otherwise, 'replace'
          if (exists) then
           open( 1, FILE=filename, STATUS='OLD', ACCESS='DIRECT',
     &          RECL = LEN)
          else
           open( 1, FILE=filename, STATUS='REPLACE', ACCESS='DIRECT',
     &          RECL = LEN)
          endif
          write(1, REC=time_level) global_vec3D(1:total_valid,
     &                                      1:vec_levels3D(fld,vec_id))
          if (debug .eq. 1) then
C          Reading back from binary file for debugging
           do i=1, time_level
            read(1, REC=i) temp(1:total_valid,
     &                                    1:vec_levels3D(fld,vec_id))
            print*,"time level:",i
            print *,"TEMP: ",temp(1:total_valid,
     &                                    1:vec_levels3D(fld,vec_id))
           enddo
          endif
         ELSE
          open(1, FILE=filename, FORM="unformatted",ACCESS='STREAM')
          write(1) global_vec3D(1:total_valid,
     &                          1:vec_levels3D(fld,vec_id))
         ENDIF

         close(1)

        ENDIF

       ENDIF

      END
CEOC
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|






C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: WRITE_GLOBAL_BIN_SF

C !INTERFACE:
      SUBROUTINE WRITE_GLOBAL_BIN_SF(total_valid,fld,sf_id,myIter)

C     !USES:
      IMPLICIT NONE

#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "DIAGNOSTICS_VEC.h"

C     !INPUT PARAMETERS:
       INTEGER total_valid, sf_id, fld, myIter

C     !LOCAL VARIABLES:

CEOP
C----&------------------------------------------------------------------xxxxxxx|
C
C     /==================================================================\
C     | Description                                                      |
C     |==================================================================|
C     | WRITE_GLOBAL_BIN_SF:                                             |
C     | This program writes the final output (global final array) to a   |
C     | binary file.                                                     |
C     |                                                                  |
C     |  Writes either a 32 bit precision or 64 bit precision file.      |
C     |  Two ways to write output:                                       |
C     |   1. Write all times levels into a single binary files           |
C     |         - Each time level is written into its own record in the  |
C     |           binary file                                            |
C     |   2. Write a separates binary file for each time level           |
C     |         - File names consist of iter number:                     |
C     |               MASK_VEC_NN_FIELD_ITER.bin                          |
C     |                                                                  |
C     | input params:                                                    |
C     | total_valid - total number of open boundary points to write      | 
C     | fld - field number                                               |
C     | sf_id - open boundary number                                     |
C     | myIter - current iter number                                     |
C     | nDim - number of dimensions in field (either 2D or 3D)           |
C     \==================================================================/
C
C----&------------------------------------------------------------------xxxxxxx|
CBOC 
       character*2 dir
       character*50 filename
       real*4 bufferR4_SF((sNy*sNx)*(nPx*nPy))
       integer, parameter :: debug = 0
       logical exists
       integer LEN, i

       LEN = 1
       dir = "./"

       IF (vec_filePrec .eq. 32) then

C       -----------------------------------------------------------------------
C       File precision: 32
C       Field dimension: 2
C       -----------------------------------------------------------------------
         call SF_R8_to_R4(bufferR4_SF,fld,sf_id)
         call CREATE_FILENAME_SF(dir, sf_flds(fld,sf_id), sf_id,
     &                      filename,0, myIter)
         IF (combineMaskTimeLevels) then
C         Writing all time levels into a single binary file
          INQUIRE (IOLENGTH = LEN) bufferR4_SF(1:total_valid)
          INQUIRE (FILE=filename, EXIST=exists)
C         If file already exists, set status as 'old'. Otherwise, 'replace'
          if (exists) then
           open(1, FILE=filename, STATUS='OLD', ACCESS='DIRECT',
     &          RECL = LEN )
          else
           open(1, FILE=filename, STATUS='REPLACE', ACCESS='DIRECT',
     &          RECL = LEN )
          endif
          write(1, REC=time_level) bufferR4_SF(1:total_valid)
         ELSE
C         Write each time level into its own binary file
          open(1, FILE=filename, FORM="unformatted",ACCESS='STREAM')
          write(1) bufferR4_SF(1:total_valid)
         ENDIF
         close(1)

       ELSE IF (vec_filePrec .eq. 64) then

C       -----------------------------------------------------------------------
C       File precision: 64
C       Field dimension: 2
C       -----------------------------------------------------------------------
         call CREATE_FILENAME_SF(dir, sf_flds(fld,sf_id), sf_id,
     &                      filename,0, myIter)
         IF (combineMaskTimeLevels) then
          INQUIRE (IOLENGTH = LEN) global_SF(1:total_valid)
          INQUIRE (FILE=filename, EXIST=exists)
C         If file already exists, set status as 'old'. Otherwise, 'replace'
          if (exists) then
           open( 1, FILE=filename, STATUS='OLD', ACCESS='DIRECT',
     &          RECL = LEN )
          else
           open( 1, FILE=filename, STATUS='REPLACE', ACCESS='DIRECT',
     &          RECL = LEN )
          endif

          write(1, REC=time_level) global_SF(1:total_valid)
         ELSE
          open(1, FILE=filename, FORM="unformatted",ACCESS='STREAM')
          write(1) global_SF(1:total_valid)
         ENDIF
         close(1)

       ENDIF

      END
CEOC
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|









C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|

       SUBROUTINE CREATE_FILENAME_VEC(dir, fldNm, vec_id, filename,
     &                            is_child, myIter)
c       Creating filenames for all binary files.
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "DIAGNOSTICS_VEC.h"


C     !INPUT PARAMETERS:
       integer is_child, vec_id, myIter
       character*50 filename
       character*8 fldNm
       character*2 dir


C     !LOCAL VARIABLES:
       integer i
       _RL myTime
       character*3 str_px, str_py
#ifndef ALLOW_USE_MPI
       INTEGER, PARAMETER :: mpiPx = 0
       INTEGER, PARAMETER :: mpiPy = 0
#endif
       character*11 str_time
       character*2 str_vec
       character*8 str_iter
       integer len, count, mask_count
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|


c       If creating a filename for a child process, create a name in the format: T.001.002.bin
c       T for temp or mask for mask
c       001 for index 1 in x axis
c       002 for index 2 in x axis
       write(str_vec, "(I2.2)") vec_id
       write(str_iter, "(I8.8)") myIter
       write(str_time, "(F11.0)") myTime

C       Counting number of valid characters to trim trailing whitespaces
        count = 0
        DO i=1, len(fldNm)
          IF (fldNm(i:i) .ne. ' ') then
            count = count + 1
          ENDIF
        ENDDO

        mask_count = 0
        DO i=1, len(vec_fnames(vec_id))
          IF (vec_fnames(vec_id)(i:i) .ne. ' ') then
            mask_count = mask_count + 1
          ENDIF
        ENDDO

       if (is_child .eq. 1) then
         write(str_px, "(I3.3)") mpiPx
         write(str_py, "(I3.3)") mpiPy
         write(filename, "(8A)") dir, fldNm(1:count),
     &                   "_avg.",str_iter,str_px, ".", str_py, ".bin"
       else

         IF (combineMaskTimeLevels) then
          write(filename, "(5A)") vec_fnames(vec_id)(1:mask_count-4), 
     &                            "_",fldNm(1:count),".bin"
         ELSE
           write(filename, "(7A)") vec_fnames(vec_id)(1:mask_count-4), 
     &                   "_",fldNm(1:count),"_",str_iter,".bin"
         ENDIF

       end if

       END
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|










C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|

       SUBROUTINE CREATE_FILENAME_SF(dir, fldNm, sf_id, filename,
     &                            is_child, myIter)
c       Creating filenames for all binary files.
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "DIAGNOSTICS_VEC.h"


C     !INPUT PARAMETERS:
       integer is_child, sf_id, myIter
       character*50 filename
       character*8 fldNm
       character*2 dir


C     !LOCAL VARIABLES:
       integer i
       _RL myTime
       character*3 str_px, str_py
#ifndef ALLOW_USE_MPI
       INTEGER, PARAMETER :: mpiPx = 0
       INTEGER, PARAMETER :: mpiPy = 0
#endif
       character*11 str_time
       character*2 str_vec
       character*8 str_iter
       integer len, count, mask_count
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|


c       If creating a filename for a child process, create a name in the format: T.001.002.bin
c       T for temp or mask for mask
c       001 for index 1 in x axis
c       002 for index 2 in x axis
       write(str_vec, "(I2.2)") sf_id
       write(str_iter, "(I8.8)") myIter
       write(str_time, "(F11.0)") myTime

C       Counting number of valid characters to trim trailing whitespaces
        count = 0
        DO i=1, len(fldNm)
          IF (fldNm(i:i) .ne. ' ') then
            count = count + 1
          ENDIF
        ENDDO

        mask_count = 0
        DO i=1, len(sf_fnames(sf_id))
          IF (sf_fnames(sf_id)(i:i) .ne. ' ') then
            mask_count = mask_count + 1
          ENDIF
        ENDDO

       if (is_child .eq. 1) then
         write(str_px, "(I3.3)") mpiPx
         write(str_py, "(I3.3)") mpiPy
         write(filename, "(8A)") dir, fldNm(1:count),
     &                   "_avg.",str_iter,str_px, ".", str_py, ".bin"
       else

         IF (combineMaskTimeLevels) then
          write(filename, "(5A)") sf_fnames(sf_id)(1:mask_count-4), 
     &                            "_",fldNm(1:count),".bin"
         ELSE
           write(filename, "(7A)") sf_fnames(sf_id)(1:mask_count-4), 
     &                   "_",fldNm(1:count),"_",str_iter,".bin"
         ENDIF

       end if

       END
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|





C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
      SUBROUTINE VEC_R8_to_R4(bufferR4_2D, bufferR4_3D,nDim,fld,vec_id)
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "DIAGNOSTICS_VEC.h"

C     !INPUT PARAMETERS:
        real*4 bufferR4_2D((sNy+sNx)*(nPx*nPy))
        real*4 bufferR4_3D((sNy+sNx)*(nPx*nPy), Nr)
        integer nDim, fld, vec_id

C     !LOCAL VARIABLES:
        integer i, k
  
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|

C        Initialize buffer arrays:
       do i=1, ((sNy+sNx)*(nPx*nPy))
         bufferR4_2D(i) = 0.0
         do k=1, Nr
           bufferR4_3D(i,k) = 0.0
         enddo
       enddo

C        Set real*8 values to real*4

        if (nDim .eq. 2) then
          do i=1, ((sNy+sNx)*(nPx*nPy))
            bufferR4_2D(i) = global_vec2D(i)
          enddo

        else if (nDim .eq. 3) then
          do i=1, ((sNy+sNx)*(nPx*nPy))
            do k=1, vec_levels3D(fld,vec_id)
              bufferR4_3D(i,k) = global_vec3D(i,k)
            enddo
          enddo

        endif

      END
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|







C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
      SUBROUTINE SF_R8_to_R4(bufferR4_SF,fld,sf_id)
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "DIAGNOSTICS_VEC.h"

C     !INPUT PARAMETERS:
        real*4 bufferR4_SF((sNy*sNx)*(nPx*nPy))
        integer fld, sf_id

C     !LOCAL VARIABLES:
        integer, parameter :: debug = 0
        integer i
  
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|

C        Initialize buffer arrays:
       do i=1, ((sNy*sNx)*(nPx*nPy))
         bufferR4_SF(i) = 0.0
       enddo

C        Set real*8 values to real*4

       do i=1, ((sNy*sNx)*(nPx*nPy))
         bufferR4_SF(i) = global_SF(i)
       enddo

      END
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
