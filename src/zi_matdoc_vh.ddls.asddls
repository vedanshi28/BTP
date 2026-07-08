@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help for material document number'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_MATDOC_VH as select from I_MaterialDocumentHeader_2
{
     key MaterialDocument,
     key MaterialDocumentYear
}
