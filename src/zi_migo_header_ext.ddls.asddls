@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MIGO Header Extension'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZI_MIGO_HEADER_EXT
  as select distinct from I_MaterialDocumentItem_2 as Item

left outer join I_Supplier as Supplier
    on Supplier.Supplier = Item.Supplier

left outer join I_PurchaseOrderAPI01 as PO
    on PO.PurchaseOrder = Item.PurchaseOrder

{
    key Item.MaterialDocumentYear,
    key Item.MaterialDocument,
    Item.Supplier                 as Vendor,
    Supplier.SupplierName         as VendorName,
    Item.PurchaseOrder            as PurchaseOrder,
    PO.PurchasingGroup            as PurchasingGroup
}
