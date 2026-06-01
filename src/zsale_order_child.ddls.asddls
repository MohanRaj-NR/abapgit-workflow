@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Child entity Sale Order Item'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSALE_ORDER_CHILD as select from ZSALE_ORDER_ITEM
association to parent ZSALE_ORDER_ROOT as _header
    on $projection.Vbeln = _header.Vbeln
{
    key Vbeln,
    key Posnr,
    Werks,
    Lgort,
    Waers,
    @Semantics.amount.currencyCode: 'Waers'
    Netpr,
    meins,
    @Semantics.quantity.unitOfMeasure: 'meins'
    kwmeng,
    _header
     // Make association public
}
