CLASS zcl_so_buffer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    " STATIC CLASS-DATA: This creates one shared shopping cart in memory
    CLASS-DATA: mt_header_create TYPE TABLE OF zvbak,
                mt_header_update TYPE TABLE OF zvbak,
                mt_header_delete TYPE TABLE OF zvbak,
                mt_item_create   TYPE TABLE OF zvbap,
                mt_item_update   TYPE TABLE OF zvbap,
                mt_item_delete   TYPE TABLE OF zvbap.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_so_buffer IMPLEMENTATION.
ENDCLASS.
