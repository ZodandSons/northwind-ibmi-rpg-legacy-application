      *****************************************************************
      *  PROGRAM  : NW490R
      *  TITLE    : PRODUCT SELECTION WINDOW (F4 PROMPT)
      *  AUTHOR   : J. SMITH  DATE: 08/19/97
      *
      *  PARAMETER: RETURNS SELECTED PRODUCT NUMBER (UNCHANGED IF F12)
      *  NOTE     : LOADS UP TO 300 ROWS - SAME CODE AS NW190R
      *****************************************************************
     FNW490D    CF   E             WORKSTN SFILE(W1SFL:RRN)
     FPRDMSTL1  IF   E           K DISK
      *****************************************************************
     C     *ENTRY        PLIST
     C                   PARM                    PKEY              5 0
      *
     C                   MOVE      *BLANKS       W1POS
     C                   EXSR      LOAD
     C     AGAIN         TAG
     C                   EXFMT     W1CTL
     C   12              GOTO      DONE
     C     W1POS         IFNE      SVPOS
     C                   EXSR      LOAD
     C                   GOTO      AGAIN
     C                   ENDIF
     C                   READC     W1SFL                                  91
     C     *IN91         DOWEQ     *OFF
     C     W1OPT         IFEQ      '1'
     C                   Z-ADD     W1KEY         PKEY
     C                   GOTO      DONE
     C                   ENDIF
     C                   READC     W1SFL                                  91
     C                   ENDDO
     C                   GOTO      AGAIN
     C     DONE          TAG
     C                   SETON                                        LR
      *****************************************************************
     C     LOAD          BEGSR
     C                   SETON                                        33
     C                   WRITE     W1CTL
     C                   SETOFF                                       3133
     C                   Z-ADD     0             RRN               4 0
     C                   MOVE      W1POS         SVPOS            20
     C                   MOVE      *BLANKS       POSKEY           40
     C                   MOVEL     W1POS         POSKEY
     C     POSKEY        SETLL     PRDMSTR
     C                   READ      PRDMSTR                                90
     C     *IN90         DOWEQ     *OFF
     C     RRN           ANDLT     300
     C                   ADD       1             RRN
     C                   MOVE      *BLANK        W1OPT
     C                   Z-ADD     PMPRD#        W1KEY
     C                   MOVEL     PMNAME        W1NAME
     C                   WRITE     W1SFL
     C                   READ      PRDMSTR                                90
     C                   ENDDO
     C                   SETON                                        3234
     C     RRN           IFGT      0
     C                   SETON                                        31
     C                   ENDIF
     C                   ENDSR
