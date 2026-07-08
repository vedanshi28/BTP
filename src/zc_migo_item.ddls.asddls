@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View for MIGO Print Item'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_MIGO_ITEM as projection on ZI_MIGO_ITEM
{
    key MaterialDocumentYear,
    key MaterialDocument,
    key LineItem,
    MaterialCode,
    ProductDescription,
    StorageLocation,
    Batch,
    @Semantics.quantity.unitOfMeasure: 'Unit'
    Quantity,
    Unit,
    /* Associations */
    _MigoHeader : redirected to parent ZC_MIGO_HEADER
    
}
