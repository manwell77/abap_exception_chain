class ZCX_EXCHAIN definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.

  interfaces IF_T100_DYN_MSG .
  interfaces IF_T100_MESSAGE .

  constants:
    begin of ZCX_EXCHAIN,
      msgid type symsgid value 'ZEXCHAIN',
      msgno type symsgno value '000',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_EXCHAIN .
  constants:
    begin of ZCX_EXCHAIN_TABLE,
      msgid type symsgid value 'ZEXCHAIN',
      msgno type symsgno value '001',
      attr1 type scx_attrname value 'MESSAGE_V1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_EXCHAIN_TABLE .
  data MESSAGE_TAB type BAPIRET2_T .
  data MESSAGE_V1 type SYMSGV .
  data MESSAGE_V2 type SYMSGV .
  data MESSAGE_V3 type SYMSGV .
  data MESSAGE_V4 type SYMSGV .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MESSAGE_TAB type BAPIRET2_T optional
      !MESSAGE_V1 type SYMSGV optional
      !MESSAGE_V2 type SYMSGV optional
      !MESSAGE_V3 type SYMSGV optional
      !MESSAGE_V4 type SYMSGV optional .
  methods GET_MESSAGES
    returning
      value(RESULT) type BAPIRET2_T .
protected section.
private section.
ENDCLASS.



CLASS ZCX_EXCHAIN IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->MESSAGE_TAB = MESSAGE_TAB .
me->MESSAGE_V1 = MESSAGE_V1 .
me->MESSAGE_V2 = MESSAGE_V2 .
me->MESSAGE_V3 = MESSAGE_V3 .
me->MESSAGE_V4 = MESSAGE_V4 .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = ZCX_EXCHAIN .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.


  method get_messages.

    data: lv_sys type logsys,
          lv_log type bapi_msg.

    field-symbols: <ls_msg> type bapiret2.

*   get current system
    lv_sys = zcl_exchain_util=>get_own_logsys( ).
*   build main message (take care of default language in case it is not defined)
    lv_log = me->get_text( ).
*   add to message
    append value #( id = me->if_t100_message~t100key-msgid type = 'A' number = me->if_t100_message~t100key-msgno system = lv_sys
                    message_v1 = me->if_t100_dyn_msg~msgv1 message_v2 = me->if_t100_dyn_msg~msgv2 message_v3 = me->if_t100_dyn_msg~msgv3 message_v4 = me->if_t100_dyn_msg~msgv4 message = lv_log ) to result.
*   add additional messages
    loop at me->message_tab assigning <ls_msg>.
*     system not specified -> assume local
      if <ls_msg>-system is initial. <ls_msg>-system = lv_sys. endif.
*     message empty and same system -> build message
      if <ls_msg>-message is initial and <ls_msg>-system eq lv_sys.
        <ls_msg>-message = zcl_exchain_util=>build_message( id = <ls_msg>-id number = <ls_msg>-number v1 = <ls_msg>-message_v1 v2 = <ls_msg>-message_v2 v3 = <ls_msg>-message_v3 v4 = <ls_msg>-message_v4 ).
      endif.
*     add to result
      append value #( id = <ls_msg>-id type = <ls_msg>-type number = <ls_msg>-number message_v1 = <ls_msg>-message_v1 message_v2 = <ls_msg>-message_v2 message_v3 = <ls_msg>-message_v3 message_v4 = <ls_msg>-message_v4 system = <ls_msg>-system ) to result.
    endloop.

  endmethod.
ENDCLASS.
