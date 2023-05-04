*&---------------------------------------------------------------------*
*& Report ZEXCHAINLOGSAMPLE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report zexchainlogsample.

parameters: p_cln type xfeld as checkbox.

start-of-selection.

  ##NEEDED
  data: lx_exc type ref to cx_root,
        ls_dat type zexchaindb.

* clean and start new luw
  if p_cln eq abap_true. delete from: zexchainlog, zexchaindb. commit work. endif.

  try.
*     start transactional operatoional
      select max( numkey ) from zexchaindb into ls_dat-numkey.
      ls_dat-mandt = sy-mandt. add 1 to ls_dat-numkey. ls_dat-sampledata = 'PIPPOZ'. insert zexchaindb from ls_dat.
      zcl_exchain_demo=>execute( ).
*     end transactional operation
    catch cx_static_check cx_dynamic_check into lx_exc.
*     if need to rollback transactional operation do it before logging (otherwise logging will be affected by rollback)
      rollback work.
      zcl_exchain_util=>log_exception( lx_exc ).
  endtry.
