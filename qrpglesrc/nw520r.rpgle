      *****************************************************************
      *  PROGRAM  : NW520R
      *  TITLE    : CUSTOMER DEMOGRAPHIC TYPES
      *  AUTHOR   : M. HERNANDEZ                     DATE: 02/02/11
      *
      *  PARAMETER: CUSTOMER NUMBER (5 CHAR) - CALLED FROM NW100R
      *
      *  MODIFICATION LOG
      *  02/02/11 MH          NEW - COPY OF NW510R
      *****************************************************************
     HDATEDIT(*MDY)
     FNW520D    CF   E             WORKSTN SFILE(SFLREC:RRN)
     FCUSDEM    UF A E           K DISK
     FCUSMST    IF   E           K DISK
     FCODTBL    IF   E           K DISK
      *
     DMSG              S             50    DIM(6) CTDATA PERRCD(1)
      *****************************************************************
     C     *ENTRY        PLIST
     C                   PARM                    PCUST             5
      *
     C     LNKKEY        KLIST
     C                   KFLD                    PCUST
     C     LNKKY2        KLIST
     C                   KFLD                    PCUST
     C                   KFLD                    WCODE
     C     CTKEY         KLIST
     C                   KFLD                    WTYPE
     C                   KFLD                    WCODE
     C     *LIKE         DEFINE    CTCODE        WCODE
     C     *LIKE         DEFINE    CTTYPE        WTYPE
      *
     C                   MOVEL     PCUST         H1KEY
     C     PCUST         CHAIN     CUSMSTR                            92
     C     *IN92         IFEQ      *ON
     C                   MOVEL     MSG(1)        H1NAME
     C                   ELSE
     C                   MOVEL     CMNAME        H1NAME
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
     C                   MOVE      'DEM'         WTYPE
     C     LNKKEY        SETLL     CUSDEMR
     C     LNKKEY        READE     CUSDEMR                                90
     C     *IN90         DOWEQ     *OFF
     C                   ADD       1             RRN
     C                   MOVE      *BLANK        S1OPT
     C                   MOVEL     CDTYPE        S1CODE
     C                   MOVE      *BLANKS       WCODE
     C                   MOVEL     CDTYPE        WCODE
     C     CTKEY         CHAIN     CODTBLR                            93
     C     *IN93         IFEQ      *ON
     C                   MOVEL     '*NOT ON FILE'S1DESC
     C                   ELSE
     C                   MOVEL     CTDESC        S1DESC
     C                   ENDIF
     C                   WRITE     SFLREC
     C     LNKKEY        READE     CUSDEMR                                90
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
     C     LNKKY2        CHAIN     CUSDEMR                            92
     C  N92              DELETE    CUSDEMR
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
     C                   MOVE      'DEM'         WTYPE
     C                   MOVE      *BLANKS       WCODE
     C                   MOVEL     A1CODE        WCODE
     C     CTKEY         CHAIN     CODTBLR                            93
     C     *IN93         IFEQ      *ON
     C                   SETON                                        51
     C                   GOTO      ADD1
     C                   ENDIF
     C     LNKKY2        CHAIN     CUSDEMR                            92
     C     *IN92         IFEQ      *OFF
     C                   SETON                                        52
     C                   GOTO      ADD1
     C                   ENDIF
     C                   MOVEL     PCUST         CDCUST
     C                   MOVEL     WCODE         CDTYPE
     C                   WRITE     CUSDEMR
     C                   MOVEL     MSG(4)        MSGLIN
     C     ADDX          TAG
     C                   ENDSR
**CTDATA MSG
Employee not on file
No territories assigned
Type removed
Type added
Unused message
Unused message
