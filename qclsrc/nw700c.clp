/*********************************************************************/
/* PROGRAM  : NW700C                                                 */
/* TITLE    : SUBMIT CUSTOMER LIST BY COUNTRY TO BATCH               */
/* AUTHOR   : R. K. MILLER                       DATE: 11/02/88      */
/*********************************************************************/
             PGM
             SBMJOB     CMD(CALL PGM(NWLEGPGM/NW700R)) JOB(NW700R) +
                          JOBQ(QBATCH) INLLIBL(*CURRENT)
             MONMSG     MSGID(CPF0000)
             SNDPGMMSG  MSG('Customer list submitted to batch') +
                          MSGTYPE(*INFO)
             ENDPGM
