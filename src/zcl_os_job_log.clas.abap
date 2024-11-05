CLASS zcl_os_job_log DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

    CLASS-METHODS log IMPORTING obj           TYPE if_bali_log_filter=>ty_object      OPTIONAL
                                sobj          TYPE if_bali_log_filter=>ty_subobject   OPTIONAL
                                xid           TYPE if_bali_log_filter=>ty_external_id OPTIONAL
                      RETURNING VALUE(result) TYPE REF TO zcl_os_job_log.

    CLASS-METHODS set_info_for_current_session IMPORTING obj  TYPE if_bali_log_filter=>ty_object
                                                         sobj TYPE if_bali_log_filter=>ty_subobject
                                                         xid  TYPE if_bali_log_filter=>ty_external_id.

    METHODS add_free_text IMPORTING !text         TYPE string
                                    severity      TYPE cl_bali_free_text_setter=>ty_severity DEFAULT if_bali_constants=>c_severity_default
                          RETURNING VALUE(result) TYPE REF TO zcl_os_job_log.

    METHODS add_message IMPORTING severity      TYPE cl_bali_message_setter=>ty_severity DEFAULT if_bali_constants=>c_severity_status
                                  !id           TYPE cl_bali_message_setter=>ty_id
                                  !number       TYPE cl_bali_message_setter=>ty_number
                                  variable_1    TYPE cl_bali_message_setter=>ty_variable OPTIONAL
                                  variable_2    TYPE cl_bali_message_setter=>ty_variable OPTIONAL
                                  variable_3    TYPE cl_bali_message_setter=>ty_variable OPTIONAL
                                  variable_4    TYPE cl_bali_message_setter=>ty_variable OPTIONAL
                        RETURNING VALUE(result) TYPE REF TO zcl_os_job_log.

    METHODS save_log.
    METHODS constructor IMPORTING !inst TYPE REF TO if_bali_log OPTIONAL.

protected section.
  PRIVATE SECTION.
    TYPES: BEGIN OF ty_appl_log,
             obj      TYPE if_bali_log_filter=>ty_object,
             sobj     TYPE if_bali_log_filter=>ty_subobject,
             xid      TYPE if_bali_log_filter=>ty_external_id,
             instance TYPE REF TO zcl_os_job_log,
           END OF ty_appl_log.
    TYPES ty_appl_log_tt TYPE STANDARD TABLE OF ty_appl_log WITH EMPTY KEY.

    CLASS-DATA instance TYPE REF TO zcl_os_job_log.
    CLASS-DATA log_object    TYPE if_bali_log_filter=>ty_object.
    CLASS-DATA log_subobject TYPE if_bali_log_filter=>ty_subobject.
    CLASS-DATA external_id   TYPE if_bali_log_filter=>ty_external_id.

    DATA bali_log_inst TYPE REF TO if_bali_log.


ENDCLASS.



CLASS ZCL_OS_JOB_LOG IMPLEMENTATION.


  METHOD add_free_text.
    IF bali_log_inst IS NOT BOUND.
      RETURN.
    ENDIF.
    DATA(log_free_text) = cl_bali_free_text_setter=>create( severity = severity
                                                            text     = CONV #( text ) ).
    TRY.
        bali_log_inst->add_item( item = log_free_text ).
      CATCH cx_bali_runtime.
        "handle exception
    ENDTRY.
    result = me.
  ENDMETHOD.


  METHOD add_message.
    IF bali_log_inst IS NOT BOUND.
      RETURN.
    ENDIF.
    DATA(item) = cl_bali_message_setter=>create( id         = id
                                                 number     = number
                                                 severity   = severity
                                                 variable_1 = variable_1
                                                 variable_2 = variable_2
                                                 variable_3 = variable_3
                                                 variable_4 = variable_4 ).
    TRY.
        bali_log_inst->add_item( item = item ).
      CATCH cx_bali_runtime.
        "handle exception
    ENDTRY.
    result = me.
  ENDMETHOD.


  METHOD constructor.
    bali_log_inst = inst.
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    DATA(ext_id) = CONV if_bali_log_filter=>ty_external_id( 'DADFA4A4FB7D1EEFA493B5DE17E5CFA6' ).

    TRY.
        DATA(filter) = cl_bali_log_filter=>create( ).
        filter->set_descriptor( object      = 'ZOS_DEMO_JOB'
                                subobject   = 'JOB_LOG'
                                external_id = ext_id ).
        DATA(log_table) = cl_bali_log_db=>get_instance( )->load_logs_via_filter( filter = filter ).
        out->write( log_table ).
      CATCH cx_bali_runtime INTO DATA(exp).
        out->write( exp->get_text( ) ).
    ENDTRY.
  ENDMETHOD.


  METHOD log.
    IF instance IS NOT INITIAL.
      result = instance.
      RETURN.
    ENDIF.

    TRY.
        DATA(bali_log) = cl_bali_log=>create_with_header(
                             header = cl_bali_header_setter=>create(
                                          object      = COND #( WHEN obj IS NOT INITIAL THEN obj ELSE log_object )
                                          subobject   = COND #( WHEN sobj IS NOT INITIAL THEN sobj ELSE log_subobject )
                                          external_id = COND #( WHEN xid IS NOT INITIAL THEN xid ELSE external_id ) ) ).
        result = instance  = NEW #( bali_log ).
      CATCH cx_bali_runtime.
        " handle exception
    ENDTRY.
  ENDMETHOD.


  METHOD save_log.
    IF bali_log_inst IS NOT BOUND.
      RETURN.
    ENDIF.
    TRY.
        cl_bali_log_db=>get_instance( )->save_log( log                        = bali_log_inst
                                                   assign_to_current_appl_job = abap_true ).
      CATCH cx_bali_runtime.
        " handle exception
    ENDTRY.
  ENDMETHOD.


  METHOD set_info_for_current_session.
    log_object = obj.
    log_subobject = sobj.
    external_id = xid.
  ENDMETHOD.
ENDCLASS.
