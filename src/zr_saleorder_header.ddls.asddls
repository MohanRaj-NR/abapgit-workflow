@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sale Order Header'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_Saleorder_Header as select from ZVBAK
composition [1..*] of Zr_saleorder_item as _ITEM
{
    key souuid as Souuid,
    vbeln as Vbeln,
    waers as Waers,
    @Semantics.amount.currencyCode: 'Waers'
    netwr as Netwr,
    localcreatedby as Localcreatedby,
    localcreatedat as Localcreatedat,
    locallastchangedby as Locallastchangedby,
    locallastchangedat as Locallastchangedat,
    _ITEM
}
