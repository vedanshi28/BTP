class ZCL_HTTP_MIGO_PRINT definition
  public
  create public .

public section.

  interfaces IF_HTTP_SERVICE_EXTENSION .
protected section.
private section.
ENDCLASS.



CLASS ZCL_HTTP_MIGO_PRINT IMPLEMENTATION.


  method IF_HTTP_SERVICE_EXTENSION~HANDLE_REQUEST.

    request->set_header_field( i_name = 'ACCESS-CONTROL-ALLOW-ORIGIN' i_value = '*' ).
    request->set_header_field( i_name = 'ACCESS-CONTROL-ALLOW-CREDENTIALS' i_value = 'TRUE' ).

*    if request->get_method( ) <> 'GET'.
*     response->set_status( i_code = '400' i_reason = 'Method not allowed' ).
*     response->set_text( 'Only GET is allowed' ).
*     return.
*    endif.

    data(lv_materialdocument) = request->get_form_field( 'MaterialDocument' ).
    data(lv_year) = request->get_form_field( 'MaterialDocumentYear' ).

    if lv_materialdocument is INITIAL.
      response->set_status( i_code = '400' i_reason = 'Bad Request' ).
      response->set_text( 'Material document is missing' ).
      return.
    endif.

    if lv_year is INITIAL.
      response->set_status( i_code = '400' i_reason = 'Bad Request' ).
      response->set_text( 'Material document year is missing' ).
      return.
    endif.

    lv_materialdocument = |{ lv_materialdocument ALPHA = IN }|.

    SELECT single from zi_migo_header FIELDS materialdocument, materialdocumentyear
    where materialdocument = @lv_materialdocument and materialdocumentyear = @lv_year INTO @data(ls_exists).

    if ls_exists is INITIAL.
     response->set_status( i_code = '404' i_reason = 'Not Found' ).
     response->set_text( |Material document { lv_materialdocument } does not exists| ).
     return.
    endif.

    data(pdf) = zcl_migo_print=>read_posts(
                  iv_materialdocument = lv_materialdocument
                  iv_year             = lv_year
                ).

    if pdf is INITIAL.
     response->set_status( i_code = '500' i_reason = 'Internal Server Error' ).
     response->set_text( 'Error generating form' ).
     return.
    else.
     response->set_status( i_code = '200' i_reason = 'OK' ).
     response->set_text( pdf ).
    endif.

  endmethod.
ENDCLASS.
