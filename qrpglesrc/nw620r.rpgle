      *****************************************************************
      *  PROGRAM  : NW620R
      *  TITLE    : PRINT INVOICE FOR ONE ORDER
      *  AUTHOR   : R. K. MILLER                     DATE: 07/11/89
      *
      *  PARAMETER: ORDER NUMBER (7,0)   CALLED BY NW620C (OVRPRTF)
      *
      *  MODIFICATION LOG
      *  11/23/99 JS   JS99   Y2K - ORDER DATE CYYMMDD
      *  04/10/03 TPK  TPK03  CONVERTED TO RPG IV
      *  10/02/08 TPK  TPK08  COMPANY NAME FROM DATA AREA NWCOMP
      *****************************************************************
     HDATEDIT(*MDY)
     FORDHDR    IF   E           K DISK
     FORDDTL    IF   E           K DISK
     FCUSMST    IF   E           K DISK
     FPRDMST    IF   E           K DISK
     FQSYSPRT   OF   F  132        PRINTER OFLIND(*INOF)
      *****************************************************************
     C     *ENTRY        PLIST
     C                   PARM                    PORD              7 0
     C     DTLKEY        KLIST
     C                   KFLD                    PORD
TPK08C     *DTAARA       DEFINE    NWCOMP        COMPNM           40
TPK08C                   IN        COMPNM
      *
     C     PORD          CHAIN     ORDHDRR                            90
     C     *IN90         IFEQ      *ON
     C                   SETON                                        LR
     C                   RETURN
     C                   ENDIF
     C     OHCUST        CHAIN     CUSMSTR                            91
     C   91              MOVE      *BLANKS       CMNAME
      *  CYYMMDD -> MMDDYY
JS99 C     OHODAT        DIV       10000         WCYY              3 0
JS99 C                   MVR                     WMMDD             4 0
JS99 C     WCYY          IFGE      100
JS99 C     WCYY          SUB       100           WYY               2 0
JS99 C                   ELSE
JS99 C                   Z-ADD     WCYY          WYY
JS99 C                   ENDIF
JS99 C     WMMDD         MULT      100           WDATE             6 0
JS99 C                   ADD       WYY           WDATE
      *
     C                   EXCPT     HEADR
     C                   Z-ADD     0             WSUB             11 2
     C     DTLKEY        SETLL     ORDDTLR
     C     DTLKEY        READE     ORDDTLR                                92
     C     *IN92         DOWEQ     *OFF
     C     *INOF         IFEQ      *ON
     C                   EXCPT     HEADR
     C                   SETOFF                                       OF
     C                   ENDIF
     C     ODPRD#        CHAIN     PRDMSTR                            93
     C   93              MOVE      *BLANKS       PMNAME
      *  NET PRICE ROUNDED FIRST, THEN TIMES QUANTITY
     C     1             SUB       ODDISC        WPCT              5 4
     C     ODPRIC        MULT(H)   WPCT          WNET              9 2
     C     WNET          MULT      ODQTY         WEXT             11 2
     C                   ADD       WEXT          WSUB
     C                   EXCPT     DETL
     C     DTLKEY        READE     ORDDTLR                                92
     C                   ENDDO
     C     WSUB          ADD       OHFRT         WTOT             11 2
     C                   EXCPT     TOTL
     C                   SETON                                        LR
      *****************************************************************
     OQSYSPRT   E            HEADR          2  1
     O                       COMPNM              40
     O                                           70 'I N V O I C E'
     O                                           76 'PAGE'
     O                       PAGE          Z     80
     OQSYSPRT   E            HEADR          2
     O                                           10 'ORDER NO'
     O                       OHORD#        Z     19
     O                                           30 'DATE'
     O                       WDATE         Y     40
     O                                           55 'CUSTOMER'
     O                       OHCUST              61
     OQSYSPRT   E            HEADR          1
     O                                           10 'SOLD TO'
     O                       CMNAME              52
     O                                           63 'SHIP TO'
     O                       OHSNAM             104
     OQSYSPRT   E            HEADR          1
     O                       OHSADR             104
     OQSYSPRT   E            HEADR          2
     O                       OHSCTY              79
     O                       OHSPST              90
     O                       OHSCNT             106
     OQSYSPRT   E            HEADR          2
     O                                            4 'LN'
     O                                           11 'ITEM'
     O                                           26 'DESCRIPTION'
     O                                           61 'QTY'
     O                                           74 'PRICE'
     O                                           80 'DISC'
     O                                           96 'AMOUNT'
     OQSYSPRT   E            DETL           1
     O                       ODLIN#        Z      4
     O                       ODPRD#        Z     11
     O                       PMNAME              53
     O                       ODQTY         1     61
     O                       ODPRIC        1     74
     O                       ODDISC        3     80
     O                       WEXT          1     96
     OQSYSPRT   E            TOTL        1  1
     O                                           80 'MERCHANDISE'
     O                       WSUB          1     96
     OQSYSPRT   E            TOTL           1
     O                                           80 'FREIGHT'
     O                       OHFRT         1     96
     OQSYSPRT   E            TOTL           1
     O                                           80 'TOTAL DUE'
     O                       WTOT          1     96
