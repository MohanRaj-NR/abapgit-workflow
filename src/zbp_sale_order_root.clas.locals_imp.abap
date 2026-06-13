CLASS lsc_zsale_order_root DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zsale_order_root IMPLEMENTATION.

  METHOD save_modified.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZSALE_ORDER_ROOT DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.


    METHODS earlynumbering_cba_item FOR NUMBERING
      IMPORTING entities FOR CREATE header\_item.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Header.

ENDCLASS.

CLASS lhc_ZSALE_ORDER_ROOT IMPLEMENTATION.

  METHOD earlynumbering_cba_Item.
  ENDMETHOD.

  METHOD earlynumbering_create.
  ENDMETHOD.

ENDCLASS.
