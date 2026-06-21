CLASS lhc_header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR header RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR header RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE header.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE header.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE header.

    METHODS read FOR READ
      IMPORTING keys FOR READ header RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK header.

    METHODS rba_Item FOR READ
      IMPORTING keys_rba FOR READ header\_Item FULL result_requested RESULT result LINK association_links.

    METHODS cba_Item FOR MODIFY
      IMPORTING entities_cba FOR CREATE header\_Item.
ENDCLASS.

CLASS lhc_header IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create.
    LOOP AT entities INTO DATA(ls_entity).
      DATA(ls_db_record) = CORRESPONDING zvbak( ls_entity MAPPING FROM ENTITY ).

      " Safety net: If framework left 'changed' blank, copy 'created' so ETags don't break
      IF ls_db_record-locallastchangedby IS INITIAL.
        ls_db_record-locallastchangedby = ls_db_record-localcreatedby.
        ls_db_record-locallastchangedat = ls_db_record-localcreatedat.
        ls_db_record-last_changed_at    = ls_db_record-localcreatedat.
      ENDIF.

      APPEND ls_db_record TO zcl_so_buffer=>mt_header_create.

      APPEND VALUE #( %cid   = ls_entity-%cid
                      Souuid = ls_entity-Souuid ) TO mapped-header.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    GET TIME STAMP FIELD DATA(lv_timestamp).

    LOOP AT entities INTO DATA(ls_entity).
      DATA(ls_db_record) = CORRESPONDING zvbak( ls_entity MAPPING FROM ENTITY ).

      ls_db_record-locallastchangedby = sy-uname.
      ls_db_record-locallastchangedat = lv_timestamp.
      ls_db_record-last_changed_at    = lv_timestamp.

      APPEND ls_db_record TO zcl_so_buffer=>mt_header_update.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_key).
      DATA(ls_db_record) = VALUE zvbak( souuid = ls_key-Souuid ).
      APPEND ls_db_record TO zcl_so_buffer=>mt_header_delete.
    ENDLOOP.
  ENDMETHOD.

  METHOD cba_Item.
    LOOP AT entities_cba INTO DATA(ls_entity_cba).
      LOOP AT ls_entity_cba-%target INTO DATA(ls_target).

        DATA(ls_db_item) = CORRESPONDING zvbap( ls_target MAPPING FROM ENTITY ).
        ls_db_item-parentid = ls_entity_cba-Souuid.

        " Safety net for ETags
        IF ls_db_item-locallastchangedby IS INITIAL.
          ls_db_item-locallastchangedby = ls_db_item-localcreatedby.
          ls_db_item-locallastchangedat = ls_db_item-localcreatedat.
        ENDIF.

        APPEND ls_db_item TO zcl_so_buffer=>mt_item_create.

        APPEND VALUE #( %cid     = ls_target-%cid
                        itemuuid = ls_target-itemuuid ) TO mapped-item.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    SELECT * FROM zvbak
      FOR ALL ENTRIES IN @keys
      WHERE souuid = @keys-Souuid
      INTO TABLE @DATA(lt_zvbak).

    IF sy-subrc = 0.
      result = CORRESPONDING #( lt_zvbak MAPPING TO ENTITY ).
    ELSE.
      LOOP AT keys INTO DATA(ls_key).
        APPEND VALUE #( souuid = ls_key-Souuid
                        %fail  = VALUE #( cause = if_abap_behv=>cause-not_found ) )
               TO failed-header.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_Item.
    SELECT * FROM zvbap
      FOR ALL ENTRIES IN @keys_rba
      WHERE parentid = @keys_rba-Souuid
      INTO TABLE @DATA(lt_zvbap).

    IF sy-subrc = 0.
      LOOP AT lt_zvbap INTO DATA(ls_db_item).
        APPEND CORRESPONDING #( ls_db_item MAPPING TO ENTITY ) TO result.

        APPEND VALUE #( source-Souuid   = ls_db_item-parentid
                        target-itemuuid = ls_db_item-itemuuid ) TO association_links.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZR_SALEORDER_HEADER DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS finalize REDEFINITION.
    METHODS check_before_save REDEFINITION.
    METHODS save REDEFINITION.
    METHODS cleanup REDEFINITION.
    METHODS cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_ZR_SALEORDER_HEADER IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    " ---------------------------------------------------------------------
    " 1. HEADER CREATES (With VBELN Generation)
    " ---------------------------------------------------------------------
    IF zcl_so_buffer=>mt_header_create IS NOT INITIAL.
      LOOP AT zcl_so_buffer=>mt_header_create ASSIGNING FIELD-SYMBOL(<ls_header_create>).
        IF <ls_header_create>-vbeln IS INITIAL.
          TRY.
              cl_numberrange_runtime=>number_get(
                EXPORTING
                  nr_range_nr       = '01'
                  object            = 'ZSO_NR'
                IMPORTING
                  number            = DATA(lv_new_vbeln) ).

              <ls_header_create>-vbeln = |{ lv_new_vbeln ALPHA = IN }|.
            CATCH cx_number_ranges INTO DATA(lx_error).
          ENDTRY.
        ENDIF.
      ENDLOOP.

      INSERT zvbak FROM TABLE @zcl_so_buffer=>mt_header_create.
    ENDIF.

    " ---------------------------------------------------------------------
    " 2. HEADER UPDATES & DELETES
    " ---------------------------------------------------------------------
    IF zcl_so_buffer=>mt_header_update IS NOT INITIAL.
      UPDATE zvbak FROM TABLE @zcl_so_buffer=>mt_header_update.
    ENDIF.

    IF zcl_so_buffer=>mt_header_delete IS NOT INITIAL.
      DELETE zvbak FROM TABLE @zcl_so_buffer=>mt_header_delete.
    ENDIF.

    " ---------------------------------------------------------------------
    " 3. ITEM CREATES (Cascading the VBELN)
    " ---------------------------------------------------------------------
    IF zcl_so_buffer=>mt_item_create IS NOT INITIAL.
      LOOP AT zcl_so_buffer=>mt_item_create ASSIGNING FIELD-SYMBOL(<ls_item_create>).

        " Check if the Header was just created in this transaction
        ASSIGN zcl_so_buffer=>mt_header_create[ souuid = <ls_item_create>-parentid ] TO FIELD-SYMBOL(<ls_parent_header>).

        IF sy-subrc = 0.
          <ls_item_create>-vbeln = <ls_parent_header>-vbeln.
        ELSE.
          " Otherwise, fetch the existing VBELN from the database
          SELECT SINGLE vbeln FROM zvbak
            WHERE souuid = @<ls_item_create>-parentid
            INTO @<ls_item_create>-vbeln.
        ENDIF.
      ENDLOOP.

      INSERT zvbap FROM TABLE @zcl_so_buffer=>mt_item_create.
    ENDIF.

    " ---------------------------------------------------------------------
    " 4. ITEM UPDATES & DELETES
    " ---------------------------------------------------------------------
    IF zcl_so_buffer=>mt_item_update IS NOT INITIAL.
      UPDATE zvbap FROM TABLE @zcl_so_buffer=>mt_item_update.
    ENDIF.

    IF zcl_so_buffer=>mt_item_delete IS NOT INITIAL.
      DELETE zvbap FROM TABLE @zcl_so_buffer=>mt_item_delete.
    ENDIF.

  ENDMETHOD.

  METHOD cleanup.
    " Completely clear the global bridge
    CLEAR: zcl_so_buffer=>mt_header_create,
           zcl_so_buffer=>mt_header_update,
           zcl_so_buffer=>mt_header_delete,
           zcl_so_buffer=>mt_item_create,
           zcl_so_buffer=>mt_item_update,
           zcl_so_buffer=>mt_item_delete.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
