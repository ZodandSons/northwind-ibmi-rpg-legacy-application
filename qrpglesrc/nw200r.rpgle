      *****************************************************************
      *  PROGRAM  : NW200R
      *  TITLE    : EMPLOYEE MASTER MAINTENANCE
      *  AUTHOR   : D. L. WEBB                       DATE: 09/03/91
      *
      *  MODIFICATION LOG
      *  09/03/91 DLW         NEW PROGRAM - BASED ON NW100R
      *  02/14/96 DLW  DLW96  EMPLOYEE NOTES (FILE EMPNOT), 10 LINES MAX
      *  11/30/99 JS   JS99   Y2K - BIRTH/HIRE DATES EXPANDED TO 8 DIGITS
      *  04/10/03 TPK  TPK03  CONVERTED TO RPG IV
      *  03/22/05 TPK  TPK05  OPTION 9 = TERRITORIES (CALL NW510R)
      *
      *  NOTE: SUBFILE IS PAGE AT A TIME - ROLL DOWN NOT SUPPORTED
      *****************************************************************
     HDATEDIT(*MDY)
     FNW200D    CF   E             WORKSTN SFILE(SFLREC:RRN)
     FEMPMST    UF A E           K DISK
     FEMPMSTL1  IF   E           K DISK    RENAME(EMPMSTR:EMPMST1)
     FEMPMSTL2  IF   E           K DISK    RENAME(EMPMSTR:EMPMST2) PREFIX(X)
DLW96FEMPNOT    UF A E           K DISK
      *
     DDAYS             S              2  0 DIM(12) CTDATA PERRCD(12)
     DMSG              S             50    DIM(10) CTDATA PERRCD(1)
      *  MMDDYYYY SCREEN DATE BROKEN INTO PIECES
     DDATDS            DS
     DWMDY                     1      8  0
     DWMM                      1      2  0
     DWDD                      3      4  0
     DWYYYY                    5      8  0
      *  YYYYMMDD FILE DATE BROKEN INTO PIECES
     DYMDDS            DS
     DWYMD                     1      8  0
     DWY4                      1      4  0
     DWM2                      5      6  0
     DWD2                      7      8  0
DLW96 *  NOTES LINES - SCREEN FIELDS N01-N10 OVERLAY THE ARRAY NTE
DLW96DNOTDS            DS
DLW96DN01                      1     60
DLW96DN02                     61    120
DLW96DN03                    121    180
DLW96DN04                    181    240
DLW96DN05                    241    300
DLW96DN06                    301    360
DLW96DN07                    361    420
DLW96DN08                    421    480
DLW96DN09                    481    540
DLW96DN10                    541    600
DLW96DNTE                      1    600    DIM(10)
      *****************************************************************
     C     *LIKE         DEFINE    EMEMP#        WEMP
     C     *LIKE         DEFINE    EMEMP#        WRPT
DLW96C     NOTKEY        KLIST
DLW96C                   KFLD                    WEMP
      *
     C                   MOVE      *BLANKS       C1POS
     C                   EXSR      NEWPOS
     C     MAIN          TAG
     C                   WRITE     FMT01
     C                   EXFMT     SFLCTL
     C                   MOVE      *BLANKS       MSGLIN
     C   03              GOTO      ENDPGM
     C   12              GOTO      ENDPGM
      *  ROLL UP - NEXT PAGE
     C     *IN25         IFEQ      *ON
     C     *IN34         IFEQ      *ON
     C                   MOVEL     MSG(7)        MSGLIN
     C                   ELSE
     C                   EXSR      LODPAG
     C                   ENDIF
     C                   GOTO      MAIN
     C                   ENDIF
      *
     C   06              EXSR      ADDEMP
     C   06              EXSR      NEWPOS
     C   06              GOTO      MAIN
     C     C1POS         IFNE      SVPOS
     C                   EXSR      NEWPOS
     C                   GOTO      MAIN
     C                   ENDIF
     C                   EXSR      PRCOPT
     C                   EXSR      NEWPOS
     C                   GOTO      MAIN
      *
     C     ENDPGM        TAG
     C                   SETON                                        LR
      *****************************************************************
      *  NEWPOS - START LIST AT POSITION-TO NAME
      *****************************************************************
     C     NEWPOS        BEGSR
     C                   MOVE      C1POS         SVPOS            20
     C     C1POS         SETLL     EMPMST1
     C                   EXSR      LODPAG
     C                   ENDSR
      *****************************************************************
      *  LODPAG - LOAD ONE PAGE (12 RECORDS)
      *****************************************************************
     C     LODPAG        BEGSR
     C                   SETON                                        33
     C                   WRITE     SFLCTL
     C                   SETOFF                                       313334
     C                   Z-ADD     0             RRN               4 0
     C                   DO        12
     C                   READ      EMPMST1                                90
     C     *IN90         IFEQ      *ON
     C                   LEAVE
     C                   ENDIF
     C                   ADD       1             RRN
     C                   MOVE      *BLANK        S1OPT
     C                   Z-ADD     EMEMP#        S1EMP
     C                   MOVEL     EMLNAM        S1LNAM
     C                   MOVEL     EMFNAM        S1FNAM
     C                   MOVEL     EMTITL        S1TITL
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
      *  PRCOPT - SUBFILE OPTIONS
      *****************************************************************
     C     PRCOPT        BEGSR
     C                   READC     SFLREC                                 91
     C     *IN91         DOWEQ     *OFF
     C                   Z-ADD     S1EMP         WEMP
     C     S1OPT         CASEQ     '2'           CHGEMP
     C     S1OPT         CASEQ     '4'           DLTEMP
     C     S1OPT         CASEQ     '5'           DSPEMP
DLW96C     S1OPT         CASEQ     '7'           NOTES
TPK05C     S1OPT         CASEQ     '9'           TERR
     C                   ENDCS
     C                   READC     SFLREC                                 91
     C                   ENDDO
     C                   ENDSR
      *****************************************************************
      *  CHGEMP - CHANGE
      *****************************************************************
     C     CHGEMP        BEGSR
     C     WEMP          CHAIN     EMPMSTR                            92
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
     C                   EXSR      EDTEMP
     C     *IN50         CABEQ     *ON           CHG1
     C                   EXSR      MOVFIL
     C                   UPDATE    EMPMSTR
     C                   MOVEL     MSG(2)        MSGLIN
     C     CHGX          TAG
     C                   ENDSR
      *****************************************************************
      *  ADDEMP - ADD.  NEXT NUMBER = HIGHEST + 1
      *****************************************************************
     C     ADDEMP        BEGSR
     C                   MOVEL     'ADD'         D1MODE
     C                   SETOFF                                       4041
     C                   EXSR      CLRSCR
     C     *HIVAL        SETGT     EMPMSTR
     C                   READP     EMPMSTR                                90
     C     *IN90         IFEQ      *OFF
     C     EMEMP#        ADD       1             D1EMP
     C                   ELSE
     C                   Z-ADD     1             D1EMP
     C                   ENDIF
     C     ADD1          TAG
     C                   EXFMT     DTLREC
     C                   MOVE      *BLANKS       D1MSG
     C   12              GOTO      ADDX
     C   03              GOTO      ADDX
     C                   Z-ADD     D1EMP         WEMP
     C     WEMP          CHAIN     EMPMSTR                            92
     C     *IN92         IFEQ      *OFF
     C                   SETON                                        5051
     C                   MOVEL     MSG(3)        D1MSG
     C                   GOTO      ADD1
     C                   ENDIF
     C                   EXSR      EDTEMP
     C     *IN50         CABEQ     *ON           ADD1
     C                   EXSR      MOVFIL
     C                   Z-ADD     D1EMP         EMEMP#
     C                   MOVE      *BLANK        EMSTAT
     C                   WRITE     EMPMSTR
     C                   MOVEL     MSG(4)        MSGLIN
     C     ADDX          TAG
     C                   ENDSR
      *****************************************************************
      *  DLTEMP - DELETE EMPLOYEE
      *****************************************************************
     C     DLTEMP        BEGSR
     C     WEMP          CHAIN     EMPMSTR                            92
     C     *IN92         IFEQ      *ON
     C                   MOVEL     MSG(1)        MSGLIN
     C                   GOTO      DLTX
     C                   ENDIF
     C                   Z-ADD     EMEMP#        D2EMP
     C                   MOVEL     EMLNAM        D2NAME
     C                   MOVE      'N'           D2CONF
     C                   EXFMT     DLTREC
     C   12              GOTO      DLTX
     C     D2CONF        IFEQ      'Y'
     C                   DELETE    EMPMSTR
     C                   MOVEL     MSG(5)        MSGLIN
     C                   ENDIF
     C     DLTX          TAG
     C                   ENDSR
      *****************************************************************
      *  DSPEMP - DISPLAY
      *****************************************************************
     C     DSPEMP        BEGSR
     C     WEMP          CHAIN     EMPMSTR                            92
     C     *IN92         IFEQ      *OFF
     C                   MOVEL     'DISPLAY'     D1MODE
     C                   SETON                                        4041
     C                   EXSR      MOVSCR
     C                   EXFMT     DTLREC
     C                   ENDIF
     C                   ENDSR
      *****************************************************************
      *  NOTES - DLW96 MAINTAIN NOTES (DELETE ALL + REWRITE)
      *****************************************************************
DLW96C     NOTES         BEGSR
DLW96C     WEMP          CHAIN     EMPMST2                            93
DLW96C                   Z-ADD     WEMP          N0EMP
DLW96C                   MOVEL     XEMLNAM       N0NAME
DLW96C                   MOVE      *BLANKS       NOTDS
DLW96C                   Z-ADD     0             X                 3 0
DLW96C     NOTKEY        SETLL     EMPNOTR
DLW96C     NOTKEY        READE     EMPNOTR                                90
DLW96C     *IN90         DOWEQ     *OFF
DLW96C                   ADD       1             X
DLW96C     X             IFLE      10
DLW96C                   MOVEL     ENTEXT        NTE(X)
DLW96C                   ENDIF
DLW96C     NOTKEY        READE     EMPNOTR                                90
DLW96C                   ENDDO
DLW96C                   EXFMT     NOTREC
DLW96C   12              GOTO      NOTX
DLW96C   03              GOTO      NOTX
      *  REPLACE ALL LINES
DLW96C     NOTKEY        SETLL     EMPNOTR
DLW96C     NOTKEY        READE     EMPNOTR                                90
DLW96C     *IN90         DOWEQ     *OFF
DLW96C                   DELETE    EMPNOTR
DLW96C     NOTKEY        READE     EMPNOTR                                90
DLW96C                   ENDDO
DLW96C     1             DO        10            X
DLW96C     NTE(X)        IFNE      *BLANKS
DLW96C                   Z-ADD     WEMP          ENEMP#
DLW96C     X             MULT      10            ENSEQ
DLW96C                   MOVEL     NTE(X)        ENTEXT
DLW96C                   WRITE     EMPNOTR
DLW96C                   ENDIF
DLW96C                   ENDDO
DLW96C                   MOVEL     MSG(8)        MSGLIN
DLW96C     NOTX          TAG
DLW96C                   ENDSR
      *****************************************************************
      *  TERR - TPK05 EMPLOYEE TERRITORIES
      *****************************************************************
TPK05C     TERR          BEGSR
TPK05C                   CALL      'NW510R'
TPK05C                   PARM                    WEMP
TPK05C                   ENDSR
      *****************************************************************
      *  EDTEMP - EDIT FIELDS (ERROR TEXT ON LINE 23)
      *****************************************************************
     C     EDTEMP        BEGSR
     C                   SETOFF                                       505152
     C                   SETOFF                                       535657
     C                   SETOFF                                       58
     C                   MOVE      *BLANKS       D1RPNM
     C     D1LNAM        IFEQ      *BLANKS
     C                   SETON                                        5052
     C                   MOVEL     MSG(9)        D1MSG
     C                   GOTO      EDTX
     C                   ENDIF
     C     D1FNAM        IFEQ      *BLANKS
     C                   SETON                                        5053
     C                   MOVEL     MSG(9)        D1MSG
     C                   GOTO      EDTX
     C                   ENDIF
JS99 C                   Z-ADD     D1BDAT        WMDY
JS99 C                   EXSR      DATCHK
JS99 C     *IN59         IFEQ      *ON
JS99 C                   SETON                                        5056
JS99 C                   MOVEL     MSG(10)       D1MSG
JS99 C                   GOTO      EDTX
JS99 C                   ENDIF
JS99 C                   Z-ADD     D1HDAT        WMDY
JS99 C                   EXSR      DATCHK
JS99 C     *IN59         IFEQ      *ON
JS99 C                   SETON                                        5057
JS99 C                   MOVEL     MSG(10)       D1MSG
JS99 C                   GOTO      EDTX
JS99 C                   ENDIF
     C     D1RPTO        IFNE      0
     C                   Z-ADD     D1RPTO        WRPT
     C     WRPT          CHAIN     EMPMST2                            93
     C     *IN93         IFEQ      *ON
     C                   SETON                                        5058
     C                   MOVEL     MSG(1)        D1MSG
     C                   ELSE
     C                   MOVEL     XEMFNAM       D1RPNM
     C     D1RPNM        CAT       XEMLNAM:1     D1RPNM
     C                   ENDIF
     C                   ENDIF
     C     EDTX          TAG
     C                   ENDSR
      *****************************************************************
      *  DATCHK - VALIDATE MMDDYYYY DATE IN WMDY (59 = BAD)
      *           ZERO DATE IS ALLOWED
      *****************************************************************
JS99 C     DATCHK        BEGSR
JS99 C                   SETOFF                                       59
JS99 C     WMDY          CABEQ     0             DATX
JS99 C     WMM           CABLT     1             DATERR
JS99 C     WMM           CABGT     12            DATERR
JS99 C     WDD           CABLT     1             DATERR
      *  FEB 29 OK IN LEAP YEAR
JS99 C     WMM           IFEQ      2
JS99 C     WDD           ANDEQ     29
JS99 C     WYYYY         DIV       4             WQ                4 0
JS99 C                   MVR                     WR                2 0
JS99 C     WR            CABEQ     0             DATX
JS99 C                   ENDIF
JS99 C     WDD           CABGT     DAYS(WMM)     DATERR
JS99 C                   GOTO      DATX
JS99 C     DATERR        TAG
JS99 C                   SETON                                        59
JS99 C     DATX          TAG
JS99 C                   ENDSR
      *****************************************************************
      *  MOVSCR - FILE TO SCREEN
      *****************************************************************
     C     MOVSCR        BEGSR
     C                   Z-ADD     EMEMP#        D1EMP
     C                   MOVEL     EMLNAM        D1LNAM
     C                   MOVEL     EMFNAM        D1FNAM
     C                   MOVEL     EMTITL        D1TITL
     C                   MOVEL     EMCRTS        D1CRTS
     C                   Z-ADD     EMBDAT        WYMD
     C                   Z-ADD     WM2           WMM
     C                   Z-ADD     WD2           WDD
     C                   Z-ADD     WY4           WYYYY
     C                   Z-ADD     WMDY          D1BDAT
     C                   Z-ADD     EMHDAT        WYMD
     C                   Z-ADD     WM2           WMM
     C                   Z-ADD     WD2           WDD
     C                   Z-ADD     WY4           WYYYY
     C                   Z-ADD     WMDY          D1HDAT
     C                   MOVEL     EMADDR        D1ADDR
     C                   MOVEL     EMCITY        D1CITY
     C                   MOVEL     EMREGN        D1REGN
     C                   MOVEL     EMPOST        D1POST
     C                   MOVEL     EMCNTY        D1CNTY
     C                   MOVEL     EMHPHN        D1HPHN
     C                   MOVEL     EMEXT         D1EXT
     C                   Z-ADD     EMRPTO        D1RPTO
     C                   MOVE      *BLANKS       D1RPNM
     C                   MOVE      *BLANKS       D1MSG
     C                   ENDSR
      *****************************************************************
      *  MOVFIL - SCREEN TO FILE (DATES MMDDYYYY -> YYYYMMDD)
      *****************************************************************
     C     MOVFIL        BEGSR
     C                   MOVEL     D1LNAM        EMLNAM
     C                   MOVEL     D1FNAM        EMFNAM
     C                   MOVEL     D1TITL        EMTITL
     C                   MOVEL     D1CRTS        EMCRTS
     C                   Z-ADD     D1BDAT        WMDY
     C                   Z-ADD     WYYYY         WY4
     C                   Z-ADD     WMM           WM2
     C                   Z-ADD     WDD           WD2
     C                   Z-ADD     WYMD          EMBDAT
     C                   Z-ADD     D1HDAT        WMDY
     C                   Z-ADD     WYYYY         WY4
     C                   Z-ADD     WMM           WM2
     C                   Z-ADD     WDD           WD2
     C                   Z-ADD     WYMD          EMHDAT
     C                   MOVEL     D1ADDR        EMADDR
     C                   MOVEL     D1CITY        EMCITY
     C                   MOVEL     D1REGN        EMREGN
     C                   MOVEL     D1POST        EMPOST
     C                   MOVEL     D1CNTY        EMCNTY
     C                   MOVEL     D1HPHN        EMHPHN
     C                   MOVEL     D1EXT         EMEXT
     C                   Z-ADD     D1RPTO        EMRPTO
     C                   ENDSR
      *****************************************************************
      *  CLRSCR - CLEAR SCREEN FIELDS
      *****************************************************************
     C     CLRSCR        BEGSR
     C                   Z-ADD     0             D1EMP
     C                   MOVE      *BLANKS       D1LNAM
     C                   MOVE      *BLANKS       D1FNAM
     C                   MOVE      *BLANKS       D1TITL
     C                   MOVE      *BLANKS       D1CRTS
     C                   Z-ADD     0             D1BDAT
     C                   Z-ADD     0             D1HDAT
     C                   MOVE      *BLANKS       D1ADDR
     C                   MOVE      *BLANKS       D1CITY
     C                   MOVE      *BLANKS       D1REGN
     C                   MOVE      *BLANKS       D1POST
     C                   MOVE      *BLANKS       D1CNTY
     C                   MOVE      *BLANKS       D1HPHN
     C                   MOVE      *BLANKS       D1EXT
     C                   Z-ADD     0             D1RPTO
     C                   MOVE      *BLANKS       D1RPNM
     C                   MOVE      *BLANKS       D1MSG
     C                   ENDSR
**CTDATA DAYS
312831303130313130313031
**CTDATA MSG
Employee not found
Employee changed
Employee number already used
Employee added
Employee deleted
No employees found
No more records
Notes saved
Name is required
Date is not valid (MMDDYYYY)
