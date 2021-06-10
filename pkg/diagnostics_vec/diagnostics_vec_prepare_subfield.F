C----&------------------------------------------------------------------xxxxxxx|
C                       diagnostics_vec_prepare_subfields
C----&------------------------------------------------------------------xxxxxxx|
C Contributors: Michael Wood, Ian Fenty, April Shin

#include "DIAGNOSTICS_VEC_OPTIONS.h"

C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|

      SUBROUTINE SET_SUBFIELDS(myThid, myIter)

C     Stores desired fields chosen by user into array subFields
C     Assign unique tags to all 2D, 3D, and SF fields for MPI_SEND
      IMPLICIT NONE


#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "DYNVARS.h"
#include "FFIELDS.h"
#include "GRID.h"

#ifdef ALLOW_EXF
#include "EXF_FIELDS.h"
#endif

#ifdef ALLOW_SEAICE
#include "SEAICE_SIZE.h"
#include "SEAICE.h"
#endif

#ifdef ALLOW_PTRACERS
#include "PTRACERS_SIZE.h"
#include "PTRACERS_FIELDS.h"
#endif

#include "DIAGNOSTICS_VEC.h"

      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER vec_id, myThid, loc_count, myIter
      INTEGER sf_id
      INTEGER i, j, k, bi, bj, numValid, vec_tag
      INTEGER sf_tag
      INTEGER nFlds2D, nFlds3D
      INTEGER nFldsSF
      INTEGER fld2D, fld3D
      INTEGER fldSF
      INTEGER, PARAMETER :: debug = 1
#ifndef ALLOW_USE_MPI
      INTEGER, PARAMETER :: mpiMyId = 0
#endif

C----&------------------------------------------------------------------xxxxxxx|


        if (debug .eq. 1) then
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "  BEGIN SET_SUBFIELDS DEBUG "
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        endif


C     Boundary starts first ----------------------------------------------------

C     Initialize tag number to 1. Tag number will be incrememted after each field is extracted.
      vec_tag = 1
      DO vec_id=1, nVEC_mask

C       Number of open boundary points for mask vec_id and process mpiMyId (added one because of fortran's indices starting from 1 )
        numValid = vec_numPnts_allproc(vec_id,mpiMyId+1)

C      Looping through 2D fields first, if any.
       nFlds2D = vec_nFlds2D(vec_id)
       DO fld2D=1, nFlds2D

C       Save unique tag for field and incremement tag for next field to be extracted
        vec_tags(vec_id, 1, fld2D) =  vec_tag
        vec_tag = vec_tag + 1

          DO loc_count=1, numValid
C          i,j indices with respect to process' sub mask for open boundary points
C          (Note: all processes have their own declared vec_sub_local_ij)
           j = vec_sub_local_ij(vec_id,2,loc_count)
           i = vec_sub_local_ij(vec_id,1,loc_count)
           bj = vec_sub_local_ij(vec_id,4,loc_count)
           bi = vec_sub_local_ij(vec_id,3,loc_count)

C          Comparing strings provided by user to fields in diagnostics_vec
           IF (vec_flds2D(fld2D,vec_id) .eq. 'ETAN') then
            subFieldOnMask_2D(vec_id,fld2D,loc_count) = etaN(i,j,bi,bj)
           ELSE IF (vec_flds2D(fld2D,vec_id) .eq. 'ETAH') then
            subFieldOnMask_2D(vec_id,fld2D,loc_count) = etaH(i,j,bi,bj)
#ifdef ALLOW_SEAICE
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'UICE') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        UICE(i,j,bi,bj)

             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'VICE') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        VICE(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'AREA') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        AREA(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'HEFF') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        HEFF(i,j,bi,bj)

             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'HSNOW') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        HSNOW(i,j,bi,bj)
#endif
           ENDIF

          ENDDO
C      !end of loop for nFlds2D
       ENDDO

C      Looping through 3D fields, if any.
       nFlds3D = vec_nFlds3D(vec_id)
       DO fld3D=1, nFlds3D

C       Save unique tag for field and incremement tag for next field to be extracted
        vec_tags(vec_id, 2, fld3D) = vec_tag
        vec_tag = vec_tag + 1

          DO loc_count=1, numValid

C          i,j indices with respect to process' sub mask for open boundary points
           j = vec_sub_local_ij(vec_id,2,loc_count)
           i = vec_sub_local_ij(vec_id,1,loc_count)
           bj = vec_sub_local_ij(vec_id,4,loc_count)
           bi = vec_sub_local_ij(vec_id,3,loc_count)
           
           DO k=1, vec_levels3D(fld3D,vec_id)

C          Comparing strings provided by user to fields in diagnostics_vec
            IF (vec_flds3D(fld3D,vec_id) .eq. 'UVEL') then
             subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        uVel(i,j,k,bi,bj)
            ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'VVEL') then
              subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        vVel(i,j,k,bi,bj)
            ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'WVEL') then
             subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        wVel(i,j,k,bi,bj)
            ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'THETA') then
              subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        theta(i,j,k,bi,bj)
C       if ((debug .eq. 1).and.(k.eq.1)) then
C        WRITE(msgBuf,'(A,I5,A,I5,A,F12.3)') 
C     &           "vec_id= 1, i=",i," j=",j," k=1, theta=",
C     &            theta(i,j,1,bi,bj)
C        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
C     &                     SQUEEZE_RIGHT, myThid )
C        endif
            ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'SALT') then
              subFieldOnMask_3D(vec_id,fld3D,loc_count,k)=
     &                                       salt(i,j,k,bi,bj)
            ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'GU') then
              subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        gU(i,j,k,bi,bj)
            ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'GV') then
              subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        gV(i,j,k,bi,bj)
            ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'HFACC') then
              subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        hfacC(i,j,k,bi,bj)
            ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'HFACW') then
              subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        hFacW(i,j,k,bi,bj)
            ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'HFACS') then
              subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        hFacS(i,j,k,bi,bj)
            
C This part is for variables from the ptracer pkg (assuming only up to 20 tracers)
#ifdef ALLOW_PTRACERS

             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE01') then
             subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,1)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE02') then
             subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,2)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE03') then
             subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,3)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE04') then
             subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,4)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE05') then
             subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,5)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE06') then
             subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,6)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE07') then
             subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,7)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE08') then
             subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,8)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE09') then
             subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,9)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE10') then
             subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,10)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE11') then
             subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,11)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE12') then
             subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,12)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE13') then
             subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,13)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE14') then
             subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,14)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE15') then
             subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,15)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE16') then
             subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,16)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE17') then
             subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,17)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE18') then
             subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,18)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE19') then
             subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,19)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE20') then
             subFieldOnMask_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,20)
#endif
            ENDIF
           ENDDO
        ENDDO

C       !End of loop for nFlds3D
       ENDDO
C     !End of loop for nVEC_mask
      ENDDO

C     Surface starts here ----------------------------------------------------

C     Initialize tag number to 1. Tag number will be incrememted after each field is extracted.
      sf_tag = 1
      DO sf_id=1, nSURF_mask

C      Number of open boundary points for mask sf_id and process mpiMyId (added one because of fortran's indices starting from 1 )
       numValid = sf_numPnts_allproc(sf_id,mpiMyId+1)

C      Looping through SF fields, if any.
       nFldsSF = sf_nFlds(sf_id)
       DO fldSF=1, nFldsSF

C       Save unique tag for field and incremement tag for next field to be extracted
        sf_tags(sf_id, 1, fldSF) =  sf_tag
        sf_tag = sf_tag + 1

          DO loc_count=1, numValid
C          i,j indices with respect to process' sub mask for open boundary points (Note: all processes have their own declared sf_sub_local_ij)
           j = sf_sub_local_ij(sf_id,2,loc_count)
           i = sf_sub_local_ij(sf_id,1,loc_count)
           bj = sf_sub_local_ij(vec_id,4,loc_count)
           bi = sf_sub_local_ij(vec_id,3,loc_count)

C          Comparing strings provided by user to fields in diagnostics_vec
C          First part of list is for 2D surface fields
           IF (sf_flds(fldSF,sf_id) .eq. 'ETAN') then
            subFieldOnMask_SF(sf_id,fldSF,loc_count) = etaN(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'ETAH') then
            subFieldOnMask_SF(sf_id,fldSF,loc_count) = etaH(i,j,bi,bj)

C          Second part of list is all the 3D fields, which are extracted in the top depth cell
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'UVEL') then
             subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        uVel(i,j,1,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'VVEL') then
              subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        vVel(i,j,1,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'WVEL') then
             subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        wVel(i,j,1,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'THETA') then
              subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        theta(i,j,1,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'SALT') then
              subFieldOnMask_SF(sf_id,fldSF,loc_count)=
     &                                        salt(i,j,1,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'GU') then
              subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        gU(i,j,1,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'GV') then
              subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        gV(i,j,1,bi,bj)

C          Third part of list is all the forcing fields
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'FU') then
             subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        fu(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'FV') then
             subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        fv(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'QNET') then
             subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        Qnet(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'QSW') then
             subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        Qsw(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'EMPMR') then
             subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        EmPmR(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'SALTFLUX') then
             subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        saltFlux(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'SST') then
             subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        SST(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'SSS') then
             subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        SSS(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'LTCR') then
             subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                            lambdaThetaClimRelax(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'LSCR') then
             subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                            lambdaSaltClimRelax(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'PLOAD') then
             subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        pLoad(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'SICELOAD') then
             subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        sIceLoad(i,j,bi,bj)

C          Fourth part of list encompasses variables from different packages
C          Variables from the EXF package:

#ifdef ALLOW_EXF
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'USTRESS') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        ustress(i,j,bi,bj)
C        if (debug .eq. 1) then
C        WRITE(msgBuf,'(A,I5,A,I5,A,F12.3)') 
C     &           "sf_id= 1, i=",i,"j=",j," k=1, ustress=",
C     &            ustress(i,j,bi,bj)
C        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
C     &                     SQUEEZE_RIGHT, myThid )
C        endif
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'VSTRESS') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        vstress(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'HFLUX') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        hflux(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'SFLUX') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        sflux(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'SWFLUX') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        swflux(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'UWIND') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        uwind(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'VWIND') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        vwind(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'WSPEED') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        wspeed(i,j,bi,bj)
#ifdef ALLOW_ATM_TEMP
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'ATEMP') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        atemp(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'AQH') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        aqh(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'HS') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        hs(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'HL') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        hl(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'LWFLUX') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        lwflux(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'EVAP') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        evap(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'PRECIP') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        precip(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'SNOWPREC') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        snowprecip(i,j,bi,bj)
#endif
#endif

#ifdef ALLOW_RUNOFF
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'RUNOFF') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        runoff(i,j,bi,bj)
#endif

#ifdef ALLOW_DOWNWARD_RADIATION
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'SWDOWN') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        swdown(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'LWDOWN') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        lwdown(i,j,bi,bj)
#endif 

#ifdef ATMOSPHERIC_LOADING
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'APRESS') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        apressure(i,j,bi,bj)
#endif

C Fifth part is for variables from the sea ice package
#ifdef ALLOW_SEAICE
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'UICE') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        UICE(i,j,bi,bj)

             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'VICE') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        VICE(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'AREA') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        AREA(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'HEFF') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        HEFF(i,j,bi,bj)

             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'HSNOW') then
                subFieldOnMask_SF(sf_id,fldSF,loc_count) =
     &                                        HSNOW(i,j,bi,bj)
#endif

           ENDIF
          ENDDO
C      !end of loop for nFldsSF
       ENDDO

C     !End of loop for nSURF_mask
      ENDDO



        if (debug .eq. 1) then
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "  END SET_SUBFIELDS DEBUG "
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

      SUBROUTINE SET_TO_INI_STATE(myThid)
C     Initializes field value average  to zero
        IMPLICIT NONE

#include "SIZE.h"
#include "EEPARAMS.h"
#include "DIAGNOSTICS_VEC.h"

        INTEGER myThid
        INTEGER nFlds2D, nFlds3D
        INTEGER nFldsSF
        INTEGER i, k, vec_id, fld2D, fld3D
        INTEGER sf_id, fldSF
C----&------------------------------------------------------------------xxxxxxx|

        DO vec_id=1, nVEC_mask

C        Total number of 2D fields
         nFlds2D = vec_nFlds2D(vec_id)
         DO fld2D=1, nFlds2D
          DO i=1, sNx+sNy
           subFieldOnMask_2Davg(vec_id,fld2D,i) = 0.0
          ENDDO
         ENDDO

c        Total number of 3D fields
         nFlds3D = vec_nFlds3D(vec_id)
         DO fld3D=1, nFlds3D
          DO i=1, sNx+sNy
           DO k=1, vec_levels3D(fld3D, vec_id)
            subFieldOnMask_3Davg(vec_id,fld3D,i,k) = 0.0
           ENDDO
          ENDDO
         ENDDO

        ENDDO


        DO sf_id=1, nSURF_mask
C        Total number of SF fields
         nFldsSF = sf_nFlds(sf_id)
         DO fldSF=1, nFldsSF
          DO i=1, sNx*sNy
           subFieldOnMask_SFavg(sf_id,fldSF,i) = 0.0
          ENDDO
         ENDDO

        ENDDO

C       Set number of time steps within averaging period back to zero for the next averaging period
       nTimeSteps_vec = 0

      END
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|





















C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
C !ROUTINE: CUMULATE_FLD_TIME

C !INTERFACE:
      SUBROUTINE CUMULATE_FLD_TIME(myThid)

C     Accumulate extracted field values
        IMPLICIT NONE  

C     !USES:
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "DIAGNOSTICS_VEC.h"

      INTEGER myThid
      INTEGER i, k, vec_id, fld, fld2D, fld3D
      INTEGER sf_id, fldSF
      INTEGER, PARAMETER :: debug = 0

C----&------------------------------------------------------------------xxxxxxx|

      DO vec_id=1, nVEC_mask
       DO i=1, sNx+sNy
        DO fld2D=1, vec_nFlds2D(vec_id)
         subFieldOnMask_2Davg(vec_id,fld2D,i)
     &                      = subFieldOnMask_2Davg(vec_id,fld2D,i)
     &                        + subFieldOnMask_2D(vec_id,fld2D,i)
        ENDDO
        DO fld3D=1, vec_nFlds3D(vec_id)
         DO k=1, vec_levels3D(fld3D, vec_id)
          subFieldOnMask_3Davg(vec_id,fld3D,i,k)
     &                    = subFieldOnMask_3Davg(vec_id,fld3D,i,k)
     &                      + subFieldOnMask_3D(vec_id,fld3D,i,k)
         ENDDO
        ENDDO
       ENDDO
      ENDDO

      DO sf_id=1, nSURF_mask
       DO i=1, sNx*sNy
        DO fldSF=1, sf_nFlds(sf_id)
         subFieldOnMask_SFavg(sf_id,fldSF,i)
     &                      = subFieldOnMask_SFavg(sf_id,fldSF,i)
     &                        + subFieldOnMask_SF(sf_id,fldSF,i)
        ENDDO

       ENDDO
      ENDDO

      END
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|










C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
C !ROUTINE: TIMEAVE_FLD

C !INTERFACE:
      SUBROUTINE TIMEAVE_FLDS(myThid, myTime)
C       Computes average of fields using the number of time steps taken 
C       in current period
        IMPLICIT NONE

C     !USES:
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "DIAGNOSTICS_VEC.h"

        INTEGER myThid
        INTEGER i, k,fld, vec_id, fld2D, fld3D
        INTEGER sf_id, fldSF
        _RL myTime
        INTEGER, PARAMETER :: debug = 0
        CHARACTER*(MAX_LEN_MBUF) msgBuf

C----&------------------------------------------------------------------xxxxxxx|


        if (debug .eq. 1) then
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "  BEGIN TIMEAVE_FLD DEBUG "
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        endif

        DO vec_id=1, nVEC_mask
          DO i=1, sNx+sNy
           DO fld2D=1, vec_nFlds2D(vec_id)
            subFieldOnMask_2Davg(vec_id,fld2D,i) =
     &           subFieldOnMask_2Davg(vec_id,fld2D,i)/nTimeSteps_vec
           ENDDO
           DO fld3D=1, vec_nFlds3D(vec_id)
            DO k=1, vec_levels3D(fld3D,vec_id)
             subFieldOnMask_3Davg(vec_id,fld3D,i,k) =
     &          subFieldOnMask_3Davg(vec_id,fld3D,i,k)/nTimeSteps_vec
            ENDDO
           ENDDO
          ENDDO

       ENDDO

        DO sf_id=1, nSURF_mask
          DO i=1, sNx*sNy
           DO fldSF=1, sf_nFlds(sf_id)
            subFieldOnMask_SFavg(sf_id,fldSF,i) =
     &              subFieldOnMask_SFavg(sf_id,fldSF,i)/nTimeSteps_vec
           ENDDO
          ENDDO

        ENDDO

        if (debug .eq. 1) then
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "  END TIMEAVE_FLD DEBUG "
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        endif

      END
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
