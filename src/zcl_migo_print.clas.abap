CLASS zcl_migo_print DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
    CLASS-METHODS: read_posts IMPORTING iv_materialdocument TYPE string
                                        iv_year TYPE string
                              RETURNING VALUE(result) TYPE string.

    CONSTANTS lv_template_name TYPE string VALUE 'ZMigoPrint/ZMIGOPRINT'.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_migo_print IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
  ENDMETHOD.

  METHOD read_posts.

*    data(lv_materialdocument) = | { iv_materialdocument } ALPHA = IN |.

    SELECT single FROM zi_migo_header FIELDS
    MaterialDocumentYear, MaterialDocument, GoodsReceiptDate,
    CurrentDate, Plant, Description, StorageLocation, Vendor, VendorName, PurchaseOrder, PurchasingGroup
    WHERE MaterialDocumentYear = @iv_year and MaterialDocument = @iv_materialdocument INTO @data(ls_migo_header).

    if sy-subrc <> 0.
     result = |Error fetching records|.
     return.
    endif.

    SELECT FROM zi_migo_item FIELDS
     MaterialDocumentYear, MaterialDocument, LineItem, MaterialCode,
     ProductDescription, StorageLocation, Batch, Quantity, Unit
     where MaterialDocumentYear = @iv_year and MaterialDocument = @iv_materialdocument INTO TABLE @data(lt_migo_item).

     if sy-subrc <> 0.
      result = |Error fetching records|.
      return.
     endif.

    data(lv_xml_data) =
      |<Form>| &&
      |<MigoHeader>| &&
      |<MaterialDocumentYear>{ ls_migo_header-MaterialDocumentYear }</MaterialDocumentYear>| &&
      |<MaterialDocument>{ ls_migo_header-MaterialDocument ALPHA = OUT }</MaterialDocument>| &&
      |<GoodsReceiptDate>{ ls_migo_header-GoodsReceiptDate }</GoodsReceiptDate>| &&
      |<CurrentDate>{ ls_migo_header-CurrentDate }</CurrentDate>| &&
      |<Plant>{ ls_migo_header-Plant }</Plant>| &&
      |<Description>{ ls_migo_header-Description }</Description>| &&
      |<StorageLocation>{ ls_migo_header-StorageLocation }</StorageLocation>| &&
      |<Vendor>{ ls_migo_header-Vendor }</Vendor>| &&
      |<VendorName>{ ls_migo_header-VendorName }</VendorName>| &&
      |<PurchaseOrder>{ ls_migo_header-PurchaseOrder ALPHA = OUT }</PurchaseOrder>| &&
      |<PurchasingGroup>{ ls_migo_header-PurchasingGroup  }</PurchasingGroup>| &&
      |<to_MigoItem>|.

    LOOP AT lt_migo_item ASSIGNING FIELD-SYMBOL(<ls_migo_item>).
      lv_xml_data &&=
        |<MigoItem>| &&
        |<MaterialDocumentYear>{ <ls_migo_item>-MaterialDocumentYear }</MaterialDocumentYear>| &&
        |<MaterialDocument>{ <ls_migo_item>-MaterialDocument ALPHA = OUT }</MaterialDocument>| &&
        |<LineItem>{ <ls_migo_item>-LineItem ALPHA = OUT }</LineItem>| &&
        |<MaterialCode>{ <ls_migo_item>-MaterialCode ALPHA = OUT }</MaterialCode>| &&
        |<ProductDescription>{ <ls_migo_item>-ProductDescription }</ProductDescription>| &&
        |<StorageLocation>{ <ls_migo_item>-StorageLocation }</StorageLocation>| &&
        |<Batch>{ <ls_migo_item>-Batch }</Batch>| &&
        |<Quantity>{ <ls_migo_item>-Quantity }</Quantity>| &&
        |<Unit>{ <ls_migo_item>-Unit }</Unit>| &&
        |</MigoItem>|.
    ENDLOOP.

    lv_xml_data &&= |</to_MigoItem></MigoHeader></Form>|.

    CALL METHOD zcl_migo_adobe=>getpdf(
      EXPORTING
        iv_template = lv_template_name
        iv_xmldata  = lv_xml_data
      RECEIVING
        pdf_result  = result
    ).

  ENDMETHOD.

ENDCLASS.
