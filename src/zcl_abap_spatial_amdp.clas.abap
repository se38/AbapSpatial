CLASS zcl_abap_spatial_amdp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_amdp_marker_hdb .

    TYPES ty_long_char TYPE c LENGTH 5000.

    TYPES: BEGIN OF ty_nearest,
             geojson  TYPE ty_long_char,
             distance TYPE p LENGTH 13 DECIMALS 5,
           END OF ty_nearest.

    TYPES: tt_nearest TYPE STANDARD TABLE OF ty_nearest WITH EMPTY KEY.

    CLASS-METHODS insert_geo_location
      IMPORTING VALUE(i_mandt)     TYPE mandt
                VALUE(i_guid)      TYPE guid_16
                VALUE(i_street)    TYPE ad_street
                VALUE(i_house_num) TYPE ad_hsnm1
                VALUE(i_post_code) TYPE ad_pstcd1
                VALUE(i_city)      TYPE ad_city1
                VALUE(i_latitude)  TYPE geolat
                VALUE(i_longitude) TYPE geolon
      RAISING   cx_amdp_execution_failed .

    CLASS-METHODS get_nearest
      IMPORTING VALUE(i_latitude)  TYPE geolat
                VALUE(i_longitude) TYPE geolon
      EXPORTING VALUE(e_nearest)   TYPE tt_nearest.
ENDCLASS.

CLASS zcl_abap_spatial_amdp IMPLEMENTATION.

  METHOD insert_geo_location
    BY DATABASE PROCEDURE FOR HDB
    LANGUAGE SQLSCRIPT
    USING zchargingpoints.

    INSERT INTO zchargingpoints VALUES (
                                  i_mandt,
                                  i_guid,
                                  i_street,
                                  i_house_num,
                                  i_post_code,
                                  i_city,
                                  i_latitude,
                                  i_longitude,
                                  NEW ST_POINT(i_longitude, i_latitude).ST_SRID(4326)
                                );
  ENDMETHOD.

  METHOD get_nearest
    BY DATABASE PROCEDURE FOR HDB
    LANGUAGE SQLSCRIPT
    OPTIONS READ-ONLY
    USING zchargingpoints.

    e_nearest = SELECT TOP 10
                  geo.ST_AsGeoJSON() as geojson,
                  NEW ST_POINT(i_longitude, i_latitude).ST_SRID(4326).ST_Distance(geo, 'kilometer') AS distance
                  FROM zchargingpoints
                  ORDER BY distance;
  ENDMETHOD.

ENDCLASS.
