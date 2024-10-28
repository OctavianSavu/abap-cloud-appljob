CLASS zcl_os_ajob_watch DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.
    CLASS-METHODS: trace RETURNING VALUE(result) TYPE REF TO zcl_os_ajob_watch.
    METHODS: structure IMPORTING name TYPE string
                                 var  TYPE any.
    METHODS: variable IMPORTING name TYPE string
                                var  TYPE any.
    METHODS: itab IMPORTING name TYPE string
                            var  TYPE any.
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA instance TYPE REF TO zcl_os_ajob_watch.

    DATA job_catalog TYPE cl_apj_rt_api=>ty_catalog_name.
    DATA job_name    TYPE cl_apj_rt_api=>ty_jobname.
    DATA job_count   TYPE cl_apj_rt_api=>ty_jobcount.
    DATA job_stepc   TYPE i.
    DATA order_in_trace TYPE i.

    METHODS constructor.
    METHODS now RETURNING VALUE(result) TYPE timestampl.

    METHODS add_new_watcher_line IMPORTING !name        TYPE string
                                           !var_content TYPE any.
ENDCLASS.



CLASS zcl_os_ajob_watch IMPLEMENTATION.
  METHOD trace.
    IF instance IS NOT INITIAL.
      result = instance.
      RETURN.
    ENDIF.

    instance = NEW zcl_os_ajob_watch( ).
    result = instance.
  ENDMETHOD.

  METHOD constructor.
    TRY.
        cl_apj_rt_api=>get_job_runtime_info(
          IMPORTING
            ev_catalog_name  = me->job_catalog
            ev_jobname       = me->job_name
            ev_jobcount      = me->job_count
            ev_stepcount     = me->job_stepc ).

        order_in_trace = 0.
      CATCH cx_apj_rt.
        "handle exception
    ENDTRY.
  ENDMETHOD.

  METHOD now.
    GET TIME STAMP FIELD result.
  ENDMETHOD.

  METHOD add_new_watcher_line.

    TRY.
        me->order_in_trace += 1.
        DATA(watcher_line) = VALUE zos_job_tracer( trace_uuid       = cl_system_uuid=>create_uuid_x16_static( )
                                                   order_in_trace   = me->order_in_trace
                                                   job_catalog      = me->job_catalog
                                                   job_name         = me->job_name
                                                   job_count        = me->job_count
                                                   job_stepcount    = me->job_stepc
                                                   variable_name    = name
                                                   recorded_at      = me->now( )
                                                   variable_content = var_content ).

        INSERT zos_job_tracer FROM @watcher_line.

      CATCH cx_uuid_error cx_root.
        " handle exception
    ENDTRY.

  ENDMETHOD.

  METHOD structure.
    IF me->job_name IS INITIAL.
      RETURN.
    ENDIF.
    "##TO_DO "some checks that this is a structure
    TRY.
        DATA(var_content) = xco_cp_json=>data->from_abap( var )->to_string( ).
        add_new_watcher_line( name = name var_content  = var_content ).
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD itab.
    IF me->job_name IS INITIAL.
      RETURN.
    ENDIF.
    "##TO_DO "some checks that this is an internal table
    TRY.
        DATA(var_content) = xco_cp_json=>data->from_abap( var )->to_string( ).
        add_new_watcher_line( name = name var_content  = var_content ).
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD variable.
    IF me->job_name IS INITIAL.
      RETURN.
    ENDIF.
    "##TO_DO "some checks that this is a correct variable
    TRY.
        " In order to better visualize as json we add the member manually
        DATA(json) = xco_cp_json=>data->builder( )->begin_object( )->add_member( 'Test' )->add_string( |{ var }| )->end_object( ).
        DATA(var_content) = json->get_data( )->to_string( ).

        add_new_watcher_line( name        = name
                              var_content = var_content ).
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
