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
    DATA: lt_interval TYPE cl_numberrange_intervals=>nr_interval,
          ls_interval LIKE LINE OF lt_interval,
          lv_error    TYPE bapi_msg,
          lv_error_w  TYPE bapi_msg.

    " 1. Define the Interval parameters
    ls_interval-nrrangenr  = '01'.
    ls_interval-fromnumber = '100000000'.   " <--- Your requested starting number
    ls_interval-tonumber   = '199999999'.   " <--- The maximum number
    ls_interval-procind    = 'I'.           " I = Insert

    APPEND ls_interval TO lt_interval.

    " 2. Push the interval to the Number Range Object
    TRY.
        cl_numberrange_intervals=>create(
          EXPORTING
            interval  = lt_interval
            object    = 'ZSO_NR'            " <--- Change to your exact Number Range Object name

        ).

        IF lv_error IS INITIAL.
          out->write( 'Success! Your Sales Orders will now start at 100000000.' ).
        ELSE.
          out->write( |Error occurred: { lv_error }| ).
        ENDIF.

      CATCH cx_number_ranges INTO DATA(lx_number_range).
        out->write( lx_number_range->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
