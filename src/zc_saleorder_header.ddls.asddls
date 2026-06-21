@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Sale Order Header'
@Metadata.allowExtensions: true

define root view entity zc_saleorder_header
  provider contract transactional_query
  as projection on ZR_Saleorder_Header
{
  key Souuid,
      Vbeln,
      @Consumption.valueHelpDefinition: [{entity: {name: 'I_CurrencyStdVH', element: 'Currency' }, useForValidation: true }]
      Waers,
      Netwr,
      localcreatedby,
      localcreatedat,
      locallastchangedby,
      locallastchangedat,
      lastchangedat,
      /* Associations */
      _ITEM : redirected to composition child zc_saleorder_item
}
