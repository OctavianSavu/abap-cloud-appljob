CLASS zcl_os_demo_appl_job DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_apj_dt_exec_object.
    INTERFACES if_apj_rt_exec_object.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF appl_log_job,
        obj       TYPE if_bali_log_filter=>ty_object    VALUE 'ZOS_DEMO_JOB',
        subobj    TYPE if_bali_log_filter=>ty_subobject VALUE 'JOB_LOG',
        msg_class TYPE cl_bali_message_setter=>ty_id    VALUE 'ZOS_DEMO_JOB_MSG',
      END OF appl_log_job,
      BEGIN OF info_job,
        template TYPE cl_apj_rt_api=>ty_template_name VALUE 'ZOS_T_DEMO_JOB',
        catalog  TYPE cl_apj_rt_api=>ty_catalog_name  VALUE 'ZOS_C_DEMO_JOB',
      END OF info_job.

ENDCLASS.


CLASS zcl_os_demo_appl_job IMPLEMENTATION.

  METHOD if_apj_dt_exec_object~get_parameters.
  ENDMETHOD.

  METHOD if_apj_rt_exec_object~execute.
    " === This is a DEMO job execution - it will execute just some dummy checks ===
    " Set from the beginning what object/suboject and external ID you want to use for logging
    zcl_os_job_log=>set_info_for_current_session( obj  = appl_log_job-obj "'ZOS_DEMO_JOB'
                                                  sobj = appl_log_job-subobj "'JOB_LOG'
                                                  xid  = CONV #( zcl_os_appl_job_util=>get_current_job_name( ) ) ).

    " One demo success log
    zcl_os_job_log=>log( )->add_message( severity = if_bali_constants=>c_severity_information
                                         id       = appl_log_job-msg_class
                                         number   = '002' )->save_log( ).  " This is a demo success message.

    " I. First we want to make sure that this job is not running already
    IF zcl_os_appl_job_util=>is_job_already_running( info_job-catalog ) = abap_true.
      zcl_os_job_log=>log( )->add_free_text(
          text     = |An instance of this job is already running. This will be SKIPPED!|
          severity = if_bali_constants=>c_severity_warning )->save_log( ).
      RETURN.
    ENDIF.

    " One demo error log
    zcl_os_job_log=>log( )->add_message( severity = if_bali_constants=>c_severity_error
                                         id       = appl_log_job-msg_class
                                         number   = '001' )->save_log( ).  " This is a demo error message. Nothing to worry about.

    " ==== Test saving structure content
    SELECT SINGLE FROM i_country
      FIELDS *
      WHERE country = 'RO'
      INTO @DATA(structure_demo).

    zcl_os_ajob_watch=>trace( )->structure( name = 'STRUCTURE_DEMO' var  = structure_demo ).

    " ==== Test saving variable content
    zcl_os_ajob_watch=>trace( )->variable( name = 'COUNTRY' var  = structure_demo-country ).

    " ==== Test saving internal table content
    SELECT FROM i_country
      FIELDS *
      INTO TABLE @DATA(itab_demo).

    zcl_os_ajob_watch=>trace( )->itab( name = 'INTERNAL_TABLE_DEMO' var  = itab_demo ).

    COMMIT WORK.

  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.

    " Schedule the demo job now
    zcl_os_appl_job_util=>schedule_job_now( EXPORTING template     = info_job-template  "'ZOS_T_DEMO_JOB'
                                                      catalog      = info_job-catalog   "'ZOS_C_DEMO_JOB'
                                                      job_text     = 'This is a demo job - test'
                                            IMPORTING jobname      = DATA(jobname)
                                                      jobcount     = DATA(jobcount)
                                                      ret_messages = DATA(ret_messages) ).
    out->write( jobname ).
    out->write( jobcount ).
    out->write( ret_messages ).
  ENDMETHOD.

ENDCLASS.
