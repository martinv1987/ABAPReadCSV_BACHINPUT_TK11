***INCLUDE BDCRECX1_S.
*  for programs doing a data transfer by creating a batch-input session
*  and
*  for programs doing a data transfer by CALL TRANSACTION USING
*  secured version WITH AUTHORITY-CHECK.

SELECTION-SCREEN BEGIN OF LINE.
  PARAMETERS SESSION RADIOBUTTON GROUP CTU.  "create session
  SELECTION-SCREEN COMMENT 3(20) TEXT-S07 FOR FIELD SESSION.
  selection-screen position 45.
  PARAMETERS CTU RADIOBUTTON GROUP  CTU.     "call transaction
  SELECTION-SCREEN COMMENT 48(20) TEXT-S08 FOR FIELD CTU.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
  SELECTION-SCREEN COMMENT 3(20) TEXT-S01 FOR FIELD GROUP.
  selection-screen position 25.
  PARAMETERS GROUP(12).                      "group name of session
  SELECTION-SCREEN COMMENT 48(20) TEXT-S05 FOR FIELD CTUMODE.
  selection-screen position 70.
  PARAMETERS CTUMODE LIKE CTU_PARAMS-DISMODE DEFAULT 'N'.
                                      "A: show all dynpros
                                      "E: show dynpro on error only
                                      "N: do not display dynpro
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
  SELECTION-SCREEN COMMENT 3(20) TEXT-S02 FOR FIELD USER.
  selection-screen position 25.
  PARAMETERS: USER(12) DEFAULT SY-UNAME.     "user for session in batch
  SELECTION-SCREEN COMMENT 48(20) TEXT-S06 FOR FIELD CUPDATE.
  selection-screen position 70.
  PARAMETERS CUPDATE LIKE CTU_PARAMS-UPDMODE DEFAULT 'L'.
                                      "S: synchronously
                                      "A: asynchronously
                                      "L: local
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
  SELECTION-SCREEN COMMENT 3(20) TEXT-S03 FOR FIELD KEEP.
  selection-screen position 25.
  PARAMETERS: KEEP AS CHECKBOX.       "' ' = delete session if finished
                                      "'X' = keep   session if finished
  SELECTION-SCREEN COMMENT 48(20) TEXT-S09 FOR FIELD E_GROUP.
  selection-screen position 70.
  parameters E_GROUP(12).             "group name of error-session
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
  SELECTION-SCREEN COMMENT 3(20) TEXT-S04 FOR FIELD HOLDDATE.
  selection-screen position 25.
  PARAMETERS: HOLDDATE LIKE SY-DATUM.
  SELECTION-SCREEN COMMENT 51(17) TEXT-S02 FOR FIELD E_USER.
  selection-screen position 70.
  PARAMETERS: E_USER(12) DEFAULT SY-UNAME.    "user for error-session
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
  SELECTION-SCREEN COMMENT 51(17) TEXT-S03 FOR FIELD E_KEEP.
  selection-screen position 70.
  PARAMETERS: E_KEEP AS CHECKBOX.     "' ' = delete session if finished
                                      "'X' = keep   session if finished
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
  SELECTION-SCREEN COMMENT 51(17) TEXT-S04 FOR FIELD E_HDATE.
  selection-screen position 70.
  PARAMETERS: E_HDATE LIKE SY-DATUM.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF LINE.
  SELECTION-SCREEN COMMENT 1(33) TEXT-S10 FOR FIELD NODATA.
  PARAMETERS: NODATA DEFAULT '/' LOWER CASE.          "nodata
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
  SELECTION-SCREEN COMMENT 1(33) TEXT-S11 FOR FIELD SMALLLOG.
  PARAMETERS: SMALLLOG as checkbox.  "' ' = log all transactions
                                     "'X' = no transaction logging
SELECTION-SCREEN END OF LINE.

*----------------------------------------------------------------------*
*   data definition
*----------------------------------------------------------------------*
*       Batchinputdata of single transaction
DATA:   BDCDATA LIKE BDCDATA    OCCURS 0 WITH HEADER LINE.
*       messages of call transaction
DATA:   MESSTAB LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.
*       error session opened (' ' or 'X')
DATA:   E_GROUP_OPENED.
*       message texts
TABLES: T100.


*----------------------------------------------------------------------*
*   at selection screen                                                *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
* group and user must be filled for create session
  IF SESSION = 'X' AND
     GROUP = SPACE OR USER = SPACE.
    MESSAGE E613(MS).
  ENDIF.

IF SY-UCOMM = 'FC01'." The only change
   PERFORM DOWNLOAD_CSV.
ENDIF.

*----------------------------------------------------------------------*
*   open dataset                                                       *
*----------------------------------------------------------------------*
FORM OPEN_DATASET USING P_DATASET.
  OPEN DATASET P_DATASET
               FOR INPUT IN TEXT MODE
               ENCODING DEFAULT.
  IF SY-SUBRC <> 0.
    WRITE: / TEXT-E00, SY-SUBRC.
    STOP.
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------*
*   close dataset                                                      *
*----------------------------------------------------------------------*
FORM CLOSE_DATASET USING P_DATASET.
  CLOSE DATASET P_DATASET.
ENDFORM.

*----------------------------------------------------------------------*
*   create batchinput session                                          *
*   (not for call transaction using...)                                *
*----------------------------------------------------------------------*
FORM OPEN_GROUP.
  IF SESSION = 'X'.
    SKIP.
    WRITE: /(20) 'Create group'(I01), GROUP.
    SKIP.
*   open batchinput group
    CALL FUNCTION 'BDC_OPEN_GROUP'
         EXPORTING  CLIENT   = SY-MANDT
                    GROUP    = GROUP
                    USER     = USER
                    KEEP     = KEEP
                    HOLDDATE = HOLDDATE.
    WRITE: /(30) 'BDC_OPEN_GROUP'(I02),
            (12) 'returncode:'(I05),
                 SY-SUBRC.
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------*
*   end batchinput session                                             *
*   (call transaction using...: error session)                         *
*----------------------------------------------------------------------*
FORM CLOSE_GROUP.
  IF SESSION = 'X'.
*   close batchinput group
    CALL FUNCTION 'BDC_CLOSE_GROUP'.
    WRITE: /(30) 'BDC_CLOSE_GROUP'(I04),
            (12) 'returncode:'(I05),
                 SY-SUBRC.
  ELSE.
    IF E_GROUP_OPENED = 'X'.
      CALL FUNCTION 'BDC_CLOSE_GROUP'.
      WRITE: /.
      WRITE: /(30) 'Fehlermappe wurde erzeugt'(I06).
      E_GROUP_OPENED = ' '.
    ENDIF.
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------*
*        Start new transaction according to parameters                 *
*----------------------------------------------------------------------*
FORM BDC_TRANSACTION USING TCODE.
  DATA: L_MSTRING(480).
  DATA: L_SUBRC LIKE SY-SUBRC.
  DATA: lx_auth_check TYPE REF TO cx_root.
  DATA: l_auth_check_text TYPE string.
* batch input session
  IF SESSION = 'X'.
    CALL FUNCTION 'BDC_INSERT'
         EXPORTING TCODE     = TCODE
         TABLES    DYNPROTAB = BDCDATA.
    IF SMALLLOG <> 'X'.
      WRITE: / 'BDC_INSERT'(I03),
               TCODE,
               'returncode:'(I05),
               SY-SUBRC,
               'RECORD:',
               SY-INDEX.
    ENDIF.
* call transaction using
  ELSE.
    REFRESH MESSTAB.
    TRY.
      CALL TRANSACTION TCODE WITH AUTHORITY-CHECK USING BDCDATA
                       MODE   CTUMODE
                       UPDATE CUPDATE
                       MESSAGES INTO MESSTAB.
    CATCH cx_sy_authorization_error INTO lx_auth_check.
*     Authorization missing for user when executing transaction
      l_auth_check_text = lx_auth_check->get_text( ).
      SY-SUBRC = 99.
    ENDTRY.
    L_SUBRC = SY-SUBRC.
    IF SMALLLOG <> 'X'.
      WRITE: / 'CALL_TRANSACTION',
               TCODE,
               'returncode:'(I05),
               L_SUBRC,
               'RECORD:',
               SY-INDEX.
      IF L_SUBRC <> 99.
        LOOP AT MESSTAB.
          MESSAGE ID     MESSTAB-MSGID
                  TYPE   MESSTAB-MSGTYP
                  NUMBER MESSTAB-MSGNR
                  INTO L_MSTRING
                  WITH MESSTAB-MSGV1
                       MESSTAB-MSGV2
                       MESSTAB-MSGV3
                       MESSTAB-MSGV4.
          WRITE: / MESSTAB-MSGTYP, L_MSTRING(250).
        ENDLOOP.
      ELSE.
        WRITE: / l_auth_check_text.
      ENDIF.
      SKIP.
    ENDIF.
** Erzeugen fehlermappe ************************************************
    IF L_SUBRC <> 0 AND L_SUBRC <> 99 AND E_GROUP <> SPACE.
      IF E_GROUP_OPENED = ' '.
        CALL FUNCTION 'BDC_OPEN_GROUP'
             EXPORTING  CLIENT   = SY-MANDT
                        GROUP    = E_GROUP
                        USER     = E_USER
                        KEEP     = E_KEEP
                        HOLDDATE = E_HDATE.
         E_GROUP_OPENED = 'X'.
      ENDIF.
      CALL FUNCTION 'BDC_INSERT'
           EXPORTING TCODE     = TCODE
           TABLES    DYNPROTAB = BDCDATA.
    ENDIF.
  ENDIF.
  REFRESH BDCDATA.
ENDFORM.

*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  CLEAR BDCDATA.
  BDCDATA-PROGRAM  = PROGRAM.
  BDCDATA-DYNPRO   = DYNPRO.
  BDCDATA-DYNBEGIN = 'X'.
  APPEND BDCDATA.
ENDFORM.

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
  IF FVAL <> NODATA.
    CLEAR BDCDATA.
    BDCDATA-FNAM = FNAM.
    BDCDATA-FVAL = FVAL.
    APPEND BDCDATA.
  ENDIF.
ENDFORM.