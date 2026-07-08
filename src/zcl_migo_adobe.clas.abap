CLASS zcl_migo_adobe DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .

    TYPES :
      BEGIN OF struct,
        xdp_template TYPE string,
        xml_data     TYPE string,
        form_type    TYPE string,
        form_locale  TYPE string,
        tagged_pdf   TYPE string,
        embed_font   TYPE string,
      END OF struct.

      CLASS-DATA: lv_url1 TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.in30.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2',
                  lv_url2 TYPE string VALUE 'https://main-development-integration-b8sq4esz.authentication.in30.hana.ondemand.com/oauth/token'.

      CLASS-METHODS: getpdf IMPORTING VALUE(iv_template) TYPE string
                                      VALUE(iv_xmldata) TYPE string
                            RETURNING VALUE(pdf_result) TYPE string,

                     create_client IMPORTING VALUE(url) TYPE string
                     RETURNING VALUE(client) TYPE REF TO if_web_http_client.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_migo_adobe IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
  ENDMETHOD.

  METHOD create_client.
    TRY.
        data(dest) = cl_http_destination_provider=>create_by_url( url ).
        client = cl_web_http_client_manager=>create_by_http_destination( dest ).
      CATCH cx_http_dest_provider_error.
      CATCH cx_web_http_client_error.
    ENDTRY.
  ENDMETHOD.

  METHOD getpdf.

  REPLACE ALL OCCURRENCES OF '\t' IN iv_xmldata WITH '&#9;'.
    REPLACE ALL OCCURRENCES OF '\n' IN iv_xmldata WITH '&#10;'.
    REPLACE ALL OCCURRENCES OF '\r' IN iv_xmldata WITH '&#13;'.
    REPLACE ALL OCCURRENCES OF '!' IN iv_xmldata WITH '&#33;'.
    REPLACE ALL OCCURRENCES OF '$' IN iv_xmldata WITH '&#36;'.
    REPLACE ALL OCCURRENCES OF '&' IN iv_xmldata WITH '&#38;'.
    REPLACE ALL OCCURRENCES OF '(' IN iv_xmldata WITH '&#40;'.
    REPLACE ALL OCCURRENCES OF ')' IN iv_xmldata WITH '&#41;'.
    REPLACE ALL OCCURRENCES OF '*' IN iv_xmldata WITH '&#42;'.
    REPLACE ALL OCCURRENCES OF '+' IN iv_xmldata WITH '&#43;'.
    REPLACE ALL OCCURRENCES OF ':' IN iv_xmldata WITH '&#58;'.
    REPLACE ALL OCCURRENCES OF '=' IN iv_xmldata WITH '&#61;'.
    REPLACE ALL OCCURRENCES OF '?' IN iv_xmldata WITH '&#63;'.
    REPLACE ALL OCCURRENCES OF '@' IN iv_xmldata WITH '&#64;'.
    REPLACE ALL OCCURRENCES OF '[' IN iv_xmldata WITH '&#91;'.
    REPLACE ALL OCCURRENCES OF ']' IN iv_xmldata WITH '&#93;'.
    REPLACE ALL OCCURRENCES OF '^' IN iv_xmldata WITH '&#94;'.
    REPLACE ALL OCCURRENCES OF '`' IN iv_xmldata WITH '&#96;'.
    REPLACE ALL OCCURRENCES OF '{' IN iv_xmldata WITH '&#123;'.
    REPLACE ALL OCCURRENCES OF '|' IN iv_xmldata WITH '&#124;'.
    REPLACE ALL OCCURRENCES OF '}' IN iv_xmldata WITH '&#125;'.
    REPLACE ALL OCCURRENCES OF '~' IN iv_xmldata WITH '&#126;'.
    REPLACE ALL OCCURRENCES OF 'µ' IN iv_xmldata WITH '&#181;'.
    REPLACE ALL OCCURRENCES OF '✓' IN iv_xmldata WITH 'a'.

    data(url) = |{ lv_url2 }|.

    data(client) = create_client( url ).

    data(req) = client->get_http_request(  ).
    req->set_authorization_basic( i_username = 'sb-7cbd6894-d48d-4cde-9fc8-ecac35efc144!b42146|ads-xsappname!b25702'
    i_password = 'e704af45-97ce-478d-b15e-16ef83a840e0$7o_GcEL1mN1PGsKM1MRKsXD0QnhdAXACRY2VTSBH8Do=' ).
    req->set_content_type( 'application/x-www-form-urlencoded' ).
    req->set_form_field( EXPORTING i_name  = 'grant_type'
                                   i_value = 'client_credentials' ).

    TRY.
        data(response) = client->execute( if_web_http_client=>post )->get_text(  ).
      CATCH cx_web_http_client_error cx_web_message_error.
    ENDTRY.

    REPLACE ALL OCCURRENCES OF '{"access_token":"' IN response WITH ''.
    SPLIT response AT '","token_type' INTO DATA(v1) DATA(v2) .
    DATA(access_token) = v1 .

    TRY.
        client->close(  ).
      CATCH cx_web_http_client_error.
    ENDTRY.

    DATA(ls_xml_data) = cl_web_http_utility=>encode_base64( iv_xmldata ).

    url = |{ lv_url1 }|.

    client = create_client( url ).
    req = client->get_http_request(  ).
    req->set_authorization_bearer( access_token ).

     DATA(ls_body) = VALUE struct( xdp_template = iv_template
                                     xml_data = ls_xml_data
                                     form_type = 'print'
                                     form_locale = 'en_US'
                                     tagged_pdf = '0'
                                     embed_font = '0' ).

    data(lv_json) = /ui2/cl_json=>serialize( data = ls_body compress = abap_true pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).
    req->append_text( EXPORTING data = lv_json ).
    req->set_content_type( 'application/json' ).

    DATA: url_response TYPE string.
    TRY.
        url_response = client->execute( if_web_http_client=>post )->get_text( ).
      CATCH cx_web_http_client_error cx_web_message_error.
    ENDTRY.
    pdf_result = url_response .

    FIELD-SYMBOLS:
      <data>                TYPE data,
      <field>               TYPE any,
      <pdf_based64_encoded> TYPE any.

    DATA(lr_d) = /ui2/cl_json=>generate( json = url_response ).

    IF lr_d IS BOUND.
      ASSIGN lr_d->* TO <data>.
      ASSIGN COMPONENT `fileContent` OF STRUCTURE <data> TO <field>.
      IF sy-subrc EQ 0.
        ASSIGN <field>->* TO <pdf_based64_encoded>.
        pdf_result = <pdf_based64_encoded> .
      ELSE.
        pdf_result = 'ERROR'.
      ENDIF.
    ENDIF.

  ENDMETHOD.


ENDCLASS.
