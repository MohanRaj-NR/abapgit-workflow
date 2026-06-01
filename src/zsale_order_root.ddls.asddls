@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root entity Sale Order Header'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZSALE_ORDER_ROOT as select from ZSALE_ORDER_HEADER
composition [1..*] of ZSALE_ORDER_CHILD as _Item
{
    key Vbeln,
    Waers,
    @Semantics.amount.currencyCode: 'Waers'
    Netwr,
    _Item // Make association public
}
