@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sale Order Item'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSALE_ORDER_ITEM as select from zvbap
{
    key vbeln as Vbeln,
    key posnr as Posnr,
    werks as Werks,
    lgort as Lgort,
    waers as Waers,
    @Semantics.amount.currencyCode: 'Waers'
    netpr as Netpr,
    meins as meins,
    @Semantics.quantity.unitOfMeasure: 'meins'
    kwmeng as kwmeng
}
