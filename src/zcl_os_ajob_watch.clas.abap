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
    METHODS persist_log IMPORTING exec_commit TYPE abap_bool DEFAULT abap_false.
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA instance TYPE REF TO zcl_os_ajob_watch.
    DATA: tracer_header    TYPE zos_job_tracer_h,
          tracer_variables TYPE STANDARD TABLE OF zos_job_tracer_p WITH EMPTY KEY.
    DATA order_in_trace TYPE i.

    METHODS constructor.
    METHODS now RETURNING VALUE(result) TYPE timestampl.

    METHODS add_new_watcher_line IMPORTING !name        TYPE string
                                           !var_content TYPE any.

ENDCLASS.



CLASS ZCL_OS_AJOB_WATCH IMPLEMENTATION.


  METHOD add_new_watcher_line.
    TRY.
        order_in_trace += 1.
        APPEND VALUE #( trace_uuid       = tracer_header-trace_uuid
                        order_in_trace   = order_in_trace
                        variable_name    = name
                        recorded_at      = now( )
                        variable_content = var_content ) TO me->tracer_variables.
      CATCH cx_root.
        " Nothing should happen==> execution is not prevented if any error happens here
    ENDTRY.
  ENDMETHOD.


  METHOD constructor.
    TRY.
        " ====Getting job information
        cl_apj_rt_api=>get_job_runtime_info( IMPORTING ev_catalog_name = tracer_header-job_catalog
                                                       ev_jobname      = tracer_header-job_name
                                                       ev_jobcount     = tracer_header-job_count
                                                       ev_stepcount    = DATA(stepcount) ).
        tracer_header-job_stepcount = stepcount.
        tracer_header-trace_uuid    = cl_system_uuid=>create_uuid_x16_static( ).

        tracer_header-created_by = sy-uname.
        tracer_header-created_at = now( ).

        order_in_trace = 0.

        " ==== Getting the class name
        " The CONSTRCTOR[1] is called in static method TRACE[2] called in the JOB CLASS[3] => so we need the 3rd position in the call stack
        DATA(call_stack) = xco_cp=>current->call_stack->full( ).
        DATA(format) = xco_cp_call_stack=>format->adt( )->with_line_number_flavor(
                           xco_cp_call_stack=>line_number_flavor->source ).

        DATA(searched_line) = call_stack->from->position( 3 )->to->position( 1 )->as_text( io_format = format ).

        DATA(text_table) = searched_line->get_lines( )->value.
        IF lines( text_table ) >= 1.
          SPLIT text_table[ 1 ] AT ' ' INTO TABLE DATA(parts).
          tracer_header-class_name = VALUE #( parts[ 1 ] OPTIONAL ).
        ENDIF.

      CATCH cx_root.
        " Nothing should happen==> execution is not prevented if any error happens here
    ENDTRY.
  ENDMETHOD.


  METHOD itab.
    IF me->tracer_header-job_name IS INITIAL.
      RETURN.
    ENDIF.
    "##TO_DO "some checks that this is an internal table
    TRY.
        DATA(var_content) = xco_cp_json=>data->from_abap( var )->to_string( ).
        add_new_watcher_line( name = name var_content  = var_content ).
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.


  METHOD now.
    GET TIME STAMP FIELD result.
  ENDMETHOD.


  METHOD persist_log.

    INSERT zos_job_tracer_h FROM @me->tracer_header.
    INSERT zos_job_tracer_p FROM TABLE @me->tracer_variables.

    IF exec_commit = abap_true.
      COMMIT WORK.
    ENDIF.

  ENDMETHOD.


  METHOD structure.
    IF me->tracer_header-job_name IS INITIAL.
      RETURN.
    ENDIF.
    "##TO_DO "some checks that this is a structure
    TRY.
        DATA(var_content) = xco_cp_json=>data->from_abap( var )->to_string( ).
        add_new_watcher_line( name = name var_content  = var_content ).
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.


  METHOD trace.
    IF instance IS NOT INITIAL.
      result = instance.
      RETURN.
    ENDIF.

    instance = NEW zcl_os_ajob_watch( ).
    result = instance.
  ENDMETHOD.


  METHOD variable.
    IF me->tracer_header-job_name IS INITIAL.
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
