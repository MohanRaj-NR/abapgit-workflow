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
    METHODS copyOrder FOR MODIFY
      IMPORTING keys FOR ACTION header~copyOrder.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR header RESULT result.

    METHODS checkCreditLimit FOR READ
      IMPORTING keys FOR FUNCTION header~checkCreditLimit RESULT result.

    METHODS getTotalOrderCount FOR READ
      IMPORTING keys FOR FUNCTION header~getTotalOrderCount RESULT result.

    METHODS blockOrder FOR MODIFY
      IMPORTING keys FOR ACTION header~blockOrder RESULT result.

    METHODS cleanupOldDrafts FOR MODIFY
      IMPORTING keys FOR ACTION header~cleanupOldDrafts.

    METHODS secureFinancialAudit FOR MODIFY
      IMPORTING keys FOR ACTION header~secureFinancialAudit.
    METHODS SurgeCharge FOR MODIFY
      IMPORTING keys FOR ACTION header~SurgeCharge RESULT result.
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

  METHOD copyOrder.

   " 1. Read the source Header AND its Items
    READ ENTITIES OF ZR_Saleorder_Header IN LOCAL MODE
      ENTITY header ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_read_headers)
      ENTITY header BY \_ITEM ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_read_items)
FAILED failed

.

    DATA lt_create_headers TYPE TABLE FOR CREATE ZR_Saleorder_Header.
    DATA lt_create_items   TYPE TABLE FOR CREATE ZR_Saleorder_Header\_ITEM.

    LOOP AT keys INTO DATA(ls_key).
      ASSIGN lt_read_headers[ KEY entity Souuid = ls_key-Souuid ] TO FIELD-SYMBOL(<ls_original_header>).
      IF sy-subrc = 0.

        " ==========================================
        " PART A: PREPARE THE HEADER
        " ==========================================
        DATA ls_create_header LIKE LINE OF lt_create_headers.

        ls_create_header-%cid      = ls_key-%cid. " Fiori's tracker ID
        ls_create_header-%is_draft = if_abap_behv=>mk-on.

        " Copy fields, clear keys
        ls_create_header-%data    = CORRESPONDING #( <ls_original_header> EXCEPT Souuid Vbeln ).
        ls_create_header-%control = VALUE #( Netwr = if_abap_behv=>mk-on Waers = if_abap_behv=>mk-on ).

        APPEND ls_create_header TO lt_create_headers.

        " ==========================================
        " PART B: PREPARE THE ITEMS
        " ==========================================
        DATA ls_cba_items LIKE LINE OF lt_create_items.

        " LINK: Tell RAP these items belong to the Header we just created above!
        ls_cba_items-%cid_ref  = ls_key-%cid.
        ls_cba_items-%is_draft = if_abap_behv=>mk-on.

        " Loop through only the items that belong to this specific Header
        LOOP AT lt_read_items INTO DATA(ls_original_item) WHERE Parentid = <ls_original_header>-Souuid.
          DATA ls_create_item LIKE LINE OF ls_cba_items-%target.

          " We must invent a unique tracker ID for every new item row
          ls_create_item-%cid      = |COPY_ITEM_{ ls_original_item-itemuuid }|.
          ls_create_item-%is_draft = if_abap_behv=>mk-on.

          " Copy fields, clear the old Item UUID and Parent UUID
          ls_create_item-%data = CORRESPONDING #( ls_original_item EXCEPT itemuuid Parentid ).

          " Tell RAP exactly which fields to save to the Draft table
          ls_create_item-%control = VALUE #(
            Posnr = if_abap_behv=>mk-on
            Netpr = if_abap_behv=>mk-on
            Kwmeng = if_abap_behv=>mk-on
            werks = if_abap_behv=>mk-on
            lgort = if_abap_behv=>mk-on
          ).

          APPEND ls_create_item TO ls_cba_items-%target.
        ENDLOOP.

        " Only add to the master item table if this order actually had items
        IF ls_cba_items-%target IS NOT INITIAL.
          APPEND ls_cba_items TO lt_create_items.
        ENDIF.

      ENDIF.
    ENDLOOP.

    " ==========================================
    " PART C: EXECUTE DEEP CREATION
    " ==========================================
    MODIFY ENTITIES OF ZR_Saleorder_Header IN LOCAL MODE
      ENTITY header
        CREATE FROM lt_create_headers
        " Add the deep creation command for the items
        CREATE BY \_ITEM FROM lt_create_items
      MAPPED   mapped
      REPORTED reported
      FAILED   failed.

  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD checkCreditLimit.
  ENDMETHOD.

  METHOD getTotalOrderCount.
  ENDMETHOD.

  METHOD blockOrder.
  ENDMETHOD.

  METHOD cleanupOldDrafts.
  ENDMETHOD.

  METHOD secureFinancialAudit.
  ENDMETHOD.

  METHOD SurgeCharge.

  READ ENTITIES OF ZR_Saleorder_Header IN LOCAL MODE
      ENTITY header FIELDS ( Netwr ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    LOOP AT lt_headers INTO DATA(ls_header).
      " 2. Calculate a new total (e.g., adding a flat 500 flat fee)
      DATA(lv_new_total) = ls_header-Netwr + 500.

      " 3. Update the database buffer
      MODIFY ENTITIES OF ZR_Saleorder_Header IN LOCAL MODE
        ENTITY header
          UPDATE FIELDS ( Netwr )
          WITH VALUE #( ( %tky  = ls_header-%tky
                          Netwr = lv_new_total ) ).
    ENDLOOP.

    " -------------------------------------------------------------------
    " 4. THE MAGIC STEP: Read the fresh data and return it!
    " -------------------------------------------------------------------
    " We read the header again because the buffer now has the new 500 fee applied
    READ ENTITIES OF ZR_Saleorder_Header IN LOCAL MODE
      ENTITY header ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_updated_headers).

    " Move the updated rows directly into the 'result' parameter
    result = VALUE #( FOR updated_row IN lt_updated_headers
                      ( %tky   = updated_row-%tky
                        %param = updated_row ) ).

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
