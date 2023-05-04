class ZCL_EXCHAIN_DEMO definition
  public
  final
  create public .

public section.

  class-methods EXECUTE
    raising
      ZCX_EXCHAIN .
protected section.
private section.

  class-methods DYNAMIC_SELECT_FAIL
    raising
      ZCX_EXCHAIN .
ENDCLASS.



CLASS ZCL_EXCHAIN_DEMO IMPLEMENTATION.


  method dynamic_select_fail.

    data: lx_exc    type ref to cx_root,
          lt_ret    type standard table of bapiret2,
          lv_ebeln  type ebeln value '1000004321',
          ##NEEDED
          lt_tab    type standard table of t000,
          lv_ne_tab type db2t3obnam value 'TABNOTEXISTING'.

    try.

*       a dynamic select that fail
        select * from (lv_ne_tab) into table lt_tab where ebeln eq lv_ebeln.

      catch cx_static_check cx_dynamic_check into lx_exc.

*       check existence
        call function 'CHECK_R3TABLE_EXISTENCE'
          exporting
            tabname              = lv_ne_tab
          exceptions
            table_does_not_exist = 1
            others               = 2.

        if sy-subrc ne 0.
          append value #( id = zcl_exchain_util=>default_message_class type = 'E' number = '002' message_v1 = zcl_exchain_util=>to_symsgv( lv_ne_tab )
                          message = zcl_exchain_util=>build_message( number = '002' v1 = zcl_exchain_util=>to_symsgv( lv_ne_tab ) ) ) to lt_ret.
        endif.

        raise exception type zcx_exchain
          exporting
            textid      = zcx_exchain=>zcx_exchain_table
            message_tab = lt_ret
            previous    = lx_exc
            message_v1  = zcl_exchain_util=>to_symsgv( lv_ebeln ).

    endtry.

  endmethod.


  method execute.

    zcl_exchain_demo=>dynamic_select_fail( ).

  endmethod.
ENDCLASS.
