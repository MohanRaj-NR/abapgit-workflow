@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sale Order Header'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSALE_ORDER_HEADER as select from zvbak
{
    key vbeln as Vbeln,
    waers as Waers,
    @Semantics.amount.currencyCode: 'Waers'
    netwr as Netwr
}
