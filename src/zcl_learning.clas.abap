CLASS zcl_learning DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_learning IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    " 1. Clear existing data to avoid short dumps on duplicate keys
    DELETE FROM zvbak.
    DELETE FROM zvbap.

    " 2. Declare internal tables and variables
    DATA lt_vbak TYPE TABLE OF zvbak.
    DATA lt_vbap TYPE TABLE OF zvbap.

    DATA lv_timestamp TYPE abp_creation_tstmpl.
    GET TIME STAMP FIELD lv_timestamp.

    " 3. Generate Data for Record 1
    DATA(lv_uuid_h1) = cl_system_uuid=>create_uuid_x16_static( ).
    DATA(lv_uuid_i1) = cl_system_uuid=>create_uuid_x16_static( ).

    APPEND VALUE #( souuid             = lv_uuid_h1
                    vbeln              = '1000000001'
                    waers              = 'INR'
                    netwr              = '5000.00'
                    localcreatedby     = sy-uname
                    localcreatedat     = lv_timestamp
                    locallastchangedby = sy-uname
                    locallastchangedat = lv_timestamp ) TO lt_vbak.

    APPEND VALUE #( itemuuid           = lv_uuid_i1
                    parentid           = lv_uuid_h1
                    vbeln              = '1000000001'
                    posnr              = '000010'
                    werks              = '1000'
                    lgort              = '1001'
                    waers              = 'INR'
                    netpr              = '5000.00'
                    meins              = 'ST'
                    kwmeng             = 1
                    localcreatedby     = sy-uname
                    localcreatedat     = lv_timestamp
                    locallastchangedby = sy-uname
                    locallastchangedat = lv_timestamp ) TO lt_vbap.

    " 4. Generate Data for Record 2
    DATA(lv_uuid_h2) = cl_system_uuid=>create_uuid_x16_static( ).
    DATA(lv_uuid_i2) = cl_system_uuid=>create_uuid_x16_static( ).

    APPEND VALUE #( souuid             = lv_uuid_h2
                    vbeln              = '1000000002'
                    waers              = 'USD'
                    netwr              = '200.00'
                    localcreatedby     = sy-uname
                    localcreatedat     = lv_timestamp
                    locallastchangedby = sy-uname
                    locallastchangedat = lv_timestamp ) TO lt_vbak.

    APPEND VALUE #( itemuuid           = lv_uuid_i2
                    parentid           = lv_uuid_h2
                    vbeln              = '1000000002'
                    posnr              = '000010'
                    werks              = '2000'
                    lgort              = '2001'
                    waers              = 'USD'
                    netpr              = '100.00'
                    meins              = 'ST'
                    kwmeng             = 2
                    localcreatedby     = sy-uname
                    localcreatedat     = lv_timestamp
                    locallastchangedby = sy-uname
                    locallastchangedat = lv_timestamp ) TO lt_vbap.

    " 5. Generate Data for Record 3
    DATA(lv_uuid_h3) = cl_system_uuid=>create_uuid_x16_static( ).
    DATA(lv_uuid_i3) = cl_system_uuid=>create_uuid_x16_static( ).

    APPEND VALUE #( souuid             = lv_uuid_h3
                    vbeln              = '1000000003'
                    waers              = 'EUR'
                    netwr              = '350.75'
                    localcreatedby     = sy-uname
                    localcreatedat     = lv_timestamp
                    locallastchangedby = sy-uname
                    locallastchangedat = lv_timestamp ) TO lt_vbak.

    APPEND VALUE #( itemuuid           = lv_uuid_i3
                    parentid           = lv_uuid_h3
                    vbeln              = '1000000003'
                    posnr              = '000010'
                    werks              = '3000'
                    lgort              = '3001'
                    waers              = 'EUR'
                    netpr              = '350.75'
                    meins              = 'ST'
                    kwmeng             = 1
                    localcreatedby     = sy-uname
                    localcreatedat     = lv_timestamp
                    locallastchangedby = sy-uname
                    locallastchangedat = lv_timestamp ) TO lt_vbap.

    " 6. Insert Data into database tables
    INSERT zvbak FROM TABLE @lt_vbak.
    INSERT zvbap FROM TABLE @lt_vbap.

    " 7. Output result to the console
    IF sy-subrc = 0.
      out->write( 'Successfully inserted 3 RAP-compliant records into ZVBAK and ZVBAP.' ).
    ELSE.
      out->write( 'Error inserting data. Please check table definitions.' ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
