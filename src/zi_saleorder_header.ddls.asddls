@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for Sale Order Header'
define root view entity zi_saleorder_header 
provider contract transactional_interface
 as projection on ZR_Saleorder_Header

{
    key Souuid,
    Vbeln,
    Waers,
    Netwr,
    Localcreatedby,
    Localcreatedat,
    Locallastchangedby,
    Locallastchangedat,
    /* Associations */
    _ITEM : redirected to composition child zi_saleorder_item
}
