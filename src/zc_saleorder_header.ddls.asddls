@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Sale Order Header'
@Metadata.allowExtensions: true
   
define root view entity zc_saleorder_header
provider contract transactional_query
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
    _ITEM : redirected to composition child zc_saleorder_item
}
