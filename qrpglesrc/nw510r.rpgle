      *****************************************************************
      *  PROGRAM  : NW510R
      *  TITLE    : EMPLOYEE TERRITORIES
      *  AUTHOR   : T. P. KOWALSKI                   DATE: 03/22/05
      *
      *  PARAMETER: EMPLOYEE NUMBER (5,0 PACKED) - CALLED FROM NW200R
      *
      *  MODIFICATION LOG
      *  03/22/05 TPK         NEW PROGRAM
      *****************************************************************
     HDATEDIT(*MDY)
     FNW510D    CF   E             WORKSTN SFILE(SFLREC:RRN)
     FEMPTER    UF A E           K DISK
     FEMPMST    IF   E           K DISK
     FCODTBL    IF   E           K DISK
      *
     DMSG              S             50    DIM(6) CTDATA PERRCD(1)
      *****************************************************************
     C     *ENTRY        PLIST
     C                   PARM                    PEMP              5 0
      *
     C     LNKKEY        KLIST
     C                   KFLD                    PEMP
     C     LNKKY2        KLIST
     C                   KFLD                    PEMP
     C                   KFLD                    WCODE
     C     CTKEY         KLIST
     C                   KFLD                    WTYPE
     C                   KFLD                    WCODE
     C     *LIKE         DEFINE    CTCODE        WCODE
     C     *LIKE         DEFINE    CTTYPE        WTYPE
      *
     C                   Z-ADD     PEMP          H1KEY
     C     PEMP          CHAIN     EMPMSTR                            92
     C     *IN92         IFEQ      *ON
     C                   MOVEL     MSG(1)        H1NAME
     C                   ELSE
     C                   MOVEL     EMLNAM        H1NAME
     C                   ENDIF
      *
     C                   EXSR      LODSFL
     C     MAIN          TAG
     C                   WRITE     FMT01
     C                   MOVE      *BLANKS       MSGLIN
     C                   EXFMT     SFLCTL
     C   03              GOTO      ENDPGM
     C   12              GOTO      ENDPGM
     C   06              EXSR      ADDLNK
     C                   EXSR      PRCOPT
     C                   EXSR      LODSFL
     C                   GOTO      MAIN
     C     ENDPGM        TAG
     C                   SETON                                        LR
      *****************************************************************
     C     LODSFL        BEGSR
     C                   SETON                                        33
     C                   WRITE     SFLCTL
     C                   SETOFF                                       313233
     C                   Z-ADD     0             RRN               4 0
     C                   MOVE      'TER'         WTYPE
     C     LNKKEY        SETLL     EMPTERR
     C     LNKKEY        READE     EMPTERR                                90
     C     *IN90         DOWEQ     *OFF
     C                   ADD       1             RRN
     C                   MOVE      *BLANK        S1OPT
     C                   MOVEL     ETTERR        S1CODE
     C                   MOVE      *BLANKS       WCODE
     C                   MOVEL     ETTERR        WCODE
     C     CTKEY         CHAIN     CODTBLR                            93
     C     *IN93         IFEQ      *ON
     C                   MOVEL     '*NOT ON FILE'S1DESC
     C                   ELSE
     C                   MOVEL     CTDESC        S1DESC
     C                   ENDIF
     C                   WRITE     SFLREC
     C     LNKKEY        READE     EMPTERR                                90
     C                   ENDDO
     C                   SETON                                        3234
     C     RRN           IFGT      0
     C                   SETON                                        31
     C                   ELSE
     C                   MOVEL     MSG(2)        MSGLIN
     C                   ENDIF
     C                   ENDSR
      *****************************************************************
     C     PRCOPT        BEGSR
     C                   READC     SFLREC                                 91
     C     *IN91         DOWEQ     *OFF
     C     S1OPT         IFEQ      '4'
     C                   MOVE      *BLANKS       WCODE
     C                   MOVEL     S1CODE        WCODE
     C     LNKKY2        CHAIN     EMPTERR                            92
     C  N92              DELETE    EMPTERR
     C  N92              MOVEL     MSG(3)        MSGLIN
     C                   ENDIF
     C                   READC     SFLREC                                 91
     C                   ENDDO
     C                   ENDSR
      *****************************************************************
     C     ADDLNK        BEGSR
     C                   MOVE      *BLANKS       A1CODE
     C     ADD1          TAG
     C                   EXFMT     ADDREC
     C   12              GOTO      ADDX
     C   03              GOTO      ADDX
     C                   SETOFF                                       5152
     C                   MOVE      'TER'         WTYPE
     C                   MOVE      *BLANKS       WCODE
     C                   MOVEL     A1CODE        WCODE
     C     CTKEY         CHAIN     CODTBLR                            93
     C     *IN93         IFEQ      *ON
     C                   SETON                                        51
     C                   GOTO      ADD1
     C                   ENDIF
     C     LNKKY2        CHAIN     EMPTERR                            92
     C     *IN92         IFEQ      *OFF
     C                   SETON                                        52
     C                   GOTO      ADD1
     C                   ENDIF
     C                   Z-ADD     PEMP          ETEMP#
     C                   MOVEL     WCODE         ETTERR
     C                   WRITE     EMPTERR
     C                   MOVEL     MSG(4)        MSGLIN
     C     ADDX          TAG
     C                   ENDSR
**CTDATA MSG
Employee not on file
No territories assigned
Territory removed
Territory added
Unused message
Unused message
