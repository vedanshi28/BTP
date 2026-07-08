@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Migo print header entity'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_MIGO_HEADER as select from I_MaterialDocumentHeader_2 as MatDocHeader

association [0..1] to ZI_MIGO_HEADER_EXT as _HeaderExt
on  $projection.MaterialDocumentYear = _HeaderExt.MaterialDocumentYear
and $projection.MaterialDocument     = _HeaderExt.MaterialDocument

composition[0..*] of ZI_MIGO_ITEM as _MigoItem 
{
   key MaterialDocumentYear,
   key MaterialDocument,
   PostingDate as GoodsReceiptDate,
   PostingDate as CurrentDate,
   Plant,
   'Balaji Multiflex Pvt Ltd' as Description,
   StorageLocation,
   _HeaderExt.Vendor,
   _HeaderExt.VendorName,
   _HeaderExt.PurchaseOrder,
   _HeaderExt.PurchasingGroup,
   _HeaderExt,
   _MigoItem
   
}
