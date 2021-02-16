*&---------------------------------------------------------------------*
*& Report zabap_spatial_nearest
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_spatial_nearest.

CLASS app DEFINITION CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS main.

ENDCLASS.

NEW app( )->main( ).

CLASS app IMPLEMENTATION.

  METHOD main.

    "enter geocoordinates in or around Cologne, Germany
    DATA lat TYPE geolat VALUE '50.961558'.
    DATA lon TYPE geolon VALUE '6.931160'.

    zcl_abap_spatial_amdp=>get_nearest(
      EXPORTING
        i_latitude  = lat
        i_longitude = lon
      IMPORTING
        e_nearest = DATA(nearest)
    ).

    DATA(geojson) = NEW zcl_geojson( ).

    DATA(point) = geojson->get_new_point(
                    i_latitude  = CONV #( lat )
                    i_longitude = CONV #( lon )
                  ).

    point->set_properties(
        i_popup_content = 'You are here'
        i_fill_color    = '#0000ff'
    ).

    geojson->add_feature( point ).

    LOOP AT nearest REFERENCE INTO DATA(near).

      point = geojson->get_new_point( ).
      point->set_geometry_from_json( CONV #( near->geojson ) ).
      point->set_properties( i_popup_content = |Distance { near->distance } km| ).

      geojson->add_feature( point ).

    ENDLOOP.

    DATA(json_string) = geojson->get_json( ).

    cl_demo_output=>display_html(
      NEW zcl_geojson_leafletjs( )->get_html(
           i_json = json_string
           i_width_x_in_px = 900
           i_use_circle_markers = abap_true         "use circle markers
       )
    ).

  ENDMETHOD.

ENDCLASS.
