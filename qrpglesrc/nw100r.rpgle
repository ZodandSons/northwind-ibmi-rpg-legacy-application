      *****************************************************************
      *  PROGRAM  : NW100R
      *  TITLE    : CUSTOMER MASTER FILE MAINTENANCE
      *  AUTHOR   : R. K. MILLER                     DATE: 03/14/88
      *
      *  MODIFICATION LOG
      *  DATE     BY   MARK   DESCRIPTION
      *  06/02/94 DLW  DLW94  ADDED PHONE/FAX EDIT, OPTION 8 = ORDERS
      *  11/23/99 JS   JS99   Y2K REVIEW - CREATE/CHANGE DATES OK (MMDDYY)
      *  04/10/03 TPK  TPK03  CONVERTED TO RPG IV (CVTRPGSRC)
      *  08/19/07 TPK  TPK07  LOGICAL DELETE INSTEAD OF DELETE (AUDIT)
      *  02/02/11 MH   MH11   OPTION 9 = CUSTOMER TYPES (CALL NW520R)
      *
      *  INDICATORS
      *   03 EXIT   06 ADD   12 CANCEL
      *   31-34 SUBFILE CONTROL
      *   40 PROTECT KEY  41 PROTECT ALL
      *   50 ERROR FOUND  51-57 FIELD ERRORS (ERRMSG IN DDS)
      *   90 EOF   91 READC EOF   92 NOT FOUND
      *****************************************************************
     HDATEDIT(*MDY)
     FNW100D    CF   E             WORKSTN SFILE(SFLREC:RRN)
     FCUSMST    UF A E           K DISK
     FCUSMSTL1  IF   E           K DISK    RENAME(CUSMSTR:CUSMST1)
      *
     DMSG              S             50    DIM(8) CTDATA PERRCD(1)
     DVALID            C                   '0123456789()-. '
      *
     DPSDS            SDS
     D@USER                  254    263
      *
DLW94DLDA             UDS                  DTAARA(*LDA)
DLW94DLDCUST                   1      5
DLW94DLDFILL                   6   1024
      *****************************************************************
      *  MAINLINE
      *****************************************************************
     C                   EXSR      LODSFL
     C     MAIN          TAG
     C                   WRITE     FMT01
     C                   MOVE      *BLANKS       MSGLIN
     C                   EXFMT     SFLCTL
     C   03              GOTO      ENDPGM
     C   12              GOTO      ENDPGM
     C   06              EXSR      ADDREC
     C   06              GOTO      RELOAD
      *  POSITION TO CHANGED - RELOAD
     C     C1POS         IFNE      SVPOS
     C                   EXSR      LODSFL
     C                   GOTO      MAIN
     C                   ENDIF
      *
     C                   EXSR      PRCOPT
     C     RELOAD        TAG
     C                   EXSR      LODSFL
     C                   GOTO      MAIN
      *
     C     ENDPGM        TAG
     C                   SETON                                        LR
     C                   RETURN
      *****************************************************************
      *  LODSFL - LOAD SUBFILE (ALL RECORDS FROM POSITION, MAX 500)
      *****************************************************************
     C     LODSFL        BEGSR
     C                   SETON                                        33
     C                   WRITE     SFLCTL
     C                   SETOFF                                       313233
     C                   Z-ADD     0             RRN               4 0
     C                   MOVE      C1POS         SVPOS            20
     C                   MOVEL     C1POS         POSKEY           40
     C                   MOVE      *BLANKS       POSKEY
     C                   MOVEL     C1POS         POSKEY
     C     POSKEY        SETLL     CUSMST1
     C                   READ      CUSMST1                                90
     C     *IN90         DOWEQ     *OFF
      * TPK07 - SKIP LOGICALLY DELETED CUSTOMERS
TPK07C     CMSTAT        IFNE      'D'
     C                   ADD       1             RRN
     C                   MOVE      *BLANK        S1OPT
     C                   MOVEL     CMCUST        S1CUST
     C                   MOVEL     CMNAME        S1NAME
     C                   MOVEL     CMCITY        S1CITY
     C                   MOVEL     CMCNTY        S1CNTY
     C                   WRITE     SFLREC
TPK07C                   ENDIF
      *  SUBFILE IS 500 RECORDS - STOP WHEN FULL
     C     RRN           CABEQ     500           LODEND
     C                   READ      CUSMST1                                90
     C                   ENDDO
     C     LODEND        TAG
      *
     C                   SETON                                        32
     C     RRN           IFGT      0
     C                   SETON                                        31
     C                   ELSE
     C                   MOVEL     MSG(6)        MSGLIN
     C                   ENDIF
     C                   SETON                                        34
     C                   ENDSR
      *****************************************************************
      *  PRCOPT - PROCESS SUBFILE OPTIONS
      *****************************************************************
     C     PRCOPT        BEGSR
     C                   READC     SFLREC                                 91
     C     *IN91         DOWEQ     *OFF
     C     S1OPT         CASEQ     '2'           CHGREC
     C     S1OPT         CASEQ     '4'           DLTCUS
     C     S1OPT         CASEQ     '5'           DSPREC
DLW94C     S1OPT         CASEQ     '8'           ORDREC
MH11 C     S1OPT         CASEQ     '9'           TYPREC
     C                   ENDCS
     C                   READC     SFLREC                                 91
     C                   ENDDO
     C                   ENDSR
      *****************************************************************
      *  CHGREC - CHANGE A CUSTOMER
      *****************************************************************
     C     CHGREC        BEGSR
     C     S1CUST        CHAIN     CUSMSTR                            92
     C     *IN92         IFEQ      *ON
     C                   MOVEL     MSG(1)        MSGLIN
     C                   ELSE
     C                   MOVEL     'CHANGE'      D1MODE
     C                   SETON                                        40
     C                   SETOFF                                       41
     C                   EXSR      MOVSCR
     C     CHG1          TAG
     C                   EXFMT     DTLREC
     C   12              GOTO      CHGX
     C   03              GOTO      CHGX
     C                   EXSR      EDTCHK
     C     *IN50         CABEQ     *ON           CHG1
     C                   EXSR      MOVFIL
     C                   MOVE      UDATE         CMCHDT
     C                   MOVEL     @USER         CMCHUS
     C                   UPDATE    CUSMSTR
     C                   MOVEL     MSG(2)        MSGLIN
     C     CHGX          TAG
     C                   ENDIF
     C                   ENDSR
      *****************************************************************
      *  ADDREC - ADD A NEW CUSTOMER
      *****************************************************************
     C     ADDREC        BEGSR
     C                   MOVEL     'ADD'         D1MODE
     C                   SETOFF                                       4041
     C                   EXSR      CLRSCR
     C     ADD1          TAG
     C                   EXFMT     DTLREC
     C   12              GOTO      ADDX
     C   03              GOTO      ADDX
     C                   SETOFF                                       5556
     C     D1CUST        IFEQ      *BLANKS
     C                   SETON                                        5056
     C                   GOTO      ADD1
     C                   ENDIF
      *  CHECK FOR DUPLICATE (FINDS DELETED ONES TOO)
     C     D1CUST        CHAIN     CUSMSTR                            92
     C     *IN92         IFEQ      *OFF
     C                   SETON                                        5055
     C                   GOTO      ADD1
     C                   ENDIF
     C                   EXSR      EDTCHK
     C     *IN50         CABEQ     *ON           ADD1
     C                   EXSR      MOVFIL
     C                   MOVEL     D1CUST        CMCUST
     C                   MOVE      *BLANK        CMSTAT
     C                   MOVE      UDATE         CMCRDT
     C                   MOVE      UDATE         CMCHDT
     C                   MOVEL     @USER         CMCHUS
     C                   WRITE     CUSMSTR
     C                   MOVEL     MSG(3)        MSGLIN
     C     ADDX          TAG
     C                   ENDSR
      *****************************************************************
      *  DLTCUS - DELETE (TPK07: NOW SETS CMSTAT = 'D')
      *****************************************************************
     C     DLTCUS        BEGSR
     C     S1CUST        CHAIN     CUSMSTR                            92
     C     *IN92         IFEQ      *ON
     C                   MOVEL     MSG(1)        MSGLIN
     C                   GOTO      DLTX
     C                   ENDIF
     C                   MOVEL     CMCUST        D2CUST
     C                   MOVEL     CMNAME        D2NAME
     C                   MOVE      'N'           D2CONF
     C                   EXFMT     DLTREC
     C   12              GOTO      DLTX
     C     D2CONF        IFEQ      'Y'
      *[TPK07]C                   DELETE    CUSMSTR
TPK07C                   MOVE      'D'           CMSTAT
TPK07C                   MOVE      UDATE         CMCHDT
TPK07C                   MOVEL     @USER         CMCHUS
TPK07C                   UPDATE    CUSMSTR
     C                   MOVEL     MSG(4)        MSGLIN
     C                   ENDIF
     C     DLTX          TAG
     C                   ENDSR
      *****************************************************************
      *  DSPREC - DISPLAY ONLY
      *****************************************************************
     C     DSPREC        BEGSR
     C     S1CUST        CHAIN     CUSMSTR                            92
     C     *IN92         IFEQ      *ON
     C                   MOVEL     MSG(1)        MSGLIN
     C                   ELSE
     C                   MOVEL     'DISPLAY'     D1MODE
     C                   SETON                                        4041
     C                   EXSR      MOVSCR
     C                   EXFMT     DTLREC
     C                   ENDIF
     C                   ENDSR
      *****************************************************************
      *  ORDREC - DLW94 SHOW ORDERS FOR CUSTOMER (PASS IN LDA)
      *****************************************************************
DLW94C     ORDREC        BEGSR
DLW94C                   MOVEL     S1CUST        LDCUST
DLW94C                   OUT       LDA
DLW94C                   CALL      'NW610R'
DLW94C                   ENDSR
      *****************************************************************
      *  TYPREC - MH11 CUSTOMER DEMOGRAPHIC TYPES
      *****************************************************************
MH11 C     TYPREC        BEGSR
MH11 C                   CALL      'NW520R'
MH11 C                   PARM                    S1CUST
MH11 C                   ENDSR
      *****************************************************************
      *  EDTCHK - EDIT SCREEN FIELDS
      *****************************************************************
     C     EDTCHK        BEGSR
     C                   SETOFF                                       505153
     C                   SETOFF                                       5457
     C     D1NAME        IFEQ      *BLANKS
     C                   SETON                                        5051
     C                   ENDIF
     C     D1CNTY        IFEQ      *BLANKS
     C                   SETON                                        5053
     C                   ENDIF
DLW94C     VALID         CHECK     D1PHON        POS               3 0    54
DLW94C   54              SETON                                        50
DLW94C     VALID         CHECK     D1FAX         POS                      57
DLW94C   57              SETON                                        50
     C                   ENDSR
      *****************************************************************
      *  MOVSCR - FILE TO SCREEN
      *****************************************************************
     C     MOVSCR        BEGSR
     C                   MOVEL     CMCUST        D1CUST
     C                   MOVEL     CMNAME        D1NAME
     C                   MOVEL     CMCONT        D1CONT
     C                   MOVEL     CMTITL        D1TITL
     C                   MOVEL     CMADDR        D1ADDR
     C                   MOVEL     CMCITY        D1CITY
     C                   MOVEL     CMREGN        D1REGN
     C                   MOVEL     CMPOST        D1POST
     C                   MOVEL     CMCNTY        D1CNTY
     C                   MOVEL     CMPHON        D1PHON
     C                   MOVEL     CMFAX         D1FAX
     C                   Z-ADD     CMCRDT        D1CRDT
     C                   Z-ADD     CMCHDT        D1CHDT
     C                   MOVEL     CMCHUS        D1CHUS
     C                   ENDSR
      *****************************************************************
      *  MOVFIL - SCREEN TO FILE
      *****************************************************************
     C     MOVFIL        BEGSR
     C                   MOVEL     D1NAME        CMNAME
     C                   MOVEL     D1CONT        CMCONT
     C                   MOVEL     D1TITL        CMTITL
     C                   MOVEL     D1ADDR        CMADDR
     C                   MOVEL     D1CITY        CMCITY
     C                   MOVEL     D1REGN        CMREGN
     C                   MOVEL     D1POST        CMPOST
     C                   MOVEL     D1CNTY        CMCNTY
     C                   MOVEL     D1PHON        CMPHON
     C                   MOVEL     D1FAX         CMFAX
     C                   ENDSR
      *****************************************************************
      *  CLRSCR - CLEAR DETAIL SCREEN
      *****************************************************************
     C     CLRSCR        BEGSR
     C                   MOVE      *BLANKS       D1CUST
     C                   MOVE      *BLANKS       D1NAME
     C                   MOVE      *BLANKS       D1CONT
     C                   MOVE      *BLANKS       D1TITL
     C                   MOVE      *BLANKS       D1ADDR
     C                   MOVE      *BLANKS       D1CITY
     C                   MOVE      *BLANKS       D1REGN
     C                   MOVE      *BLANKS       D1POST
     C                   MOVE      *BLANKS       D1CNTY
     C                   MOVE      *BLANKS       D1PHON
     C                   MOVE      *BLANKS       D1FAX
     C                   Z-ADD     0             D1CRDT
     C                   Z-ADD     0             D1CHDT
     C                   MOVE      *BLANKS       D1CHUS
     C                   ENDSR
**CTDATA MSG
Customer not found
Customer changed
Customer added
Customer deleted
Customer has open orders - not deleted
No customers found
Record in use by another user
Unexpected error - call I.S. dept x4357
