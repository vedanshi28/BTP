@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View for MIGO Print Header'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_MIGO_HEADER 
provider contract transactional_query
 as projection on ZI_MIGO_HEADER
{
    key MaterialDocumentYear,
    @Consumption.valueHelpDefinition: [{ entity.name: 'ZI_MATDOC_VH', entity.element: 'MaterialDocument' }]
    key MaterialDocument,
    GoodsReceiptDate,
    CurrentDate,
    Plant,
    Description,
    StorageLocation,
    Vendor,
    VendorName,
    PurchaseOrder,
    PurchasingGroup,
    /* Associations */
    _HeaderExt,
    _MigoItem : redirected to composition child ZC_MIGO_ITEM
}
