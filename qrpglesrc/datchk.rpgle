      *****************************************************************
      *  COPY MEMBER : DATCHK
      *  VALIDATE A MMDDYY DATE.                       J. SMITH 06/06/01
      *
      *  THE INCLUDING PROGRAM MUST DEFINE:
      *     DS WITH WMDY6 (6,0) OVERLAID BY WMM, WDD, WYY (2,0 EACH)
      *     ARRAY DAYS (2,0) DIM(12) WITH DAYS PER MONTH
      *  RESULT: INDICATOR 59 ON = INVALID.   ZERO DATE = VALID.
      *
      *  ONLY NW600R USES THIS - THE OTHER PROGRAMS HAVE THEIR OWN COPY
      *****************************************************************
     C     DATCHK        BEGSR
     C                   SETOFF                                       59
     C     WMDY6         CABEQ     0             DCHKX
     C     WMM           CABLT     1             DCHKE
     C     WMM           CABGT     12            DCHKE
     C     WDD           CABLT     1             DCHKE
     C     WMM           IFEQ      2
     C     WDD           ANDEQ     29
     C     WYY           DIV       4             WQ4               3 0
     C                   MVR                     WR4               1 0
     C     WR4           CABEQ     0             DCHKX
     C                   ENDIF
     C     WDD           CABGT     DAYS(WMM)     DCHKE
     C                   GOTO      DCHKX
     C     DCHKE         TAG
     C                   SETON                                        59
     C     DCHKX         TAG
     C                   ENDSR
