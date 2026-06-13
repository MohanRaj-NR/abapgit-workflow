@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for Sale Order Item'
define view entity zi_saleorder_item as projection on Zr_saleorder_item
{
    key itemuuid,
    Parentid,
    Vbeln,
    Posnr,
    Werks,
    Lgort,
    Waers,
    Netpr,
    Meins,
    Kwmeng,
    Localcreatedby,
    Localcreatedat,
    Locallastchangedby,
    Locallastchangedat,
    /* Associations */
    _HEADER : redirected to parent zi_saleorder_header
}
