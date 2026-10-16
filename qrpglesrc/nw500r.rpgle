      *****************************************************************
      *  PROGRAM  : NW500R
      *  TITLE    : CODE TABLE MAINTENANCE (ALL TABLES IN CODTBL)
      *  AUTHOR   : R. K. MILLER                     DATE: 07/15/98
      *
      *  CALLED FROM MENU NW000C WITH THE TABLE TYPE:
      *    REG = REGIONS       SHP = SHIPPERS (ALT1 = PHONE)
      *    CAT = CATEGORIES    (ALT1 = LONG DESCRIPTION, CODE = 001-999)
      *    TER = TERRITORIES   (ALT2 = REGION CODE)
      *    DEM = CUSTOMER DEMOGRAPHIC TYPES
      *
      *  MODIFICATION LOG
      *  04/10/03 TPK  TPK03  CONVERTED TO RPG IV
      *  09/09/04 TPK  TPK04  RE-READ RECORD BEFORE UPDATE - REGION CHECK
      *                       MOVED THE FILE POINTER (UPDATED WRONG RECORD)
      *****************************************************************
     HDATEDIT(*MDY)
     FNW500D    CF   E             WORKSTN SFILE(SFLREC:RRN)
     FCODTBL    UF A E           K DISK
      *
     DTYP              S              3    DIM(5) CTDATA PERRCD(1)
     DTTL              S             30    DIM(5) ALT(TYP)
     DMSG              S             50    DIM(6) CTDATA PERRCD(1)
      *****************************************************************
     C     *ENTRY        PLIST
     C                   PARM                    PTYPE             3
      *
     C     TBLKEY        KLIST
     C                   KFLD                    PTYPE
     C     CTKEY         KLIST
     C                   KFLD                    PTYPE
     C                   KFLD                    WCODE
     C     REGKEY        KLIST
     C                   KFLD                    WREG
     C                   KFLD                    WCODE2
     C     *LIKE         DEFINE    CTCODE        WCODE
     C     *LIKE         DEFINE    CTCODE        WCODE2
     C     *LIKE         DEFINE    CTTYPE        WREG
      *  FIND TABLE TITLE
     C                   Z-ADD     1             X                 3 0
     C     PTYPE         LOOKUP    TYP(X)                                 80
     C     *IN80         IFEQ      *ON
     C                   MOVEL     TTL(X)        C1TITL
     C                   ELSE
     C                   MOVEL     'UNKNOWN'     C1TITL
     C                   ENDIF
     C                   MOVEL     C1TITL        D1TITL
     C                   MOVE      PTYPE         C1TYPE
      *  WHICH EXTRA FIELDS DOES THIS TABLE USE
     C                   SETON                                        6162
     C                   MOVE      *BLANKS       C1ALTH
     C     PTYPE         IFEQ      'SHP'
     C                   SETOFF                                       61
     C                   MOVEL     'Phone . . .' D1L1
     C                   MOVEL     'Phone'       C1ALTH
     C                   ENDIF
     C     PTYPE         IFEQ      'CAT'
     C                   SETOFF                                       61
     C                   MOVEL     'Long desc .' D1L1
     C                   MOVEL     'Long desc'   C1ALTH
     C                   ENDIF
     C     PTYPE         IFEQ      'TER'
     C                   SETOFF                                       62
     C                   MOVEL     'Region code' D1L2
     C                   MOVEL     'Region'      C1ALTH
     C                   ENDIF
      *
     C                   EXSR      LODSFL
     C     MAIN          TAG
     C                   WRITE     FMT01
     C                   MOVE      *BLANKS       MSGLIN
     C                   EXFMT     SFLCTL
     C   03              GOTO      ENDPGM
     C   12              GOTO      ENDPGM
     C   06              EXSR      ADDREC
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
     C     TBLKEY        SETLL     CODTBLR
     C     TBLKEY        READE     CODTBLR                                90
     C     *IN90         DOWEQ     *OFF
     C                   ADD       1             RRN
     C                   MOVE      *BLANK        S1OPT
     C                   MOVEL     CTCODE        S1CODE
     C                   MOVEL     CTDESC        S1DESC
     C                   MOVE      *BLANKS       S1ALT
     C     PTYPE         IFEQ      'TER'
     C                   MOVEL     CTALT2        S1ALT
     C                   ELSE
     C                   MOVEL     CTALT1        S1ALT
     C                   ENDIF
     C                   WRITE     SFLREC
     C     RRN           CABEQ     200           LODEND
     C     TBLKEY        READE     CODTBLR                                90
     C                   ENDDO
     C     LODEND        TAG
     C                   SETON                                        3234
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
     C                   MOVEL     S1CODE        WCODE
     C     S1OPT         CASEQ     '2'           CHGREC
     C     S1OPT         CASEQ     '4'           DLTREC
     C                   ENDCS
     C                   READC     SFLREC                                 91
     C                   ENDDO
     C                   ENDSR
      *****************************************************************
     C     CHGREC        BEGSR
     C     CTKEY         CHAIN     CODTBLR                            92
     C     *IN92         IFEQ      *ON
     C                   MOVEL     MSG(1)        MSGLIN
     C                   GOTO      CHGX
     C                   ENDIF
     C                   MOVEL     'CHANGE'      D1MODE
     C                   SETON                                        40
     C                   MOVEL     CTCODE        D1CODE
     C                   MOVEL     CTDESC        D1DESC
     C                   MOVEL     CTALT1        D1ALT1
     C                   MOVEL     CTALT2        D1ALT2
     C     CHG1          TAG
     C                   EXFMT     DTLREC
     C   12              GOTO      CHGX
     C   03              GOTO      CHGX
     C                   EXSR      EDTCHK
     C     *IN50         CABEQ     *ON           CHG1
TPK04C     CTKEY         CHAIN     CODTBLR                            92
     C                   MOVEL     D1DESC        CTDESC
     C                   MOVEL     D1ALT1        CTALT1
     C                   MOVEL     D1ALT2        CTALT2
     C                   UPDATE    CODTBLR
     C                   MOVEL     MSG(2)        MSGLIN
     C     CHGX          TAG
     C                   ENDSR
      *****************************************************************
     C     ADDREC        BEGSR
     C                   MOVEL     'ADD'         D1MODE
     C                   SETOFF                                       40
     C                   MOVE      *BLANKS       D1CODE
     C                   MOVE      *BLANKS       D1DESC
     C                   MOVE      *BLANKS       D1ALT1
     C                   MOVE      *BLANKS       D1ALT2
     C     ADD1          TAG
     C                   EXFMT     DTLREC
     C   12              GOTO      ADDX
     C   03              GOTO      ADDX
     C                   SETOFF                                       5556
     C     D1CODE        IFEQ      *BLANKS
     C                   SETON                                        56
     C                   GOTO      ADD1
     C                   ENDIF
     C                   MOVEL     D1CODE        WCODE
     C     CTKEY         CHAIN     CODTBLR                            92
     C     *IN92         IFEQ      *OFF
     C                   SETON                                        55
     C                   GOTO      ADD1
     C                   ENDIF
     C                   EXSR      EDTCHK
     C     *IN50         CABEQ     *ON           ADD1
     C                   MOVE      PTYPE         CTTYPE
     C                   MOVEL     D1CODE        CTCODE
     C                   MOVEL     D1DESC        CTDESC
     C                   MOVEL     D1ALT1        CTALT1
     C                   MOVEL     D1ALT2        CTALT2
     C                   WRITE     CODTBLR
     C                   MOVEL     MSG(3)        MSGLIN
     C     ADDX          TAG
     C                   ENDSR
      *****************************************************************
      *  DLTREC - NO CONFIRMATION, NO WHERE-USED CHECK
      *****************************************************************
     C     DLTREC        BEGSR
     C     CTKEY         CHAIN     CODTBLR                            92
     C     *IN92         IFEQ      *OFF
     C                   DELETE    CODTBLR
     C                   MOVEL     MSG(4)        MSGLIN
     C                   ENDIF
     C                   ENDSR
      *****************************************************************
      *  EDTCHK - TERRITORY MUST POINT TO A REGION
      *****************************************************************
     C     EDTCHK        BEGSR
     C                   SETOFF                                       505158
     C     D1DESC        IFEQ      *BLANKS
     C                   SETON                                        5051
     C                   ENDIF
     C     PTYPE         IFEQ      'TER'
     C                   MOVE      'REG'         WREG
     C                   MOVEL     D1ALT2        WCODE2
     C     REGKEY        CHAIN     CODTBLR                            93
     C   93              SETON                                        5058
     C                   ENDIF
     C                   ENDSR
**CTDATA TYP
REGRegions
SHPShippers
CATProduct Categories
TERSales Territories
DEMCustomer Demographic Types
**CTDATA MSG
Code not found
Code changed
Code added
Code deleted
Code is in use
No codes on file for this table
