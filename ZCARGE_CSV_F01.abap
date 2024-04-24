MODULE STATUS_0100 OUTPUT.
DATA: LS_LAYOUT  TYPE LVC_S_LAYO,
      LS_VARIANT TYPE DISVARIANT.


SET PF-STATUS 'PRINCIPAL'.
IF CUSTOM_CONTAINER IS INITIAL.
* create a custom container control for our ALV Control
    CREATE OBJECT CUSTOM_CONTAINER
        EXPORTING
            CONTAINER_NAME = CONTROL_CUSTOM1
        EXCEPTIONS
            CNTL_ERROR = 1
            CNTL_SYSTEM_ERROR = 2
            CREATE_ERROR = 3
            LIFETIME_ERROR = 4
            LIFETIME_DYNPRO_DYNPRO_LINK = 5.
    IF SY-SUBRC NE 0.

    ENDIF.
* create an instance of alv control
    CREATE OBJECT GO_ALV_GRID
          EXPORTING I_PARENT = CUSTOM_CONTAINER.
*
* Set a titlebar for the grid control
*
    GS_LAYOUT-GRID_TITLE = 'Registers'(100).

    APPEND INITIAL LINE TO GT_FIELDCAT_POPUP ASSIGNING FIELD-SYMBOL(<FS_FIELDCAT_POPUP>).
    <FS_FIELDCAT_POPUP>-FIELDNAME = 'STATUS'.
    <FS_FIELDCAT_POPUP>-REF_TABLE = 'TL_REGISTERS'.
    <FS_FIELDCAT_POPUP>-TABNAME = 'TL_REGISTERS'.
    <FS_FIELDCAT_POPUP>-SCRTEXT_S = 'Status'.
    <FS_FIELDCAT_POPUP>-SCRTEXT_M = 'Status'.
    <FS_FIELDCAT_POPUP>-SCRTEXT_L = 'Status'.
    <FS_FIELDCAT_POPUP>-OUTPUTLEN = 5.
    <FS_FIELDCAT_POPUP>-JUST = 'C'.
    <FS_FIELDCAT_POPUP>-FIX_COLUMN = ABAP_TRUE.

    APPEND INITIAL LINE TO GT_FIELDCAT_POPUP ASSIGNING <FS_FIELDCAT_POPUP>.
    <FS_FIELDCAT_POPUP>-FIELDNAME = 'ROUTE'.
    <FS_FIELDCAT_POPUP>-REF_TABLE = 'TL_REGISTERS'.
    <FS_FIELDCAT_POPUP>-TABNAME = 'TL_REGISTERS'.
    <FS_FIELDCAT_POPUP>-OUTPUTLEN = 30.
    <FS_FIELDCAT_POPUP>-JUST = 'C'.
    <FS_FIELDCAT_POPUP>-FIX_COLUMN = ABAP_TRUE.

    APPEND INITIAL LINE TO GT_FIELDCAT_POPUP ASSIGNING <FS_FIELDCAT_POPUP>.
    <FS_FIELDCAT_POPUP>-FIELDNAME = 'SDABW'.
    <FS_FIELDCAT_POPUP>-REF_TABLE = 'TL_REGISTERS'.
    <FS_FIELDCAT_POPUP>-TABNAME = 'TL_REGISTERS'.
    <FS_FIELDCAT_POPUP>-OUTPUTLEN = 30.
    <FS_FIELDCAT_POPUP>-JUST = 'C'.
    <FS_FIELDCAT_POPUP>-FIX_COLUMN = ABAP_TRUE.

    APPEND INITIAL LINE TO GT_FIELDCAT_POPUP ASSIGNING <FS_FIELDCAT_POPUP>.
    <FS_FIELDCAT_POPUP>-FIELDNAME = 'KBETR'.
    <FS_FIELDCAT_POPUP>-REF_TABLE = 'TL_REGISTERS'.
    <FS_FIELDCAT_POPUP>-TABNAME = 'TL_REGISTERS'.
    <FS_FIELDCAT_POPUP>-CFIELDNAME = 'KONWA'.
    <FS_FIELDCAT_POPUP>-OUTPUTLEN = 30.
    <FS_FIELDCAT_POPUP>-JUST = 'C'.
    <FS_FIELDCAT_POPUP>-FIX_COLUMN = ABAP_TRUE.

    APPEND INITIAL LINE TO GT_FIELDCAT_POPUP ASSIGNING <FS_FIELDCAT_POPUP>.
    <FS_FIELDCAT_POPUP>-FIELDNAME = 'KONWA'.
    <FS_FIELDCAT_POPUP>-REF_TABLE = 'TL_REGISTERS'.
    <FS_FIELDCAT_POPUP>-TABNAME = 'TL_REGISTERS'.
    <FS_FIELDCAT_POPUP>-OUTPUTLEN = 30.
    <FS_FIELDCAT_POPUP>-JUST = 'C'.
    <FS_FIELDCAT_POPUP>-FIX_COLUMN = ABAP_TRUE.

    APPEND INITIAL LINE TO GT_FIELDCAT_POPUP ASSIGNING <FS_FIELDCAT_POPUP>.
    <FS_FIELDCAT_POPUP>-FIELDNAME = 'DATAB'.
    <FS_FIELDCAT_POPUP>-REF_TABLE = 'TL_REGISTERS'.
    <FS_FIELDCAT_POPUP>-TABNAME = 'TL_REGISTERS'.
    <FS_FIELDCAT_POPUP>-OUTPUTLEN = 30.
    <FS_FIELDCAT_POPUP>-JUST = 'C'.
    <FS_FIELDCAT_POPUP>-DATATYPE = 'DATS'.
    <FS_FIELDCAT_POPUP>-FIX_COLUMN = ABAP_TRUE.

    APPEND INITIAL LINE TO GT_FIELDCAT_POPUP ASSIGNING <FS_FIELDCAT_POPUP>.
    <FS_FIELDCAT_POPUP>-FIELDNAME = 'DATBI'.
    <FS_FIELDCAT_POPUP>-REF_TABLE = 'TL_REGISTERS'.
    <FS_FIELDCAT_POPUP>-TABNAME = 'TL_REGISTERS'.
    <FS_FIELDCAT_POPUP>-OUTPUTLEN = 30.
    <FS_FIELDCAT_POPUP>-JUST = 'C'.
    <FS_FIELDCAT_POPUP>-DATATYPE = 'DATS'.
    <FS_FIELDCAT_POPUP>-FIX_COLUMN = ABAP_TRUE.

    CALL METHOD GO_ALV_GRID->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        I_SAVE                        = 'A'
      CHANGING
        IT_OUTTAB                     = GT_REGISTERS
        IT_FIELDCATALOG               = GT_FIELDCAT_POPUP
      EXCEPTIONS
        INVALID_PARAMETER_COMBINATION = 1
        PROGRAM_ERROR                 = 2
        TOO_MANY_LINES                = 3
        OTHERS                        = 4.
    IF SY-SUBRC <> 0.
*   Implement suitable error handling here
    ELSE.

    ENDIF.
ELSE.
    CALL METHOD GO_ALV_GRID->REFRESH_TABLE_DISPLAY.
ENDIF.

ENDMODULE.

MODULE USER_COMMAND_0100 INPUT.
CASE SY-UCOMM.
  WHEN '&CLOSE'.
     LEAVE TO SCREEN 0.
  WHEN '&RETURN'.
     LEAVE TO SCREEN 0.
  WHEN '&EXIT'.
     LEAVE TO SCREEN 0.
  WHEN '&PROCESS'.
     PERFORM PROCESS_CSV USING GT_REGISTERS.
ENDCASE.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Form  READ_CSV_FILE
*&---------------------------------------------------------------------*
FORM READ_CSV_FILE.

  DATA: LV_FILENAME TYPE RLGRAP-FILENAME,
        VL_KBETR TYPE STRING.

  LV_FILENAME = P_FILE.

  CALL FUNCTION 'WS_UPLOAD'
    EXPORTING
      FILENAME          = LV_FILENAME
      FILETYPE          = 'ASC'
    TABLES
      DATA_TAB          = LT_FIELDS
    EXCEPTIONS
      CONVERSION_ERROR  = 1
      OTHERS            = 2.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    RETURN.
  ENDIF.

LOOP AT LT_FIELDS INTO LV_LINE.
    CHECK SY-TABIX > 1.
    REPLACE ALL OCCURRENCES OF REGEX CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB IN LV_LINE WITH ''.
    REPLACE ALL OCCURRENCES OF REGEX '"' IN LV_LINE WITH ''.

    APPEND INITIAL LINE TO GT_REGISTERS ASSIGNING FIELD-SYMBOL(<FS_REGISTERS>).

    SPLIT LV_LINE AT LV_SEPARATOR INTO <FS_REGISTERS>-ROUTE
         <FS_REGISTERS>-SDABW
         <FS_REGISTERS>-KBETR_TXT
         <FS_REGISTERS>-KONWA
         <FS_REGISTERS>-DATAB
         <FS_REGISTERS>-DATBI.


    CONDENSE <FS_REGISTERS>-KBETR_TXT.
    MOVE <FS_REGISTERS>-KBETR_TXT TO <FS_REGISTERS>-KBETR.


    CLEAR: VL_KBETR.
ENDLOOP.

ENDFORM.                    " READ_CSV_FILE


FORM PROGRESS_BAR USING P_VALUE
                        P_TABIX
                        P_NLINES.

  DATA: W_TEXT(40),
        W_PERCENTAGE      TYPE P,
        W_PERCENT_CHAR(3).

  IF P_NLINES NE 0.
      W_PERCENTAGE = ( P_TABIX / P_NLINES ) * 100.
      W_PERCENT_CHAR = W_PERCENTAGE.
      SHIFT W_PERCENT_CHAR LEFT DELETING LEADING ' '.
      CONCATENATE P_VALUE ' (' W_PERCENT_CHAR '%) ' INTO W_TEXT RESPECTING BLANKS.

      IF W_PERCENTAGE GT VG_PERCENT OR P_TABIX EQ 1.
        CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
          EXPORTING
            PERCENTAGE = W_PERCENTAGE
            TEXT       = W_TEXT.
        VG_PERCENT = W_PERCENTAGE.
      ENDIF.

      CALL FUNCTION 'TH_REDISPATCH'
        EXPORTING
          CHECK_RUNTIME = 0.
  ENDIF.
ENDFORM.

FORM PROCESS_CSV USING P_REGISTERS TYPE TT_REGISTERS.
DATA: VL_INDEX TYPE I,
      VL_LINES TYPE I.

DESCRIBE TABLE P_REGISTROS LINES VL_LINES.

LOOP AT P_REGISTERS ASSIGNING FIELD-SYMBOL(<FS_REGISTERS>) WHERE STATUS NE '@0A@'.
    VL_INDEX = SY-TABIX.

    PERFORM PROGRESS_BAR USING TEXT-P01 VL_INDEX VL_LINES.
    
    MOVE <FS_REGISTERS>-ROUTE TO VL_ROUTE.
    MOVE <FS_REGISTERS>-SDABW TO VL_SDABW.

    MOVE <FS_REGISTERS>-KONWA TO VL_KONWA.

    CONCATENATE <FS_REGISTERS>-DATAB+6(2) <FS_REGISTERS>-DATAB+4(2) <FS_REGISTERS>-DATAB+0(4) INTO VL_DATAB.
    CONCATENATE <FS_REGISTERS>-DATBI+6(2) <FS_REGISTERS>-DATBI+4(2) <FS_REGISTERS>-DATBI+0(4) INTO VL_DATBI.

    PERFORM OPEN_GROUP.

    PERFORM BDC_DYNPRO      USING 'SAPMV13A' '0100'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RV13A-KSCHL'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'RV13A-KSCHL'
                                  'ZZZZ'.
    PERFORM BDC_DYNPRO      USING 'SAPMV13A' '1906'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'KOMG-ROUTE'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'KOMG-ROUTE'
                                  VL_ROUTE.
    PERFORM BDC_DYNPRO      USING 'SAPMV13A' '1906'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RV13A-DATAB(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'KOMG-ROUTE'
                                  VL_ROUTE.
    PERFORM BDC_FIELD       USING 'KOMG-SDABW(01)'
                                  VL_SDABW.
    PERFORM BDC_FIELD       USING 'KONP-KBETR(01)'
                                  <FS_REGISTERS>-KBETR_TXT.
    PERFORM BDC_FIELD       USING 'KONP-KONWA(01)'
                                  VL_KONWA.
    PERFORM BDC_FIELD       USING 'RV13A-DATAB(01)'
                                  VL_DATAB.
    PERFORM BDC_FIELD       USING 'RV13A-DATBI(01)'
                                  VL_DATBI.
    PERFORM BDC_DYNPRO      USING 'SAPMV13A' '1906'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'KOMG-SDABW(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=SICH'.
    PERFORM BDC_TRANSACTION USING 'TK11'.

    PERFORM CLOSE_GROUP.

    <FS_REGISTERS>-STATUS = '@08@'.
ENDLOOP.
ENDFORM.


FORM PRINCIPAL.

IF P_FILE IS INITIAL.
  MESSAGE TEXT-T03 TYPE 'S' DISPLAY LIKE 'E'.
  RETURN.
ENDIF.

LV_FILENAME = P_FILE.

PERFORM READ_CSV_FILE."Read CSV File

SELECT A906~ROUTE,A906~SDABW, A906~DATBI, A906~DATAB,KONP~KNUMH, KONP~KAPPL, KONP~KSCHL, KONP~KBETR, KONP~KONWA, KONP~LOEVM_KO FROM KONP
    INNER JOIN A906 ON A906~KNUMH = KONP~KNUMH
    INTO CORRESPONDING FIELDS OF TABLE @TL_REGISTERS
    FOR ALL ENTRIES IN @GT_REGISTERS
    WHERE A906~ROUTE = @GT_REGISTERS-ROUTE."Get conditions

IF SY-SUBRC EQ 0.
ENDIF.

LOOP AT TL_REGISTERS ASSIGNING FIELD-SYMBOL(<FS_CONDICIONES>)."Make a hash
         CLEAR <FS_CONDICIONES>-CHECKSUM.

         MOVE <FS_CONDICIONES>-KBETR TO VL_KBETR.
         CONDENSE VL_KBETR.

         CONCATENATE <FS_CONDICIONES>-ROUTE
                     <FS_CONDICIONES>-SDABW
                     VL_KBETR
                     <FS_CONDICIONES>-KONWA
                     <FS_CONDICIONES>-DATAB
                     <FS_CONDICIONES>-DATBI
                     <FS_CONDICIONES>-TDLNR
          INTO <FS_CONDICIONES>-CHECKSUM.

         CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
           EXPORTING
             TEXT           = <FS_CONDICIONES>-CHECKSUM
*            MIMETYPE       = ' '
*            ENCODING       =
          IMPORTING
            BUFFER         = VG_VALUE
          EXCEPTIONS
            FAILED         = 1
            OTHERS         = 2.
         IF SY-SUBRC <> 0.
* Implement suitable error handling here
         ENDIF.


         MOVE <FS_CONDICIONES>-CHECKSUM TO VG_VALUE.

         TRY.
          CL_ABAP_HMAC=>CALCULATE_HMAC_FOR_RAW(
                       EXPORTING IF_ALGORITHM = 'SHA256'
                                 IF_KEY = '0'
                                 IF_DATA = VG_VALUE
                       IMPORTING EF_HMACXSTRING = VG_VALUE ).
         CATCH CX_ROOT.
         ENDTRY.

      MOVE VG_VALUE TO <FS_CONDICIONES>-CHECKSUM.
ENDLOOP.

LOOP AT GT_REGISTERS ASSIGNING FIELD-SYMBOL(<FS_REGISTERS>). "Make a hash

     <FS_REGISTERS>-KBETR = <FS_REGISTERS>-KBETR / 100.
     MOVE <FS_REGISTERS>-KBETR TO VL_KBETR.
     CONDENSE VL_KBETR.

     CONCATENATE <FS_REGISTERS>-ROUTE
                 <FS_REGISTERS>-SDABW
                 VL_KBETR
                 <FS_REGISTERS>-KONWA
                 <FS_REGISTERS>-DATAB
                 <FS_REGISTERS>-DATBI
           INTO <FS_REGISTERS>-CHECKSUM.

      CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
           EXPORTING
             TEXT           = <FS_REGISTERS>-CHECKSUM
*            MIMETYPE       = ' '
*            ENCODING       =
          IMPORTING
            BUFFER         = VG_VALUE
          EXCEPTIONS
            FAILED         = 1
            OTHERS         = 2.
         IF SY-SUBRC <> 0.
* Implement suitable error handling here
         ENDIF.


      TRY.
          CL_ABAP_HMAC=>CALCULATE_HMAC_FOR_RAW(
                        EXPORTING IF_ALGORITHM = 'SHA256'
                                  IF_KEY = '0'
                                  IF_DATA = VG_VALUE
                        IMPORTING EF_HMACXSTRING = VG_VALUE ).
          CATCH CX_ROOT.
          ENDTRY.

       READ TABLE TL_REGISTERS ASSIGNING <FS_CONDICIONES> WITH KEY CHECKSUM = VG_VALUE.
       IF SY-SUBRC EQ 0.
          <FS_REGISTERS>-EXISTE = ABAP_TRUE.
          <FS_REGISTERS>-STATUS = '@09@'."Cuando existe se marca con una alerta
       ENDIF.
   ENDLOOP.

LOOP AT GT_REGISTERS ASSIGNING <FS_REGISTERS>.
    CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY' "Check date format
      EXPORTING
        DATE                            = <FS_REGISTERS>-DATAB
     EXCEPTIONS
       PLAUSIBILITY_CHECK_FAILED       = 1
       OTHERS                          = 2.
    IF SY-SUBRC <> 0.
       MESSAGE TEXT-T01 TYPE 'S' DISPLAY LIKE 'E'.
       <FS_REGISTERS>-STATUS = '@0A@'.
    ENDIF.

    CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY' "Check date format
      EXPORTING
        DATE                            = <FS_REGISTERS>-DATBI
     EXCEPTIONS
       PLAUSIBILITY_CHECK_FAILED       = 1
       OTHERS                          = 2.
    IF SY-SUBRC <> 0.
       MESSAGE TEXT-T02 TYPE 'S' DISPLAY LIKE 'E'.
       <FS_REGISTERS>-STATUS = '@0A@'.
    ENDIF.
ENDLOOP.

IF GT_REGISTERS[] IS INITIAL.
   RETURN. "If i got no registers i return
ENDIF.

CALL SCREEN 0100."Spash the screen

ENDFORM.

FORM DOWNLOAD_CSV .

DATA: LT_DATA TYPE TABLE OF STRING,
      LV_STRING TYPE STRING,
      LV_FILENAME TYPE STRING,
      LV_FULLPATH TYPE STRING,
      LV_PATH TYPE STRING,
      LV_ACTION TYPE I,
      LV_FILE TYPE STRING.

CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
EXPORTING
  WINDOW_TITLE = 'Please select the location'
  DEFAULT_EXTENSION = 'CSV'
  DEFAULT_FILE_NAME = LV_FILE
  FILE_FILTER = '*.CSV'
CHANGING
  FILENAME = LV_FILENAME
  PATH = LV_PATH
  FULLPATH = LV_FULLPATH
  USER_ACTION = LV_ACTION
EXCEPTIONS
  CNTL_ERROR = 1
  ERROR_NO_GUI = 2
OTHERS = 3.

IF SY-SUBRC NE 0.
   RETURN.
ENDIF.

APPEND INITIAL LINE TO LT_DATA ASSIGNING FIELD-SYMBOL(<FS_DATA>).
<FS_DATA> = 'ROUTE;  SDABW;  KBETR;  KONWA;  DATAB;  DATBI'.
APPEND INITIAL LINE TO LT_DATA ASSIGNING <FS_DATA>.
<FS_DATA> = '000001;   2;  600;  CLP;  20240301; 99991231'.


CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      FILENAME = LV_FILENAME
      FILETYPE = 'ASC'
    TABLES
      DATA_TAB = LT_DATA
    EXCEPTIONS
      FILE_WRITE_ERROR = 1
      NO_BATCH = 2
      GUI_REFUSE_FILETRANSFER = 3
      INVALID_TYPE = 4
      NO_AUTHORITY = 5
      UNKNOWN_ERROR = 6
      HEADER_NOT_ALLOWED = 7
      SEPARATOR_NOT_ALLOWED = 8
      FILESIZE_NOT_ALLOWED = 9
      HEADER_TOO_LONG = 10
      DP_ERROR_CREATE = 11
      DP_ERROR_SEND = 12
      DP_ERROR_WRITE = 13
      UNKNOWN_DP_ERROR = 14
      ACCESS_DENIED = 15
      DP_OUT_OF_MEMORY = 16
      DISK_FULL = 17
      DP_TIMEOUT = 18
      FILE_NOT_FOUND = 19
      DATAPROVIDER_EXCEPTION = 20
      CONTROL_FLUSH_ERROR = 21
      OTHERS = 22.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.