function zexchainlog.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(LOGTABLE) TYPE  ZEXCHAINLOG_T
*"     VALUE(COMMIT) TYPE  XFELD DEFAULT 'X'
*"----------------------------------------------------------------------

  data: lv_id type numc11.

  field-symbols: <ls_log> type zexchainlog.

* next id
  lv_id = zcl_exchain_util=>get_next_id( ).

* set id
  loop at logtable assigning <ls_log>. <ls_log>-seqno = lv_id. add 1 to lv_id. endloop.

* write
  modify zexchainlog from table logtable.

* force db
  if commit eq abap_true. commit work and wait. endif.

endfunction.
