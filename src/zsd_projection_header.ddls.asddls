@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection Header view'
@Metadata.ignorePropagatedAnnotations: true
define root view entity zsd_projection_header 
provider contract transactional_query
as projection on ZSALE_ORDER_ROOT
{
    key Vbeln,
    Waers,
    @Semantics.amount.currencyCode: 'Waers'
    Netwr,
    /* Associations */
    _Item : redirected to composition child zsd_projection_child
}
