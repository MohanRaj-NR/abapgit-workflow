CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE item.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE item.

    METHODS setItemNumber FOR DETERMINE ON MODIFY
      IMPORTING keys FOR item~set_item.
    METHODS read FOR READ
      IMPORTING keys FOR READ item RESULT result.

    METHODS rba_Header FOR READ
      IMPORTING keys_rba FOR READ item\_Header FULL result_requested RESULT result LINK association_links.
ENDCLASS.

CLASS lhc_item IMPLEMENTATION.

  METHOD update.
    GET TIME STAMP FIELD DATA(lv_timestamp).

    LOOP AT entities INTO DATA(ls_entity).
      DATA(ls_db_item) = CORRESPONDING zvbap( ls_entity MAPPING FROM ENTITY ).

      " Update the changed timestamps/users
      ls_db_item-locallastchangedby = sy-uname.
      ls_db_item-locallastchangedat = lv_timestamp.

      " Push to the global bridge
      APPEND ls_db_item TO zcl_so_buffer=>mt_item_update.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_key).
      DATA(ls_db_record) = VALUE zvbap( itemuuid = ls_key-itemuuid ).
      " Push to the global bridge
      APPEND ls_db_record TO zcl_so_buffer=>mt_item_delete.
    ENDLOOP.
  ENDMETHOD.

  METHOD setItemNumber.
    " 1. Read the newly created Items
    READ ENTITIES OF ZR_Saleorder_Header IN LOCAL MODE
      ENTITY item
        FIELDS ( Parentid Posnr )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_new_items).

    " 2. Loop through the parents
    LOOP AT lt_new_items INTO DATA(ls_new_item) GROUP BY ls_new_item-Parentid.

      " 3. Bypass EML and check both physical tables for the highest number
      DATA lv_max_posnr TYPE n LENGTH 6 VALUE '000000'.

      " Check Active Table
      SELECT MAX( posnr ) FROM zvbap
        WHERE parentid = @ls_new_item-Parentid
        INTO @DATA(lv_active_max).

      IF lv_active_max > lv_max_posnr.
        lv_max_posnr = lv_active_max.
      ENDIF.

      " Check Draft Table
      SELECT MAX( posnr ) FROM zvbap_d
        WHERE parentid = @ls_new_item-Parentid
        INTO @DATA(lv_draft_max).

      IF lv_draft_max > lv_max_posnr.
        lv_max_posnr = lv_draft_max.
      ENDIF.

      " 4. Assign new numbers to the NEW items
      DATA lt_update TYPE TABLE FOR UPDATE ZR_Saleorder_Header\\item.

      LOOP AT lt_new_items INTO DATA(ls_update_item)
           WHERE Parentid = ls_new_item-Parentid
             AND Posnr IS INITIAL.

        " Increment by 10 (Type N handles the leading zeros automatically)
        lv_max_posnr = lv_max_posnr + 10.

        APPEND VALUE #( %tky  = ls_update_item-%tky
                        Posnr = lv_max_posnr ) TO lt_update.
      ENDLOOP.

      " 5. Silently update the Draft records
      IF lt_update IS NOT INITIAL.
        MODIFY ENTITIES OF ZR_Saleorder_Header IN LOCAL MODE
          ENTITY item
            UPDATE FIELDS ( Posnr )
            WITH lt_update
          REPORTED DATA(ls_reported).
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Header.
  ENDMETHOD.

ENDCLASS.
