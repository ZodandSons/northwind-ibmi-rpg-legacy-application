      *****************************************************************
      *  PROGRAM  : NW300R
      *  TITLE    : SUPPLIER MASTER FILE MAINTENANCE
      *  AUTHOR   : B. J. THOMAS                     DATE: 05/20/96
      *             (COPIED FROM NW100R CUSTOMER MAINTENANCE)
      *
      *  MODIFICATION LOG
      *  05/20/96 BJT         NEW - SCREEN FIELDS NOW REFERENCE SUPMST SO
      *                       NO MORE MOVE STATEMENTS NEEDED
      *  04/10/03 TPK  TPK03  CONVERTED TO RPG IV
      *
      *  INDICATORS - SAME AS NW100R
      *****************************************************************
     HDATEDIT(*MDY)
     FNW300D    CF   E             WORKSTN SFILE(SFLREC:RRN)
     FSUPMST    UF A E           K DISK
     FSUPMSTL1  IF   E           K DISK    RENAME(SUPMSTR:SUPMST1)
      *
     DMSG              S             50    DIM(8) CTDATA PERRCD(1)
     DVALID            C                   '0123456789()-. '
      *****************************************************************
     C     *LIKE         DEFINE    SMSUP#        WSUP
     C                   EXSR      LODSFL
     C     MAIN          TAG
     C                   WRITE     FMT01
     C                   MOVE      *BLANKS       MSGLIN
     C                   EXFMT     SFLCTL
     C   03              GOTO      ENDPGM
     C   12              GOTO      ENDPGM
     C   06              EXSR      ADDREC
     C   06              GOTO      RELOAD
     C     C1POS         IFNE      SVPOS
     C                   EXSR      LODSFL
     C                   GOTO      MAIN
     C                   ENDIF
     C                   EXSR      PRCOPT
     C     RELOAD        TAG
     C                   EXSR      LODSFL
     C                   GOTO      MAIN
     C     ENDPGM        TAG
     C                   SETON                                        LR
     C                   RETURN
      *****************************************************************
      *  LODSFL - LOAD SUBFILE
      *****************************************************************
     C     LODSFL        BEGSR
     C                   SETON                                        33
     C                   WRITE     SFLCTL
     C                   SETOFF                                       313233
     C                   Z-ADD     0             RRN               4 0
     C                   MOVE      C1POS         SVPOS            20
     C                   MOVE      *BLANKS       POSKEY           40
     C                   MOVEL     C1POS         POSKEY
     C     POSKEY        SETLL     SUPMST1
     C                   READ      SUPMST1                                90
     C     *IN90         DOWEQ     *OFF
     C                   ADD       1             RRN
     C                   MOVE      *BLANK        S1OPT
     C                   Z-ADD     SMSUP#        S1SUP
     C                   MOVEL     SMNAME        S1NAME
     C                   MOVEL     SMCITY        S1CITY
     C                   MOVEL     SMCNTY        S1CNTY
     C                   WRITE     SFLREC
     C     RRN           CABEQ     500           LODEND
     C                   READ      SUPMST1                                90
     C                   ENDDO
     C     LODEND        TAG
     C                   SETON                                        32
     C     RRN           IFGT      0
     C                   SETON                                        31
     C                   ELSE
     C                   MOVEL     MSG(6)        MSGLIN
     C                   ENDIF
     C                   SETON                                        34
     C                   ENDSR
      *****************************************************************
      *  PRCOPT - PROCESS OPTIONS
      *****************************************************************
     C     PRCOPT        BEGSR
     C                   READC     SFLREC                                 91
     C     *IN91         DOWEQ     *OFF
     C                   Z-ADD     S1SUP         WSUP
     C     S1OPT         CASEQ     '2'           CHGREC
     C     S1OPT         CASEQ     '4'           DLTSUP
     C     S1OPT         CASEQ     '5'           DSPREC
     C                   ENDCS
     C                   READC     SFLREC                                 91
     C                   ENDDO
     C                   ENDSR
      *****************************************************************
      *  CHGREC - CHANGE (FILE FIELDS ARE THE SCREEN FIELDS)
      *****************************************************************
     C     CHGREC        BEGSR
     C     WSUP          CHAIN     SUPMSTR                            92
     C     *IN92         IFEQ      *ON
     C                   MOVEL     MSG(1)        MSGLIN
     C                   ELSE
     C                   MOVEL     'CHANGE'      D1MODE
     C                   SETON                                        40
     C                   SETOFF                                       41
     C     CHG1          TAG
     C                   EXFMT     DTLREC
     C   12              GOTO      CHGX
     C   03              GOTO      CHGX
     C                   EXSR      EDTCHK
     C     *IN50         CABEQ     *ON           CHG1
     C                   UPDATE    SUPMSTR
     C                   MOVEL     MSG(2)        MSGLIN
     C     CHGX          TAG
     C                   ENDIF
     C                   ENDSR
      *****************************************************************
      *  ADDREC - ADD (NEXT NUMBER LOGIC COPIED FROM NW200R)
      *****************************************************************
     C     ADDREC        BEGSR
     C                   MOVEL     'ADD'         D1MODE
     C                   SETON                                        40
     C                   SETOFF                                       41
     C     *HIVAL        SETGT     SUPMSTR
     C                   READP     SUPMSTR                                90
     C                   Z-ADD     1             WSUP
     C     *IN90         IFEQ      *OFF
     C     SMSUP#        ADD       1             WSUP
     C                   ENDIF
TPK03C                   CLEAR                   SUPMSTR
     C                   Z-ADD     WSUP          SMSUP#
     C     ADD1          TAG
     C                   EXFMT     DTLREC
     C   12              GOTO      ADDX
     C   03              GOTO      ADDX
     C                   EXSR      EDTCHK
     C     *IN50         CABEQ     *ON           ADD1
     C                   MOVE      *BLANK        SMSTAT
     C                   WRITE     SUPMSTR
     C                   MOVEL     MSG(3)        MSGLIN
     C     ADDX          TAG
     C                   ENDSR
      *****************************************************************
      *  DLTSUP - DELETE (PHYSICAL - PRODUCTS ARE NOT CHECKED)
      *****************************************************************
     C     DLTSUP        BEGSR
     C     WSUP          CHAIN     SUPMSTR                            92
     C     *IN92         IFEQ      *ON
     C                   MOVEL     MSG(1)        MSGLIN
     C                   GOTO      DLTX
     C                   ENDIF
     C                   Z-ADD     SMSUP#        D2SUP
     C                   MOVEL     SMNAME        D2NAME
     C                   MOVE      'N'           D2CONF
     C                   EXFMT     DLTREC
     C   12              GOTO      DLTX
     C     D2CONF        IFEQ      'Y'
     C                   DELETE    SUPMSTR
     C                   MOVEL     MSG(4)        MSGLIN
     C                   ENDIF
     C     DLTX          TAG
     C                   ENDSR
      *****************************************************************
      *  DSPREC - DISPLAY
      *****************************************************************
     C     DSPREC        BEGSR
     C     WSUP          CHAIN     SUPMSTR                            92
     C     *IN92         IFEQ      *ON
     C                   MOVEL     MSG(1)        MSGLIN
     C                   ELSE
     C                   MOVEL     'DISPLAY'     D1MODE
     C                   SETON                                        4041
     C                   EXFMT     DTLREC
     C                   ENDIF
     C                   ENDSR
      *****************************************************************
      *  EDTCHK - EDIT (SAME AS NW100R)
      *****************************************************************
     C     EDTCHK        BEGSR
     C                   SETOFF                                       505153
     C                   SETOFF                                       5457
     C     SMNAME        IFEQ      *BLANKS
     C                   SETON                                        5051
     C                   ENDIF
     C     SMCNTY        IFEQ      *BLANKS
     C                   SETON                                        5053
     C                   ENDIF
     C     VALID         CHECK     SMPHON        POS               3 0    54
     C   54              SETON                                        50
      * FAX CHECK REMOVED 1997 - FOREIGN FAX NUMBERS HAVE LETTERS BJT
      *C    VALID         CHECK     SMFAX         POS                      57
      *C  57               SETON                                        50
     C                   ENDSR
      *****************************************************************
      *  OLDCHK - NOT USED SINCE 1997 - DO NOT DELETE (BJT)
      *****************************************************************
     C     OLDCHK        BEGSR
     C     SMPOST        IFEQ      *BLANKS
     C     SMCNTY        ANDEQ     'USA'
     C                   SETON                                        50
     C                   ENDIF
     C                   ENDSR
**CTDATA MSG
Customer not found
Supplier changed
Supplier added
Supplier deleted
Customer has products - not deleted
No suppliers found
Record in use by another user
Unexpected error - call I.S. dept x4357
