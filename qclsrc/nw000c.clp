/*********************************************************************/
/* PROGRAM  : NW000C                                                 */
/* TITLE    : NORTHWIND MAIN MENU                                    */
/* AUTHOR   : R. K. MILLER                       DATE: 03/14/88      */
/*                                                                   */
/* MODIFICATION LOG                                                  */
/* 07/15/98 RKM  OPTIONS 5-9 USE CODE TABLE PROGRAM NW500R           */
/* 08/02/04 TPK  GLOBAL MONMSG ADDED - USERS KEPT GETTING DUMPED     */
/*                                                                   */
/* LIBRARIES ARE HARD CODED - SEE ALSO NW700C                        */
/*********************************************************************/
             PGM
             DCLF       FILE(NW000D)
             MONMSG     MSGID(CPF0000 RNX0000 CEE0000) EXEC(GOTO +
                          CMDLBL(ERROR))

             ADDLIBLE   LIB(NWLEGDTA)
             MONMSG     MSGID(CPF0000)
             ADDLIBLE   LIB(NWLEGPGM)
             MONMSG     MSGID(CPF0000)
             CHGVAR     VAR(&MSG) VALUE(' ')

 LOOP:       SNDRCVF    RCDFMT(MENU)
             IF         COND(&IN03 *EQ '1') THEN(GOTO CMDLBL(END))
             CHGVAR     VAR(&MSG) VALUE(' ')

             IF         COND(&OPTION *EQ 1) THEN(CALL PGM(NW100R))
             IF         COND(&OPTION *EQ 2) THEN(CALL PGM(NW200R))
             IF         COND(&OPTION *EQ 3) THEN(CALL PGM(NW300R))
             IF         COND(&OPTION *EQ 4) THEN(CALL PGM(NW400R))
             IF         COND(&OPTION *EQ 5) THEN(CALL PGM(NW500R) +
                          PARM('REG'))
             IF         COND(&OPTION *EQ 6) THEN(CALL PGM(NW500R) +
                          PARM('SHP'))
             IF         COND(&OPTION *EQ 7) THEN(CALL PGM(NW500R) +
                          PARM('CAT'))
             IF         COND(&OPTION *EQ 8) THEN(CALL PGM(NW500R) +
                          PARM('TER'))
             IF         COND(&OPTION *EQ 9) THEN(CALL PGM(NW500R) +
                          PARM('DEM'))
             IF         COND(&OPTION *EQ 10) THEN(CALL PGM(NW600R))
             IF         COND(&OPTION *EQ 11) THEN(CALL PGM(NW610R))
             IF         COND(&OPTION *EQ 12) THEN(CALL PGM(NW700C))
             IF         COND(&OPTION *EQ 90) THEN(SIGNOFF)
             IF         COND(&OPTION *GT 12 *AND &OPTION *NE 90) +
                          THEN(CHGVAR VAR(&MSG) VALUE('INVALID OPTION'))

             CHGVAR     VAR(&OPTION) VALUE(0)
             GOTO       CMDLBL(LOOP)

 ERROR:      CHGVAR     VAR(&MSG) VALUE('AN ERROR OCCURRED - CALL +
                          I.S. ON X4357')
             CHGVAR     VAR(&OPTION) VALUE(0)
             GOTO       CMDLBL(LOOP)

 END:        RETURN
             ENDPGM
