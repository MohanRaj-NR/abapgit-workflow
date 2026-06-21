@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sale Order Header'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_Saleorder_Header as select from zvbak
composition [1..*] of Zr_saleorder_item as _ITEM
{
    key souuid as Souuid,
    vbeln as Vbeln,
    waers as Waers,
    @Semantics.amount.currencyCode: 'Waers'
    netwr as Netwr,
    @Semantics.user.createdBy: true
    localcreatedby,
    @Semantics.systemDateTime.createdAt: true
    localcreatedat,
    @Semantics.user.localInstanceLastChangedBy: true
    locallastchangedby,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    locallastchangedat,    
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at as lastchangedat,
    _ITEM
}
