@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Migo print item entity'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_MIGO_ITEM as select distinct from I_MaterialDocumentItem_2 as MatDocItem

left outer join I_Product as Product
on Product.Product = MatDocItem.Material

association to parent ZI_MIGO_HEADER as _MigoHeader on $projection.MaterialDocument = _MigoHeader.MaterialDocument 
                                                    and $projection.MaterialDocumentYear = _MigoHeader.MaterialDocumentYear

{
    key MatDocItem.MaterialDocumentYear as MaterialDocumentYear,
    key MatDocItem.MaterialDocument as MaterialDocument,
    key MatDocItem.MaterialDocumentItem as LineItem,
    MatDocItem.Material as MaterialCode,
    Product.YY1_ProductName_PRD as ProductDescription,
    MatDocItem.StorageLocation as StorageLocation,
    MatDocItem.Batch as Batch,
    @Semantics.quantity.unitOfMeasure: 'Unit'
    MatDocItem.QuantityInBaseUnit as Quantity,
    MatDocItem.MaterialBaseUnit as Unit,
    _MigoHeader
    
}
