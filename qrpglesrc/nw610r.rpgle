      *****************************************************************
      *  PROGRAM  : NW610R
      *  TITLE    : ORDER INQUIRY
      *  AUTHOR   : R. K. MILLER                     DATE: 06/20/89
      *
      *  CUSTOMER FILTER IS TAKEN FROM THE LDA (POS 1-5) WHEN CALLED
      *  FROM NW100R OPTION 8
      *
      *  MODIFICATION LOG
      *  11/23/99 JS   JS99   Y2K - ORDER DATES ARE NOW CYYMMDD
      *  04/10/03 TPK  TPK03  CONVERTED TO RPG IV
      *  01/15/06 TPK  TPK06  OPTION 4 = CANCEL (STATUS C)
      *****************************************************************
     HDATEDIT(*MDY)
     FNW610D    CF   E             WORKSTN SFILE(SFLREC:RRN) SFILE(LINSFL:RRN2)
     FORDHDR    UF   E           K DISK
     FORDHDRL1  IF   E           K DISK    RENAME(ORDHDRR:ORDHDR1)
     FORDDTL    IF   E           K DISK
     FCUSMST    IF   E           K DISK
     FPRDMST    IF   E           K DISK
      *
     DLDA             UDS                  DTAARA(*LDA)
     DLDCUST                   1      5
      *  CYYMMDD -> MMDDYY CONVERSION FIELDS
     DYMDDS            DS
     DWYMD6                    1      6  0
     DWY                       1      2  0
     DWM                       3      4  0
     DWD                       5      6  0
     DMDYDS            DS
     DWMDY6                    1      6  0
     DXMM                      1      2  0
     DXDD                      3      4  0
     DXYY                      5      6  0
      *****************************************************************
     C     *LIKE         DEFINE    OHORD#        WORD
     C     DTLKEY        KLIST
     C                   KFLD                    WORD
      *  FILTER FROM LDA (SET BY NW100R)
     C                   MOVEL     LDCUST        C1CUST
     C                   EXSR      LODSFL
     C     MAIN          TAG
     C                   WRITE     FMT01
     C                   EXFMT     SFLCTL
     C                   MOVE      *BLANKS       MSGLIN
     C   03              GOTO      ENDPGM
     C   12              GOTO      ENDPGM
     C   05              EXSR      LODSFL
     C   05              GOTO      MAIN
     C     C1CUST        IFNE      SVCUST
     C                   EXSR      LODSFL
     C                   GOTO      MAIN
     C                   ENDIF
     C                   EXSR      PRCOPT
     C                   GOTO      MAIN
     C     ENDPGM        TAG
     C                   SETON                                        LR
      *****************************************************************
      *  LODSFL - ALL ORDERS (OLDEST FIRST) OR ONE CUSTOMER (NEWEST FIRST)
      *****************************************************************
     C     LODSFL        BEGSR
     C                   SETON                                        33
     C                   WRITE     SFLCTL
     C                   SETOFF                                       313233
     C                   Z-ADD     0             RRN               4 0
     C                   MOVE      C1CUST        SVCUST            5
     C     C1CUST        IFEQ      *BLANKS
     C     *LOVAL        SETLL     ORDHDRR
     C                   READ      ORDHDRR                                90
     C     *IN90         DOWEQ     *OFF
     C                   EXSR      ADDROW
     C     RRN           CABEQ     999           LODEND
     C                   READ      ORDHDRR                                90
     C                   ENDDO
     C                   ELSE
     C     C1CUST        SETLL     ORDHDR1
     C     C1CUST        READE     ORDHDR1                                90
     C     *IN90         DOWEQ     *OFF
     C                   EXSR      ADDROW
     C     RRN           CABEQ     999           LODEND
     C     C1CUST        READE     ORDHDR1                                90
     C                   ENDDO
     C                   ENDIF
     C     LODEND        TAG
     C                   SETON                                        3234
     C     RRN           IFGT      0
     C                   SETON                                        31
     C                   ELSE
     C                   MOVEL     'NO ORDERS'   MSGLIN
     C                   ENDIF
     C                   UNLOCK    ORDHDR
     C                   ENDSR
      *
     C     ADDROW        BEGSR
     C                   ADD       1             RRN
     C                   MOVE      *BLANK        S1OPT
     C                   Z-ADD     OHORD#        S1ORD
     C                   MOVEL     OHCUST        S1CUST
     C     OHCUST        CHAIN     CUSMSTR                            93
     C     *IN93         IFEQ      *ON
     C                   MOVEL     '*UNKNOWN'    S1CNAM
     C                   ELSE
     C                   MOVEL     CMNAME        S1CNAM
     C                   ENDIF
     C                   Z-ADD     OHODAT        WCYMD             7 0
     C                   EXSR      CYMMDY
     C                   Z-ADD     WMDY6         S1ODAT
     C                   MOVE      OHSTAT        S1STAT
     C                   Z-ADD     OHTOTL        S1TOTL
     C                   WRITE     SFLREC
     C                   ENDSR
      *****************************************************************
     C     PRCOPT        BEGSR
     C                   READC     SFLREC                                 91
     C     *IN91         DOWEQ     *OFF
     C                   Z-ADD     S1ORD         WORD
TPK06C     S1OPT         CASEQ     '4'           CANORD
     C     S1OPT         CASEQ     '5'           DSPORD
     C     S1OPT         CASEQ     '6'           PRTORD
     C                   ENDCS
     C                   MOVE      *BLANK        S1OPT
     C                   UPDATE    SFLREC
     C                   READC     SFLREC                                 91
     C                   ENDDO
     C                   ENDSR
      *****************************************************************
      *  CANORD - TPK06 CANCEL (STOCK IS NOT PUT BACK)
      *****************************************************************
TPK06C     CANORD        BEGSR
TPK06C     WORD          CHAIN     ORDHDRR                            92
TPK06C     *IN92         IFEQ      *ON
TPK06C                   MOVEL     'NOT FOUND'   MSGLIN
TPK06C                   GOTO      CANX
TPK06C                   ENDIF
TPK06C     OHSTAT        IFEQ      'S'
TPK06C                   EVAL      MSGLIN = 'Shipped orders cannot be cancelled'
TPK06C                   UNLOCK    ORDHDR
TPK06C                   GOTO      CANX
TPK06C                   ENDIF
TPK06C                   MOVE      'C'           OHSTAT
TPK06C                   UPDATE    ORDHDRR
TPK06C                   MOVE      'C'           S1STAT
TPK06C                   MOVEL     'CANCELLED'   MSGLIN
TPK06C     CANX          TAG
TPK06C                   ENDSR
      *****************************************************************
      *  DSPORD - SHOW HEADER AND LINES (EXTENDED PRICE RECALCULATED)
      *****************************************************************
     C     DSPORD        BEGSR
     C     WORD          CHAIN     ORDHDRR                            92
     C     *IN92         IFEQ      *ON
     C                   MOVEL     'NOT FOUND'   MSGLIN
     C                   GOTO      DSPX
     C                   ENDIF
     C                   Z-ADD     OHORD#        D1ORD
     C                   MOVEL     OHCUST        D1CUST
     C                   MOVEL     S1CNAM        D1CNAM
     C                   Z-ADD     OHODAT        WCYMD
     C                   EXSR      CYMMDY
     C                   Z-ADD     WMDY6         D1ODAT
     C                   Z-ADD     OHRDAT        WCYMD
     C                   EXSR      CYMMDY
     C                   Z-ADD     WMDY6         D1RDAT
     C                   Z-ADD     OHSDAT        WCYMD
     C                   EXSR      CYMMDY
     C                   Z-ADD     WMDY6         D1SDAT
     C                   MOVE      OHSTAT        D1STAT
     C                   MOVEL     OHSNAM        D1SNAM
     C                   MOVEL     OHSADR        D1SADR
     C                   MOVEL     OHSCTY        D1SCTY
     C                   MOVEL     OHSCNT        D1SCNT
     C                   MOVE      OHSHPV        D1SHPV
     C                   Z-ADD     OHFRT         D1FRT
     C                   Z-ADD     OHTOTL        D1TOTS
     C                   UNLOCK    ORDHDR
      *
     C                   SETON                                        37
     C                   WRITE     LINCTL
     C                   SETOFF                                       353637
     C                   Z-ADD     0             RRN2              4 0
     C                   Z-ADD     0             D1TOT
     C     DTLKEY        SETLL     ORDDTLR
     C     DTLKEY        READE     ORDDTLR                                90
     C     *IN90         DOWEQ     *OFF
     C                   ADD       1             RRN2
     C                   Z-ADD     ODLIN#        L1LIN
     C                   Z-ADD     ODPRD#        L1PRD
     C     ODPRD#        CHAIN     PRDMSTR                            93
     C     *IN93         IFEQ      *ON
     C                   MOVEL     '*DELETED'    L1NAME
     C                   ELSE
     C                   MOVEL     PMNAME        L1NAME
     C                   ENDIF
     C                   Z-ADD     ODQTY         L1QTY
     C                   Z-ADD     ODPRIC        L1PRIC
     C                   Z-ADD     ODDISC        L1DISC
      *  RECALCULATE EXTENDED PRICE (NO ROUNDING)
     C     ODPRIC        MULT      ODQTY         WGRS             11 2
     C     1             SUB       ODDISC        WPCT              5 4
     C     WGRS          MULT      WPCT          L1EXT
     C                   ADD       L1EXT         D1TOT
     C                   WRITE     LINSFL
     C     DTLKEY        READE     ORDDTLR                                90
     C                   ENDDO
     C                   SETON                                        3638
     C     RRN2          IFGT      0
     C                   SETON                                        35
     C                   ENDIF
     C                   WRITE     DSPFTR
     C                   EXFMT     LINCTL
     C     DSPX          TAG
     C                   ENDSR
      *****************************************************************
     C     PRTORD        BEGSR
     C                   CALL      'NW620C'
     C                   PARM                    WORD
     C                   MOVEL     'PRINTED'     MSGLIN
     C                   ENDSR
      *****************************************************************
      *  CYMMDY - CYYMMDD (WCYMD) TO MMDDYY (WMDY6) - CENTURY DROPPED
      *****************************************************************
JS99 C     CYMMDY        BEGSR
JS99 C                   MOVE      WCYMD         WYMD6
JS99 C                   Z-ADD     WM            XMM
JS99 C                   Z-ADD     WD            XDD
JS99 C                   Z-ADD     WY            XYY
JS99 C                   ENDSR
