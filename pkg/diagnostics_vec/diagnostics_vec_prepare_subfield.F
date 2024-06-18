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

#ifdef ALLOW_KPP
#include "KPP.h"
#endif

#ifdef ALLOW_DARWIN
#include "DARWIN_FIELDS.h"
#include "DARWIN_EXF_FIELDS.h"
#endif

#ifdef ALLOW_ICEPLUME
#include "ICEPLUME_DV_FIELDS.h"
#endif

#ifdef ALLOW_SHELFICE
#include "SHELFICE.h"
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
      INTEGER, PARAMETER :: debug = 0
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
            fldOnMsk_2D(vec_id,fld2D,loc_count) = etaN(i,j,bi,bj)
           ELSE IF (vec_flds2D(fld2D,vec_id) .eq. 'ETAH') then
            fldOnMsk_2D(vec_id,fld2D,loc_count) = etaH(i,j,bi,bj)
       
#ifdef ALLOW_SEAICE
C       Add the variables from the sea ice package if its acivated
             ELSE IF (vec_flds2D(fld2D,vec_id) .eq. 'UICE') then
                fldOnMsk_2D(vec_id,fld2D,loc_count) =
     &                                        UICE(i,j,bi,bj)
             ELSE IF (vec_flds2D(fld2D,vec_id) .eq. 'VICE') then
                fldOnMsk_2D(vec_id,fld2D,loc_count) =
     &                                        VICE(i,j,bi,bj)
             ELSE IF (vec_flds2D(fld2D,vec_id) .eq. 'AREA') then
                fldOnMsk_2D(vec_id,fld2D,loc_count) =
     &                                        AREA(i,j,bi,bj)
             ELSE IF (vec_flds2D(fld2D,vec_id) .eq. 'HEFF') then
                fldOnMsk_2D(vec_id,fld2D,loc_count) =
     &                                        HEFF(i,j,bi,bj)
             ELSE IF (vec_flds2D(fld2D,vec_id) .eq. 'HSNOW') then
                fldOnMsk_2D(vec_id,fld2D,loc_count) =
     &                                        HSNOW(i,j,bi,bj)
#endif

#ifdef ALLOW_KPP
             ELSE IF (vec_flds2D(fld2D,vec_id) .eq. 'KPPHBL') then
                fldOnMsk_2D(vec_id,fld2D,loc_count) =
     &                                        KPPhbl(i,j,bi,bj)
             ELSE IF (vec_flds2D(fld2D,vec_id) .eq. 'KPPFRAC') then
                fldOnMsk_2D(vec_id,fld2D,loc_count) =
     &                                        KPPfrac(i,j,bi,bj)
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
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        uVel(i,j,k,bi,bj)
            ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'VVEL') then
              fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        vVel(i,j,k,bi,bj)
            ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'WVEL') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        wVel(i,j,k,bi,bj)
            ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'THETA') then
              fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        theta(i,j,k,bi,bj)
            ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'SALT') then
              fldOnMsk_3D(vec_id,fld3D,loc_count,k)=
     &                                       salt(i,j,k,bi,bj)
            ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'GU') then
              fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        gU(i,j,k,bi,bj)
            ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'GV') then
              fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        gV(i,j,k,bi,bj)
            ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'HFACC') then
              fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        hfacC(i,j,k,bi,bj)
            ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'HFACW') then
              fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        hFacW(i,j,k,bi,bj)
            ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'HFACS') then
              fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        hFacS(i,j,k,bi,bj)
            
C This part is for variables from the ptracer pkg (assuming only up to 31 tracers)
#ifdef ALLOW_PTRACERS

             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE01') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,1)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE02') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,2)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE03') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,3)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE04') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,4)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE05') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,5)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE06') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,6)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE07') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,7)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE08') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,8)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE09') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,9)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE10') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,10)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE11') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,11)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE12') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,12)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE13') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,13)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE14') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,14)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE15') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,15)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE16') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,16)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE17') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,17)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE18') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,18)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE19') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,19)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE20') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,20)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE21') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,21)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE22') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,22)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE23') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,23)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE24') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,24)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE25') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,25)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE26') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,26)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE27') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,27)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE28') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,28)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE29') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,29)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE30') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,30)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PTRACE31') then
             fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        PTRACER(i,j,k,bi,bj,31)
#endif

C Then kpp
#ifdef ALLOW_KPP
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'KPPDIFFS') then
                fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        KPPdiffKzS(i,j,k,bi,bj)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'KPPDIFFT') then
                fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        KPPdiffKzT(i,j,k,bi,bj)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'KPPVISCA') then
                fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        KPPviscAz(i,j,k,bi,bj)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'KPPGHAT') then
                fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        KPPghat(i,j,k,bi,bj)
#endif

#ifdef ALLOW_DARWIN
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PH') then
                fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        pH(i,j,k,bi,bj)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'PCO2') then
                fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                        pCO2(i,j,k,bi,bj)
#endif

#ifdef ALLOW_ICEPLUME
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'ICEFRNTA') then
                fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                       icefrntA_dv(i,j,k,bi,bj)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'ICEFRNTM') then
                fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                       icefrntM_dv(i,j,k,bi,bj)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'ICEFRNTR') then
                fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                       icefrntR_dv(i,j,k,bi,bj)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'ICEFRNTS') then
                fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                       icefrntS_dv(i,j,k,bi,bj)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'ICEFRNTT') then
                fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                       icefrntT_dv(i,j,k,bi,bj)
             ELSE IF (vec_flds3D(fld3D,vec_id) .eq. 'ICEFRNTW') then
                fldOnMsk_3D(vec_id,fld3D,loc_count,k) =
     &                                       icefrntW_dv(i,j,k,bi,bj)
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
           bj = sf_sub_local_ij(sf_id,4,loc_count)
           bi = sf_sub_local_ij(sf_id,3,loc_count)

C          Comparing strings provided by user to fields in diagnostics_vec
C          First part of list is for 2D surface fields
           IF (sf_flds(fldSF,sf_id) .eq. 'ETAN') then
            fldOnMsk_SF(sf_id,fldSF,loc_count) = etaN(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'ETAH') then
            fldOnMsk_SF(sf_id,fldSF,loc_count) = etaH(i,j,bi,bj)

C          Second part of list is all the 3D fields, which are extracted in the top depth cell
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'UVEL') then
             fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        uVel(i,j,1,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'VVEL') then
              fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        vVel(i,j,1,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'WVEL') then
             fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        wVel(i,j,1,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'THETA') then
              fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        theta(i,j,1,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'SALT') then
              fldOnMsk_SF(sf_id,fldSF,loc_count)=
     &                                        salt(i,j,1,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'GU') then
              fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        gU(i,j,1,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'GV') then
              fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        gV(i,j,1,bi,bj)

C          Third part of list is all the forcing fields
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'FU') then
             fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        fu(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'FV') then
             fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        fv(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'QNET') then
             fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        Qnet(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'QSW') then
             fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        Qsw(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'EMPMR') then
             fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        EmPmR(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'SALTFLUX') then
             fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        saltFlux(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'SST') then
             fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        SST(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'SSS') then
             fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        SSS(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'LTCR') then
             fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                            lambdaThetaClimRelax(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'LSCR') then
             fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                            lambdaSaltClimRelax(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'PLOAD') then
             fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        pLoad(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'SICELOAD') then
             fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        sIceLoad(i,j,bi,bj)

C          Fourth part of list encompasses variables from different packages
C          Variables from the EXF package:

#ifdef ALLOW_EXF
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'USTRESS') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        ustress(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'VSTRESS') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        vstress(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'HFLUX') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        hflux(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'SFLUX') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        sflux(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'UWIND') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        uwind(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'VWIND') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        vwind(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'WSPEED') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        wspeed(i,j,bi,bj)
#ifdef ATMOSPHERIC_LOADING
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'APRESS') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        apressure(i,j,bi,bj)
#endif
#ifdef ALLOW_ATM_TEMP
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'ATEMP') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        atemp(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'AQH') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        aqh(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'HS') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        hs(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'HL') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        hl(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'LWFLUX') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        lwflux(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'EVAP') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        evap(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'PRECIP') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        precip(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'SNOWPREC') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        snowprecip(i,j,bi,bj)
#endif
#endif

#ifdef ALLOW_RUNOFF
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'RUNOFF') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        runoff(i,j,bi,bj)
#endif

#ifdef ALLOW_DOWNWARD_RADIATION
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'SWDOWN') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        swdown(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'LWDOWN') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        lwdown(i,j,bi,bj)
#endif 



C Fifth part is for variables from the sea ice package
#ifdef ALLOW_SEAICE
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'UICE') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        UICE(i,j,bi,bj)

             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'VICE') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        VICE(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'AREA') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        AREA(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'HEFF') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        HEFF(i,j,bi,bj)

             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'HSNOW') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        HSNOW(i,j,bi,bj)
#endif

C Sixth part is for variables from the KPP package
#ifdef ALLOW_KPP
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'KPPHBL') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        KPPhbl(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'KPPFRAC') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        KPPfrac(i,j,bi,bj)
#endif

C Seventh part is for variables for the Darwin package
#ifdef ALLOW_DARWIN
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'ATMOSCO2') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                        atmospCO2(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'IRONDUST') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                     inputFe(i,j,bi,bj)
#endif

C Seventh part is for variables for the shelfice package
#ifdef ALLOW_SHELFICE
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'SHFHTFLX') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                                 shelficeHeatFlux(i,j,bi,bj)
             ELSE IF (sf_flds(fldSF,sf_id) .eq. 'SHFFWFLX') then
                fldOnMsk_SF(sf_id,fldSF,loc_count) =
     &                           shelficeFreshWaterFlux(i,j,bi,bj)
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

        SUBROUTINE SET_TO_VEC_INI_STATE(myThid,vec_id)
C     Initializes field value average  to zero

        IMPLICIT NONE
        
#include "SIZE.h"
#include "EEPARAMS.h"
#include "DIAGNOSTICS_VEC.h"

        INTEGER myThid, vec_id
        INTEGER nFlds2D, nFlds3D
        INTEGER i, k, fld2D, fld3D
C----&------------------------------------------------------------------xxxxxxx|

C        Total number of 2D fields
        nFlds2D = vec_nFlds2D(vec_id)
        DO fld2D=1, nFlds2D
          DO i=1, (VEC_points)*(nSx*nSy)
            fldOnMsk_2Davg(vec_id,fld2D,i) = 0.0
          ENDDO
        ENDDO

c        Total number of 3D fields
        nFlds3D = vec_nFlds3D(vec_id)
        DO fld3D=1, nFlds3D
          DO i=1, (VEC_points)*(nSx*nSy)
            DO k=1, vec_levels3D(fld3D, vec_id)
               fldOnMsk_3Davg(vec_id,fld3D,i,k) = 0.0
            ENDDO
          ENDDO
        ENDDO

C       Set number of time steps within averaging period back to zero for the next averaging period
        vec_nTimeSteps(vec_id) = 0

        END
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|




C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|

        SUBROUTINE SET_TO_SF_INI_STATE(myThid,sf_id)
C     Initializes field value average  to zero
        IMPLICIT NONE

#include "SIZE.h"
#include "EEPARAMS.h"
#include "DIAGNOSTICS_VEC.h"

        INTEGER myThid, sf_id
        INTEGER nFldsSF
        INTEGER i, fldSF
C----&------------------------------------------------------------------xxxxxxx|



C        Total number of SF fields
        nFldsSF = sf_nFlds(sf_id)
        DO fldSF=1, nFldsSF
          DO i=1, (sNx*sNy)*(nSx*nSy)
                fldOnMsk_SFavg(sf_id,fldSF,i) = 0.0
          ENDDO
        ENDDO

C       Set number of time steps within averaging period back to zero for the next averaging period
        sf_nTimeSteps(sf_id) = 0

        END
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|





















C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
C !ROUTINE: CUMULATE_FLD_TIME

C !INTERFACE:
        SUBROUTINE CUMULATE_VEC_FLD_TIME(myThid,vec_id)

C     Accumulate extracted field values
        IMPLICIT NONE  

C     !USES:
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "DIAGNOSTICS_VEC.h"

        INTEGER myThid, vec_id
        INTEGER i, k, fld, fld2D, fld3D
        INTEGER, PARAMETER :: debug = 0

C----&------------------------------------------------------------------xxxxxxx|


        DO i=1, (VEC_points)*(nSx*nSy)

        DO fld2D=1, vec_nFlds2D(vec_id)
                fldOnMsk_2Davg(vec_id,fld2D,i)
     &                      = fldOnMsk_2Davg(vec_id,fld2D,i)
     &                        + fldOnMsk_2D(vec_id,fld2D,i)
        ENDDO

        DO fld3D=1, vec_nFlds3D(vec_id)
          DO k=1, vec_levels3D(fld3D, vec_id)
                fldOnMsk_3Davg(vec_id,fld3D,i,k)
     &                    = fldOnMsk_3Davg(vec_id,fld3D,i,k)
     &                      + fldOnMsk_3D(vec_id,fld3D,i,k)
          ENDDO
        ENDDO

        ENDDO


        END
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|





C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
C !ROUTINE: CUMULATE_FLD_TIME

C !INTERFACE:
        SUBROUTINE CUMULATE_SF_FLD_TIME(myThid,sf_id)

C     Accumulate extracted field values
        IMPLICIT NONE  

C     !USES:
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "DIAGNOSTICS_VEC.h"

        INTEGER myThid, sf_id
        INTEGER i, fldSF
        INTEGER, PARAMETER :: debug = 0

C----&------------------------------------------------------------------xxxxxxx|


        DO i=1, (sNx*sNy)*(nSx*nSy)
          DO fldSF=1, sf_nFlds(sf_id)
                fldOnMsk_SFavg(sf_id,fldSF,i)
     &             = fldOnMsk_SFavg(sf_id,fldSF,i)
     &               + fldOnMsk_SF(sf_id,fldSF,i)
          ENDDO
        ENDDO

        END
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|




C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
C !ROUTINE: TIMEAVE_FLD

C !INTERFACE:
        SUBROUTINE TIMEAVE_VEC_FLD(myThid, myTime, vec_id)
C       Computes average of fields using the number of time steps taken 
C       in current period
        IMPLICIT NONE

C     !USES:
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "DIAGNOSTICS_VEC.h"

        INTEGER myThid, vec_id
        INTEGER i, k,fld, fld2D, fld3D
        _RL myTime
        INTEGER, PARAMETER :: debug = 0
        CHARACTER*(MAX_LEN_MBUF) msgBuf

C----&------------------------------------------------------------------xxxxxxx|


        if (debug .eq. 1) then
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "  BEGIN TIMEAVE_VEC_FLD DEBUG "
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        endif


        DO i=1, (VEC_points)*(nSx*nSy)

        DO fld2D=1, vec_nFlds2D(vec_id)
            fldOnMsk_2Davg(vec_id,fld2D,i) =
     &      fldOnMsk_2Davg(vec_id,fld2D,i)/vec_nTimeSteps(vec_id)
        ENDDO

        DO fld3D=1, vec_nFlds3D(vec_id)
          DO k=1, vec_levels3D(fld3D,vec_id)
            fldOnMsk_3Davg(vec_id,fld3D,i,k) =
     &       fldOnMsk_3Davg(vec_id,fld3D,i,k)/vec_nTimeSteps(vec_id)
          ENDDO
        ENDDO

        ENDDO


        if (debug .eq. 1) then
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "  END TIMEAVE_VEC_FLD DEBUG "
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
C !ROUTINE: TIMEAVE_FLD

C !INTERFACE:
        SUBROUTINE TIMEAVE_SF_FLD(myThid, myTime, sf_id)
C       Computes average of fields using the number of time steps taken 
C       in current period
        IMPLICIT NONE

C     !USES:
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "DIAGNOSTICS_VEC.h"

        INTEGER myThid, sf_id
        INTEGER i, fldSF
        _RL myTime
        INTEGER, PARAMETER :: debug = 0
        CHARACTER*(MAX_LEN_MBUF) msgBuf

C----&------------------------------------------------------------------xxxxxxx|


        if (debug .eq. 1) then
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "  BEGIN TIMEAVE_SF_FLD DEBUG "
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        endif

        DO i=1, (sNx*sNy)*(nSx*nSy)
          DO fldSF=1, sf_nFlds(sf_id)
                fldOnMsk_SFavg(sf_id,fldSF,i) =
     &          fldOnMsk_SFavg(sf_id,fldSF,i)/sf_nTimeSteps(sf_id)
          ENDDO
        ENDDO


        if (debug .eq. 1) then
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "  END TIMEAVE_SF_FLD DEBUG "
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        endif

        END
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
