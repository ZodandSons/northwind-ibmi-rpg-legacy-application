/*********************************************************************/
/* PROGRAM  : NW620C                                                 */
/* TITLE    : PRINT INVOICE - OVERRIDE PRINTER AND CALL NW620R       */
/* AUTHOR   : R. K. MILLER                       DATE: 07/11/89      */
/* PARM     : ORDER NUMBER  *DEC (7 0)                               */
/*********************************************************************/
             PGM        PARM(&ORDER)
             DCL        VAR(&ORDER) TYPE(*DEC) LEN(7 0)

             OVRPRTF    FILE(QSYSPRT) PAGESIZE(66 132) LPI(6) CPI(10) +
                          FORMTYPE(INVOICE) SPLFNAME(NWINVOICE) +
                          HOLD(*YES) SHARE(*NO)
             CALL       PGM(NW620R) PARM(&ORDER)
             MONMSG     MSGID(CPF0000)
             DLTOVR     FILE(QSYSPRT)
             MONMSG     MSGID(CPF0000)
             ENDPGM
