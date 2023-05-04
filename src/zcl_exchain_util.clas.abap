class ZCL_EXCHAIN_UTIL definition
  public
  final
  create public .

public section.

  constants DEFAULT_LANGU type SYLANGU value 'E' ##NO_TEXT.
  constants DEFAULT_MESSAGE_CLASS type ARBGB value 'ZEXCHAIN' ##NO_TEXT.

  class-methods GET_NEXT_ID
    returning
      value(RESULT) type NUMC11 .
  class-methods GET_OWN_LOGSYS
    returning
      value(RESULT) type LOGSYS .
  class-methods LOG_BAPIRET2
    importing
      value(MESSAGES) type BAPIRET2_T
      value(CPROG) type SYCPROG default SY-CPROG
      value(REPID) type SYREPID default SY-REPID
      value(LANGU) type SYLANGU default SY-LANGU
      value(UNAME) type SYUNAME default SY-UNAME
      value(DATUM) type SYDATUM default SY-DATUM
      value(UZEIT) type SYUZEIT default SY-UZEIT .
  class-methods LOG_EXCEPTION
    importing
      value(EXCEPTION) type ref to CX_ROOT
      value(CPROG) type SYCPROG default SY-CPROG
      value(REPID) type SYREPID default SY-REPID
      value(LANGU) type SYLANGU default SY-LANGU
      value(UNAME) type SYUNAME default SY-UNAME
      value(DATUM) type SYDATUM default SY-DATUM
      value(UZEIT) type SYUZEIT default SY-UZEIT .
  class-methods TO_SYMSGV
    importing
      value(VALUE) type ANY
    returning
      value(RESULT) type SYMSGV .
  class-methods BUILD_MESSAGE
    importing
      value(ID) type SYMSGID default 'ZEXCHAIN'
      value(NUMBER) type SYMSGNO
      value(V1) type ANY optional
      value(V2) type ANY optional
      value(V3) type ANY optional
      value(V4) type ANY optional
    returning
      value(RESULT) type BAPI_MSG .
protected section.
private section.

  class-methods BAPIRET2_TO_LOG
    importing
      value(MESSAGES) type BAPIRET2_T
      value(CPROG) type SYCPROG optional
      value(REPID) type SYREPID optional
      value(LANGU) type SYLANGU optional
      value(UNAME) type SYUNAME optional
      value(DATUM) type SYDATUM optional
      value(UZEIT) type SYUZEIT optional
    returning
      value(RESULT) type ZEXCHAINLOG_T .
  class-methods EXCEPTION_TO_LOG
    importing
      value(EXCEPTION) type ref to CX_ROOT
      value(CPROG) type SYCPROG optional
      value(REPID) type SYREPID optional
      value(LANGU) type SYLANGU optional
      value(UNAME) type SYUNAME optional
      value(DATUM) type SYDATUM optional
      value(UZEIT) type SYUZEIT optional
    returning
      value(RESULT) type ZEXCHAINLOG_T .
ENDCLASS.



CLASS ZCL_EXCHAIN_UTIL IMPLEMENTATION.


  method bapiret2_to_log.

    data: ls_msg type bapiret2,
          ls_log type zexchainlog,
          lv_sys type logsys.

*   no messages
    if messages is initial. return. endif.

*   get own logsys
    lv_sys = zcl_exchain_util=>get_own_logsys( ).

*   prepare
    loop at messages into ls_msg.
*     clean
      clear: ls_log.
*     assign system
      if ls_msg-system is initial. ls_msg-system = lv_sys. endif.
*     other fields except seqno (decided just before logging to db)
      ls_log-mandt = sy-mandt.
      ls_log-systm = ls_msg-system.
      ls_log-cprog = cprog.
      ls_log-repid = repid.
      ls_log-langu = langu.
      ls_log-uname = uname.
      ls_log-datum = datum.
      ls_log-uzeit = uzeit.
      ls_log-severity = ls_msg-type.
      if not ls_msg-message is initial.
        ls_log-log = ls_msg-message.
      else.
        ls_log-log = zcl_exchain_util=>build_message( id = ls_msg-id number = ls_msg-number v1 = ls_msg-message_v1 v2 = ls_msg-message_v2 v3 = ls_msg-message_v3 v4 = ls_msg-message_v4 ).
      endif.
*     add
      append ls_log to result.
    endloop.

  endmethod.


  method build_message.

    data: lv_msg type sylisel.

*   in login language
    message id id type 'I' number number with v1 v2 v3 v4 into result.

*   not found -> in default language
    if result is initial and zcl_exchain_util=>default_langu ne sy-langu.
*     message builder
      call function 'RPY_MESSAGE_COMPOSE'
        exporting
          language          = zcl_exchain_util=>default_langu
          message_id        = id
          message_number    = number
          message_var1      = v1
          message_var2      = v2
          message_var3      = v3
          message_var4      = v4
        importing
          message_text      = lv_msg
        exceptions
          message_not_found = 0
          others            = 0.
*     cast
      result = lv_msg.
    endif.

*   still empty -> write cohordinates
    if result is initial.
      result = |message { number }({ id }) with { v1 } { v2 } { v3 } { v4 }|.
    endif.

  endmethod.


  method exception_to_log.

    data: lt_lon type standard table of string,
          ls_log type zexchainlog,
          lv_lon type string,
          lv_sys type logsys.

*   no messages
    if exception is not bound. return. endif.

*   get own logsys
    lv_sys = zcl_exchain_util=>get_own_logsys( ).

*   prepare main text
    ls_log-mandt = sy-mandt.
    ls_log-systm = lv_sys.
    ls_log-cprog = cprog.
    ls_log-repid = repid.
    ls_log-langu = langu.
    ls_log-uname = uname.
    ls_log-datum = datum.
    ls_log-uzeit = uzeit.
    ls_log-severity = 'A'.
    ls_log-log = exception->get_text( ).
    append ls_log to result.

*   long text
    lv_lon = exception->get_longtext( ).

*   nothing -> return.
    if lv_lon is initial. return. endif.

*   add long
    split lv_lon at cl_abap_char_utilities=>cr_lf into table lt_lon.
    loop at lt_lon into lv_lon. ls_log-log = lv_lon. append ls_log to result. endloop.

  endmethod.


  method get_next_id.

    select max( seqno ) from zexchainlog into result.
    add 1 to result.

  endmethod.


  method get_own_logsys.

*   get current system
    call function 'OWN_LOGICAL_SYSTEM_GET'
      importing
        own_logical_system             = result
      exceptions
        own_logical_system_not_defined = 0
        others                         = 0.

  endmethod.


  method log_bapiret2.

    data: lt_log type zexchainlog_t.

*   no messages
    if messages is initial. return. endif.

*   to log
    lt_log = zcl_exchain_util=>bapiret2_to_log( messages = messages cprog = cprog repid = repid langu = langu uname = uname datum = datum uzeit = uzeit ).

*   log
    call function 'ZEXCHAINLOG'
      exporting
        logtable = lt_log.

  endmethod.


  method log_exception.

    data: lx_exc type ref to zcx_exchain,
          lt_log type zexchainlog_t.

*   check exception
    if exception is not bound. return. endif.

*   prepare
    do.
*     my main exception?
      try.
*         try to cast to check if it is my root exception
          free lx_exc. lx_exc ?= exception.
          insert lines of zcl_exchain_util=>bapiret2_to_log( messages = lx_exc->get_messages( ) cprog = cprog repid = repid langu = langu uname = uname datum = datum uzeit = uzeit ) into lt_log index 1.
        catch cx_static_check cx_dynamic_check.
*         means usual exception
          insert lines of zcl_exchain_util=>exception_to_log( exception = exception cprog = cprog repid = repid langu = langu uname = uname datum = datum uzeit = uzeit ) into lt_log index 1.
      endtry.
*     rebase
      if lx_exc is bound. exception = lx_exc. endif.
*     check previous
      if exception->previous is not bound. exit. else. exception = exception->previous. endif.
    enddo.

*   log
    call function 'ZEXCHAINLOG'
      exporting
        logtable = lt_log.

  endmethod.


  method to_symsgv.

*   write to
    result = value.

    condense result.

    call function 'CONVERSION_EXIT_ALPHA_OUTPUT'
      exporting
        input  = result
      importing
        output = result.

  endmethod.
ENDCLASS.
