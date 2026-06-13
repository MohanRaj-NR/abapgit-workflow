@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Sale Order Item'
@Metadata.allowExtensions: true
define view entity zc_saleorder_item as projection on Zr_saleorder_item
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
    _HEADER : redirected to parent zc_saleorder_header 
}
