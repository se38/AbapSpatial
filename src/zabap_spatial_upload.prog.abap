*&---------------------------------------------------------------------*
*& Report zabap_spatial_upload
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_spatial_upload.

CLASS app DEFINITION CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS main.

ENDCLASS.

NEW app( )->main( ).

CLASS app IMPLEMENTATION.

  METHOD main.

"start via <F8> ! (GUI!)
    DATA lines TYPE string_table.

    cl_gui_frontend_services=>gui_upload(
      EXPORTING
        filename                = 'D:\data\c\chargingpoints.csv'
      CHANGING
        data_tab                = lines
      EXCEPTIONS
        OTHERS                  = 8
    ).

    IF sy-subrc <> 0.
      cl_demo_output=>display( 'Upload error' ).
      RETURN.
    ENDIF.

    DELETE lines INDEX 1.

    DATA point TYPE zchargingpoints.

    TRY.
        LOOP AT lines REFERENCE INTO DATA(line).

          point-guid = cl_system_uuid=>create_uuid_x16_static( ).

          DATA lat TYPE c LENGTH 20.
          DATA lon TYPE c LENGTH 20.

          SPLIT line->* AT ';' INTO point-street point-house_num point-post_code point-city lat lon.
          REPLACE ',' IN lat WITH '.'.
          REPLACE ',' IN lon WITH '.'.
          point-latitude = lat.
          point-longitude = lon.

          zcl_abap_spatial_amdp=>insert_geo_location(
            i_mandt     = sy-mandt
            i_guid      = point-guid
            i_street    = point-street
            i_house_num = point-house_num
            i_post_code = point-post_code
            i_city      = point-city
            i_latitude  = point-latitude
            i_longitude = point-longitude
          ).

        ENDLOOP.

      CATCH  cx_uuid_error
             cx_amdp_execution_failed INTO DATA(lcx).
        cl_demo_output=>display( lcx->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
