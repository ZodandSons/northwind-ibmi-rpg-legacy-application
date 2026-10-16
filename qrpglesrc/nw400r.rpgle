      *****************************************************************
      *  PROGRAM  : NW400R
      *  TITLE    : PRODUCT MASTER MAINTENANCE
      *  AUTHOR   : D. L. WEBB                       DATE: 10/07/91
      *             (LIST LOGIC FROM NW200R)
      *
      *  MODIFICATION LOG
      *  02/01/93 DLW  DLW93  NEXT PRODUCT NUMBER FROM DATA AREA NWNXTPRD
      *  07/15/98 RKM  RKM98  CATEGORY MOVED TO CODTBL (TYPE CAT)
      *  04/10/03 TPK  TPK03  CONVERTED TO RPG IV
      *****************************************************************
     HDATEDIT(*MDY)
     FNW400D    CF   E             WORKSTN SFILE(SFLREC:RRN)
     FPRDMST    UF A E           K DISK
     FPRDMSTL1  IF   E           K DISK    RENAME(PRDMSTR:PRDMST1)
     FSUPMST    IF   E           K DISK
RKM98FCODTBL    IF   E           K DISK
      *
     DMSG              S             50    DIM(10) CTDATA PERRCD(1)
      *****************************************************************
     C     *LIKE         DEFINE    PMPRD#        WPRD
     C     *LIKE         DEFINE    SMSUP#        WSUP
DLW93C     *DTAARA       DEFINE    NWNXTPRD      NXTPRD            5 0
RKM98C     *LIKE         DEFINE    CTTYPE        WTYPE
RKM98C     *LIKE         DEFINE    CTCODE        WCODE
RKM98C     CTKEY         KLIST
RKM98C                   KFLD                    WTYPE
RKM98C                   KFLD                    WCODE
      *
     C                   MOVE      *BLANKS       C1POS
     C                   EXSR      NEWPOS
     C     MAIN          TAG
     C                   WRITE     FMT01
     C                   EXFMT     SFLCTL
     C                   MOVE      *BLANKS       MSGLIN
     C   03              GOTO      ENDPGM
     C   12              GOTO      ENDPGM
     C     *IN25         IFEQ      *ON
     C     *IN34         IFEQ      *ON
     C                   MOVEL     MSG(7)        MSGLIN
     C                   ELSE
     C                   EXSR      LODPAG
     C                   ENDIF
     C                   GOTO      MAIN
     C                   ENDIF
     C   06              EXSR      ADDPRD
     C   06              EXSR      NEWPOS
     C   06              GOTO      MAIN
     C     C1POS         IFNE      SVPOS
     C                   EXSR      NEWPOS
     C                   GOTO      MAIN
     C                   ENDIF
     C                   EXSR      PRCOPT
     C                   EXSR      NEWPOS
     C                   GOTO      MAIN
     C     ENDPGM        TAG
     C                   SETON                                        LR
      *****************************************************************
      *  NEWPOS / LODPAG - SAME AS NW200R
      *****************************************************************
     C     NEWPOS        BEGSR
     C                   MOVE      C1POS         SVPOS            20
     C                   MOVE      *BLANKS       POSKEY           40
     C                   MOVEL     C1POS         POSKEY
     C     POSKEY        SETLL     PRDMST1
     C                   EXSR      LODPAG
     C                   ENDSR
      *
     C     LODPAG        BEGSR
     C                   SETON                                        33
     C                   WRITE     SFLCTL
     C                   SETOFF                                       313334
     C                   Z-ADD     0             RRN               4 0
     C                   DO        12
     C                   READ      PRDMST1                                90
     C     *IN90         IFEQ      *ON
     C                   LEAVE
     C                   ENDIF
     C                   ADD       1             RRN
     C                   MOVE      *BLANK        S1OPT
     C                   Z-ADD     PMPRD#        S1PRD
     C                   MOVEL     PMNAME        S1NAME
     C                   Z-ADD     PMPRIC        S1PRIC
     C                   Z-ADD     PMSTCK        S1STCK
     C                   MOVE      PMDISC        S1DISC
     C                   WRITE     SFLREC
     C                   ENDDO
     C   90              SETON                                        34
     C                   SETON                                        32
     C     RRN           IFGT      0
     C                   SETON                                        31
     C                   ELSE
     C                   MOVEL     MSG(6)        MSGLIN
     C                   ENDIF
     C                   ENDSR
      *****************************************************************
     C     PRCOPT        BEGSR
     C                   READC     SFLREC                                 91
     C     *IN91         DOWEQ     *OFF
     C                   Z-ADD     S1PRD         WPRD
     C     S1OPT         CASEQ     '2'           CHGPRD
     C     S1OPT         CASEQ     '4'           DLTPRD
     C     S1OPT         CASEQ     '5'           DSPPRD
     C                   ENDCS
     C                   READC     SFLREC                                 91
     C                   ENDDO
     C                   ENDSR
      *****************************************************************
      *  CHGPRD - CHANGE
      *****************************************************************
     C     CHGPRD        BEGSR
     C     WPRD          CHAIN     PRDMSTR                            92
     C     *IN92         IFEQ      *ON
     C                   MOVEL     MSG(1)        MSGLIN
     C                   GOTO      CHGX
     C                   ENDIF
     C                   MOVEL     'CHANGE'      D1MODE
     C                   SETON                                        40
     C                   SETOFF                                       41
     C                   EXSR      MOVSCR
     C     CHG1          TAG
     C                   EXFMT     DTLREC
     C                   MOVE      *BLANKS       D1MSG
     C   12              GOTO      CHGX
     C   03              GOTO      CHGX
     C                   EXSR      EDTPRD
     C     *IN50         CABEQ     *ON           CHG1
     C                   EXSR      MOVFIL
     C                   UPDATE    PRDMSTR
     C                   MOVEL     MSG(2)        MSGLIN
     C     CHGX          TAG
     C                   ENDSR
      *****************************************************************
      *  ADDPRD - DLW93 NUMBER FROM DATA AREA
      *****************************************************************
     C     ADDPRD        BEGSR
     C                   MOVEL     'ADD'         D1MODE
     C                   SETON                                        40
     C                   SETOFF                                       41
     C                   EXSR      CLRSCR
DLW93C     *LOCK         IN        NXTPRD
DLW93C                   Z-ADD     NXTPRD        D1PRD
     C     ADD1          TAG
     C                   EXFMT     DTLREC
     C                   MOVE      *BLANKS       D1MSG
      * DATA AREA STAYS LOCKED WHILE THE USER TYPES
     C   12              GOTO      ADDCAN
     C   03              GOTO      ADDCAN
     C                   EXSR      EDTPRD
     C     *IN50         CABEQ     *ON           ADD1
     C                   EXSR      MOVFIL
     C                   Z-ADD     D1PRD         PMPRD#
     C                   WRITE     PRDMSTR
DLW93C     NXTPRD        ADD       1             NXTPRD
DLW93C                   OUT       NXTPRD
     C                   MOVEL     MSG(3)        MSGLIN
     C                   GOTO      ADDX
DLW93C     ADDCAN        TAG
DLW93C                   UNLOCK    NXTPRD
     C     ADDX          TAG
     C                   ENDSR
      *****************************************************************
      *  DLTPRD - DELETE (ORDER LINES NOT CHECKED)
      *****************************************************************
     C     DLTPRD        BEGSR
     C     WPRD          CHAIN     PRDMSTR                            92
     C     *IN92         IFEQ      *ON
     C                   MOVEL     MSG(1)        MSGLIN
     C                   GOTO      DLTX
     C                   ENDIF
     C                   Z-ADD     PMPRD#        D2PRD
     C                   MOVEL     PMNAME        D2NAME
     C                   MOVE      'N'           D2CONF
     C                   EXFMT     DLTREC
     C   12              GOTO      DLTX
     C     D2CONF        IFEQ      'Y'
     C                   DELETE    PRDMSTR
     C                   MOVEL     MSG(4)        MSGLIN
     C                   ENDIF
     C     DLTX          TAG
     C                   ENDSR
      *****************************************************************
     C     DSPPRD        BEGSR
     C     WPRD          CHAIN     PRDMSTR                            92
     C     *IN92         IFEQ      *OFF
     C                   MOVEL     'DISPLAY'     D1MODE
     C                   SETON                                        4041
     C                   EXSR      MOVSCR
     C                   EXFMT     DTLREC
     C                   ENDIF
     C                   ENDSR
      *****************************************************************
      *  EDTPRD - EDITS
      *****************************************************************
     C     EDTPRD        BEGSR
     C                   SETOFF                                       505152
     C                   SETOFF                                       535455
     C                   EXSR      GETNAM
     C     D1NAME        IFEQ      *BLANKS
     C                   SETON                                        5051
     C                   MOVEL     MSG(8)        D1MSG
     C                   GOTO      EDTX
     C                   ENDIF
     C     D1SUP         IFNE      0
     C     *IN93         ANDEQ     *ON
     C                   SETON                                        5052
     C                   MOVEL     MSG(9)        D1MSG
     C                   GOTO      EDTX
     C                   ENDIF
RKM98C     *IN94         IFEQ      *ON
RKM98C                   SETON                                        5053
RKM98C                   MOVEL     MSG(10)       D1MSG
RKM98C                   GOTO      EDTX
RKM98C                   ENDIF
     C     D1STCK        IFLT      0
     C                   SETON                                        5054
TPK03C                   EVAL      D1MSG = 'Stock cannot be negative'
     C                   GOTO      EDTX
     C                   ENDIF
     C     D1ONOR        IFLT      0
     C                   SETON                                        5055
TPK03C                   EVAL      D1MSG = 'On order cannot be negative'
     C                   ENDIF
     C     EDTX          TAG
     C                   ENDSR
      *****************************************************************
      *  GETNAM - LOOK UP SUPPLIER AND CATEGORY NAMES (93/94 = NOT FOUND)
      *****************************************************************
     C     GETNAM        BEGSR
     C                   MOVE      *BLANKS       D1SUPN
     C                   MOVE      *BLANKS       D1CATN
     C                   Z-ADD     D1SUP         WSUP
     C     WSUP          CHAIN     SUPMSTR                            93
     C  N93              MOVEL     SMNAME        D1SUPN
RKM98C                   MOVE      'CAT'         WTYPE
RKM98C                   MOVE      D1CATG        WCAT3             3
RKM98C                   MOVE      *BLANKS       WCODE
RKM98C                   MOVEL     WCAT3         WCODE
RKM98C     CTKEY         CHAIN     CODTBLR                            94
RKM98C  N94              MOVEL     CTDESC        D1CATN
     C                   ENDSR
      *****************************************************************
     C     MOVSCR        BEGSR
     C                   Z-ADD     PMPRD#        D1PRD
     C                   MOVEL     PMNAME        D1NAME
     C                   Z-ADD     PMSUP#        D1SUP
     C                   Z-ADD     PMCATG        D1CATG
     C                   MOVEL     PMQPU         D1QPU
     C                   Z-ADD     PMPRIC        D1PRIC
     C                   Z-ADD     PMSTCK        D1STCK
     C                   Z-ADD     PMONOR        D1ONOR
     C                   Z-ADD     PMROLV        D1ROLV
     C                   MOVE      PMDISC        D1DISC
     C                   MOVE      *BLANKS       D1MSG
     C                   EXSR      GETNAM
     C                   ENDSR
      *
     C     MOVFIL        BEGSR
     C                   MOVEL     D1NAME        PMNAME
     C                   Z-ADD     D1SUP         PMSUP#
     C                   Z-ADD     D1CATG        PMCATG
     C                   MOVEL     D1QPU         PMQPU
     C                   Z-ADD     D1PRIC        PMPRIC
     C                   Z-ADD     D1STCK        PMSTCK
     C                   Z-ADD     D1ONOR        PMONOR
     C                   Z-ADD     D1ROLV        PMROLV
     C                   MOVE      D1DISC        PMDISC
     C                   ENDSR
      *
     C     CLRSCR        BEGSR
     C                   Z-ADD     0             D1PRD
     C                   MOVE      *BLANKS       D1NAME
     C                   Z-ADD     0             D1SUP
     C                   Z-ADD     0             D1CATG
     C                   MOVE      *BLANKS       D1QPU
     C                   Z-ADD     0             D1PRIC
     C                   Z-ADD     0             D1STCK
     C                   Z-ADD     0             D1ONOR
     C                   Z-ADD     0             D1ROLV
     C                   MOVE      'N'           D1DISC
     C                   MOVE      *BLANKS       D1SUPN
     C                   MOVE      *BLANKS       D1CATN
     C                   MOVE      *BLANKS       D1MSG
     C                   ENDSR
**CTDATA MSG
Product not found
Product changed
Product added
Product deleted
Product is on orders - not deleted
No products found
No more records
Product name is required
Supplier not found
Category not found
