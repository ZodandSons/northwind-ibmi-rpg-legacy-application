      *****************************************************************
      *  PROGRAM  : NW600R
      *  TITLE    : ORDER ENTRY
      *  AUTHOR   : R. K. MILLER                     DATE: 05/02/89
      *
      *  MODIFICATION LOG
      *  05/02/89 RKM         NEW PROGRAM
      *  08/12/97 JS   JS97   F4 PROMPTS (CALL NW190R / NW490R)
      *  11/23/99 JS   JS99   Y2K - ORDER DATES STORED CYYMMDD, SCREEN STAYS
      *                       MMDDYY, WINDOW: YY < 40 = 20YY
      *  06/06/01 JS   JS01   DATE CHECK MOVED TO COPY MEMBER DATCHK
      *  01/08/90 RKM  RKM90  FEOD BEFORE INVOICE CALL (BLANK INVOICES)
      *  03/03/02 RKM  RKM02  RELIEVE INVENTORY WHEN ORDER IS WRITTEN
      *  04/10/03 TPK  TPK03  CONVERTED TO RPG IV
      *
      *  NOTE: ORDER NUMBER COMES FROM DATA AREA NWNXTORD
      *****************************************************************
     HDATEDIT(*MDY)
     FNW600D    CF   E             WORKSTN
     FCUSMST    IF   E           K DISK
     FEMPMST    IF   E           K DISK
     FCODTBL    IF   E           K DISK
RKM02FPRDMST    UF   E           K DISK
     FORDHDR    OF   E           K DISK
     FORDDTL    OF   E           K DISK
      *
     DDAYS             S              2  0 DIM(12) CTDATA PERRCD(12)
      *  MMDDYY WORK DATE - FIELD NAMES ARE USED BY COPY MEMBER DATCHK
     DDAT6             DS
     DWMDY6                    1      6  0
     DWMM                      1      2  0
     DWDD                      3      4  0
     DWYY                      5      6  0
      *  LINE ARRAYS OVER THE 10 SCREEN LINES
     DLPRDDS           DS
     DLPRD01                   1      5  0
     DLPRD02                   6     10  0
     DLPRD03                  11     15  0
     DLPRD04                  16     20  0
     DLPRD05                  21     25  0
     DLPRD06                  26     30  0
     DLPRD07                  31     35  0
     DLPRD08                  36     40  0
     DLPRD09                  41     45  0
     DLPRD10                  46     50  0
     DXPRD                     1     50  0 DIM(10)
     DLNAMDS           DS
     DLNAM01                   1     25
     DLNAM02                  26     50
     DLNAM03                  51     75
     DLNAM04                  76    100
     DLNAM05                 101    125
     DLNAM06                 126    150
     DLNAM07                 151    175
     DLNAM08                 176    200
     DLNAM09                 201    225
     DLNAM10                 226    250
     DXNAM                     1    250    DIM(10)
     DLQTYDS           DS
     DLQTY01                   1      5  0
     DLQTY02                   6     10  0
     DLQTY03                  11     15  0
     DLQTY04                  16     20  0
     DLQTY05                  21     25  0
     DLQTY06                  26     30  0
     DLQTY07                  31     35  0
     DLQTY08                  36     40  0
     DLQTY09                  41     45  0
     DLQTY10                  46     50  0
     DXQTY                     1     50  0 DIM(10)
     DLPRCDS           DS
     DLPRC01                   1      7  2
     DLPRC02                   8     14  2
     DLPRC03                  15     21  2
     DLPRC04                  22     28  2
     DLPRC05                  29     35  2
     DLPRC06                  36     42  2
     DLPRC07                  43     49  2
     DLPRC08                  50     56  2
     DLPRC09                  57     63  2
     DLPRC10                  64     70  2
     DXPRC                     1     70  2 DIM(10)
     DLDSCDS           DS
     DLDSC01                   1      2  0
     DLDSC02                   3      4  0
     DLDSC03                   5      6  0
     DLDSC04                   7      8  0
     DLDSC05                   9     10  0
     DLDSC06                  11     12  0
     DLDSC07                  13     14  0
     DLDSC08                  15     16  0
     DLDSC09                  17     18  0
     DLDSC10                  19     20  0
     DXDSC                     1     20  0 DIM(10)
     DLEXTDS           DS
     DLEXT01                   1      9  2
     DLEXT02                  10     18  2
     DLEXT03                  19     27  2
     DLEXT04                  28     36  2
     DLEXT05                  37     45  2
     DLEXT06                  46     54  2
     DLEXT07                  55     63  2
     DLEXT08                  64     72  2
     DLEXT09                  73     81  2
     DLEXT10                  82     90  2
     DXEXT                     1     90  2 DIM(10)
      *
     DPSDS            SDS
     D@USER                  254    263
      *****************************************************************
     C     *LIKE         DEFINE    EMEMP#        WEMP
     C     *LIKE         DEFINE    PMPRD#        WPRD
     C     *DTAARA       DEFINE    NWNXTORD      NXTORD            7 0
     C     SHPKEY        KLIST
     C                   KFLD                    WTYPE
     C                   KFLD                    WCODE
     C     *LIKE         DEFINE    CTTYPE        WTYPE
     C     *LIKE         DEFINE    CTCODE        WCODE
      *
     C                   EXSR      NEWORD
     C     HDR           TAG
     C                   EXFMT     HDRREC
     C                   MOVE      *BLANKS       H1MSG
     C   03              GOTO      ENDPGM
     C   12              GOTO      ENDPGM
JS97 C     *IN04         IFEQ      *ON
JS97 C                   CALL      'NW190R'
JS97 C                   PARM                    H1CUST
JS97 C                   GOTO      HDR
JS97 C                   ENDIF
     C                   EXSR      EDTHDR
     C     *IN50         CABEQ     *ON           HDR
      *
     C                   MOVEL     H1CUST        L0CUST
     C                   MOVEL     H1CNAM        L0CNAM
     C                   Z-ADD     H1FRT         L0FRT
     C                   EXSR      CALC
     C     LIN           TAG
     C                   EXFMT     LINREC
     C                   MOVE      *BLANKS       L0MSG
     C   03              GOTO      ENDPGM
     C   12              GOTO      HDR
JS97 C     *IN04         IFEQ      *ON
JS97 C                   EXSR      PRMPRD
JS97 C                   EXSR      CALC
JS97 C                   GOTO      LIN
JS97 C                   ENDIF
     C                   EXSR      CALC
     C     *IN50         CABEQ     *ON           LIN
     C  N10              GOTO      LIN
     C     WTOT          IFEQ      0
     C                   MOVEL     'NO ITEMS'    L0MSG
     C                   GOTO      LIN
     C                   ENDIF
     C                   EXSR      WRTORD
     C                   EXSR      NEWORD
     C                   GOTO      HDR
      *
     C     ENDPGM        TAG
     C                   SETON                                        LR
      *****************************************************************
      *  NEWORD - CLEAR FOR A NEW ORDER
      *****************************************************************
     C     NEWORD        BEGSR
     C                   Z-ADD     0             H1ORD
     C                   MOVE      *BLANKS       H1CUST
     C                   MOVE      *BLANKS       H1CNAM
     C                   Z-ADD     0             H1EMP
     C                   MOVE      *BLANKS       H1ENAM
     C                   Z-ADD     UDATE         H1ODAT
     C                   Z-ADD     0             H1RDAT
     C                   MOVE      '1'           H1SHPV
     C                   MOVE      *BLANKS       H1SHPN
     C                   Z-ADD     0             H1FRT
     C                   MOVE      *BLANKS       H1SNAM
     C                   MOVE      *BLANKS       H1SADR
     C                   MOVE      *BLANKS       H1SCTY
     C                   MOVE      *BLANKS       H1SREG
     C                   MOVE      *BLANKS       H1SPST
     C                   MOVE      *BLANKS       H1SCNT
     C                   Z-ADD     0             XPRD
     C                   MOVE      *BLANKS       XNAM
     C                   Z-ADD     0             XQTY
     C                   Z-ADD     0             XPRC
     C                   Z-ADD     0             XDSC
     C                   Z-ADD     0             XEXT
     C                   Z-ADD     0             L0TOT
     C                   MOVE      'N'           L0PRT
     C                   ENDSR
      *****************************************************************
      *  EDTHDR - EDIT THE HEADER (STOPS AT FIRST ERROR)
      *****************************************************************
     C     EDTHDR        BEGSR
     C                   SETOFF                                       505152
     C                   SETOFF                                       535455
     C     H1CUST        CHAIN     CUSMSTR                            92
     C     *IN92         IFEQ      *ON
     C                   SETON                                        5051
     C                   MOVEL     'CUSTOMER?'   H1MSG
     C                   GOTO      EDTX
     C                   ENDIF
     C                   MOVEL     CMNAME        H1CNAM
      *  DEFAULT SHIP-TO FROM CUSTOMER WHEN BLANK
     C     H1SNAM        IFEQ      *BLANKS
     C                   MOVEL     CMNAME        H1SNAM
     C                   MOVEL     CMADDR        H1SADR
     C                   MOVEL     CMCITY        H1SCTY
     C                   MOVEL     CMREGN        H1SREG
     C                   MOVEL     CMPOST        H1SPST
     C                   MOVEL     CMCNTY        H1SCNT
     C                   ENDIF
     C                   Z-ADD     H1EMP         WEMP
     C     WEMP          CHAIN     EMPMSTR                            92
     C     *IN92         IFEQ      *ON
     C                   SETON                                        5052
     C                   MOVEL     'EMPLOYEE?'   H1MSG
     C                   GOTO      EDTX
     C                   ENDIF
     C                   MOVEL     EMFNAM        H1ENAM
     C     H1ENAM        CAT       EMLNAM:1      H1ENAM
JS01 C                   Z-ADD     H1ODAT        WMDY6
JS01 C                   EXSR      DATCHK
JS01 C     *IN59         IFEQ      *ON
JS01 C     WMDY6         OREQ      0
JS01 C                   SETON                                        5053
JS01 C                   MOVEL     'ORDER DATE?' H1MSG
JS01 C                   GOTO      EDTX
JS01 C                   ENDIF
JS01 C                   Z-ADD     H1RDAT        WMDY6
JS01 C                   EXSR      DATCHK
JS01 C     *IN59         IFEQ      *ON
JS01 C                   SETON                                        5054
JS01 C                   MOVEL     'REQ DATE?'   H1MSG
JS01 C                   GOTO      EDTX
JS01 C                   ENDIF
     C                   MOVE      'SHP'         WTYPE
     C                   MOVE      *BLANKS       WCODE
     C                   MOVEL     H1SHPV        WCODE
     C     SHPKEY        CHAIN     CODTBLR                            92
     C     *IN92         IFEQ      *ON
     C                   SETON                                        5055
     C                   MOVEL     'SHIP VIA?'   H1MSG
     C                   ELSE
     C                   MOVEL     CTDESC        H1SHPN
     C                   ENDIF
     C     EDTX          TAG
     C                   ENDSR
      *****************************************************************
      *  CALC - LOOK UP PRODUCTS, DEFAULT PRICE, EXTEND, TOTAL
      *****************************************************************
     C     CALC          BEGSR
     C                   SETOFF                                       50
     C                   Z-ADD     0             WTOT             11 2
     C                   MOVEA     '0000000000'  *IN(61)
     C     1             DO        10            I                 3 0
     C     XPRD(I)       IFEQ      0
     C                   MOVE      *BLANKS       XNAM(I)
     C                   Z-ADD     0             XEXT(I)
     C                   ITER
     C                   ENDIF
     C                   Z-ADD     XPRD(I)       WPRD
     C     WPRD          CHAIN     PRDMSTR                            93
     C     *IN93         IFEQ      *ON
     C                   MOVEL     '*NOT FOUND'  XNAM(I)
     C                   Z-ADD     0             XEXT(I)
     C                   SETON                                        50
     C     I             ADD       60            J                 3 0
     C                   MOVE      *ON           *IN(J)
     C                   ITER
     C                   ENDIF
     C                   MOVEL     PMNAME        XNAM(I)
     C     XPRC(I)       IFEQ      0
     C                   Z-ADD     PMPRIC        XPRC(I)
     C                   ENDIF
     C     XQTY(I)       IFEQ      0
     C                   Z-ADD     1             XQTY(I)
     C                   ENDIF
      *  EXTENDED = PRICE * QTY - DISCOUNT (ROUNDED)
     C     XPRC(I)       MULT(H)   XQTY(I)       WGRS             11 2
     C     WGRS          MULT      XDSC(I)       WDAMT            13 2
     C     WDAMT         DIV(H)    100           WDAMT
     C     WGRS          SUB       WDAMT         XEXT(I)
     C                   ADD       XEXT(I)       WTOT
     C                   ENDDO
     C                   Z-ADD     WTOT          L0TOT
     C   50              MOVEL     'CHECK ITEMS' L0MSG
     C                   ENDSR
      *****************************************************************
      *  PRMPRD - F4 PRODUCT PROMPT INTO FIRST EMPTY LINE
      *****************************************************************
JS97 C     PRMPRD        BEGSR
JS97 C                   Z-ADD     0             WPRD
JS97 C                   CALL      'NW490R'
JS97 C                   PARM                    WPRD
JS97 C     WPRD          IFNE      0
JS97 C                   Z-ADD     1             I
JS97 C     0             LOOKUP    XPRD(I)                                81
JS97 C     *IN81         IFEQ      *ON
JS97 C                   Z-ADD     WPRD          XPRD(I)
JS97 C                   ELSE
JS97 C                   MOVEL     'ORDER FULL'  L0MSG
JS97 C                   ENDIF
JS97 C                   ENDIF
JS97 C                   ENDSR
      *****************************************************************
      *  WRTORD - WRITE HEADER, LINES, RELIEVE STOCK, PRINT
      *****************************************************************
     C     WRTORD        BEGSR
     C     *LOCK         IN        NXTORD
     C                   Z-ADD     NXTORD        WORD              7 0
     C                   ADD       1             NXTORD
     C                   OUT       NXTORD
      *
     C                   Z-ADD     WORD          OHORD#
     C                   MOVEL     H1CUST        OHCUST
     C                   Z-ADD     H1EMP         OHEMP#
JS99 C                   Z-ADD     H1ODAT        WMDY6
JS99 C                   EXSR      CVTCYM
JS99 C                   Z-ADD     WCYMD         OHODAT
JS99 C                   Z-ADD     0             OHRDAT
JS99 C     H1RDAT        IFNE      0
JS99 C                   Z-ADD     H1RDAT        WMDY6
JS99 C                   EXSR      CVTCYM
JS99 C                   Z-ADD     WCYMD         OHRDAT
JS99 C                   ENDIF
     C                   Z-ADD     0             OHSDAT
     C                   MOVE      H1SHPV        OHSHPV
     C                   Z-ADD     H1FRT         OHFRT
     C                   MOVEL     H1SNAM        OHSNAM
     C                   MOVEL     H1SADR        OHSADR
     C                   MOVEL     H1SCTY        OHSCTY
     C                   MOVEL     H1SREG        OHSREG
     C                   MOVEL     H1SPST        OHSPST
     C                   MOVEL     H1SCNT        OHSCNT
      *  OHTOTL = ITEMS ONLY (FREIGHT NOT INCLUDED)
     C                   Z-ADD     WTOT          OHTOTL
     C                   MOVE      'O'           OHSTAT
     C                   MOVEL     @USER         OHENTU
     C                   MOVE      UDATE         OHENTD
     C                   WRITE     ORDHDRR
      *
     C                   Z-ADD     0             WLIN              3 0
     C     1             DO        10            I
     C     XPRD(I)       IFNE      0
     C                   ADD       1             WLIN
     C                   Z-ADD     WORD          ODORD#
     C                   Z-ADD     WLIN          ODLIN#
     C                   Z-ADD     XPRD(I)       ODPRD#
     C                   Z-ADD     XQTY(I)       ODQTY
     C                   Z-ADD     XPRC(I)       ODPRIC
     C     XDSC(I)       DIV       100           ODDISC
     C                   Z-ADD     XEXT(I)       ODEXT
     C                   WRITE     ORDDTLR
RKM02C                   Z-ADD     XPRD(I)       WPRD
RKM02C     WPRD          CHAIN     PRDMSTR                            93
RKM02C     *IN93         IFEQ      *OFF
RKM02C     PMSTCK        SUB       XQTY(I)       PMSTCK
RKM02C                   UPDATE    PRDMSTR
RKM02C                   ENDIF
     C                   ENDIF
     C                   ENDDO
      *
      *  FORCE BLOCKED RECORDS TO DISK - INVOICE PRINTED EMPTY  RKM 01/90
RKM90C                   FEOD      ORDHDR
RKM90C                   FEOD      ORDDTL
     C     L0PRT         IFEQ      'Y'
     C                   CALL      'NW620C'
     C                   PARM                    WORD
     C                   ENDIF
     C                   MOVE      WORD          WORDA             7
     C     'ORDER'       CAT       WORDA:1       H1MSG
     C     H1MSG         CAT       'ENTERED':1   H1MSG
     C                   ENDSR
      *****************************************************************
      *  CVTCYM - MMDDYY (WMDY6) TO CYYMMDD (WCYMD)  -  JS99
      *****************************************************************
JS99 C     CVTCYM        BEGSR
JS99 C     WYY           IFLT      40
JS99 C                   Z-ADD     1000000       WCYMD             7 0
JS99 C                   ELSE
JS99 C                   Z-ADD     0             WCYMD
JS99 C                   ENDIF
JS99 C     WYY           MULT      10000         WTMP              7 0
JS99 C                   ADD       WTMP          WCYMD
JS99 C     WMM           MULT      100           WTMP
JS99 C                   ADD       WTMP          WCYMD
JS99 C                   ADD       WDD           WCYMD
JS99 C                   ENDSR
      *
      /COPY QRPGLESRC,DATCHK
**CTDATA DAYS
312831303130313130313031
