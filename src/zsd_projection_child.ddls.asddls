@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection item view'
@Metadata.ignorePropagatedAnnotations: true
define view entity zsd_projection_child as projection on ZSALE_ORDER_CHILD
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
    /* Associations */
    _header : redirected to parent zsd_projection_header
}
