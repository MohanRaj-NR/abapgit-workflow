@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sale Order Item'
@Metadata.ignorePropagatedAnnotations: true
define view entity Zr_saleorder_item as select from zvbap
association to parent ZR_Saleorder_Header as _HEADER
    on $projection.Parentid = _HEADER.Souuid
{
    key itemuuid as itemuuid,
    parentid as Parentid,    
    vbeln as Vbeln,
    posnr as Posnr,
    werks as Werks,
    lgort as Lgort,
    waers as Waers,
    @Semantics.amount.currencyCode: 'Waers'
    netpr as Netpr,
    meins as Meins,
    @Semantics.quantity.unitOfMeasure: 'Meins'
    kwmeng as Kwmeng,
    @Semantics.user.createdBy: true
    localcreatedby as Localcreatedby,
    @Semantics.systemDateTime.createdAt: true
    localcreatedat as Localcreatedat,
    @Semantics.user.localInstanceLastChangedBy: true
    locallastchangedby as Locallastchangedby,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    locallastchangedat as Locallastchangedat,
    _HEADER 
}
