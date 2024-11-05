CLASS zcl_os_appl_job_util DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS is_job_already_running IMPORTING catalog           TYPE cl_apj_rt_api=>ty_catalog_name
                                         RETURNING VALUE(is_running) TYPE abap_bool.
    CLASS-METHODS schedule_job_now IMPORTING template     TYPE cl_apj_rt_api=>ty_template_name
                                             catalog      TYPE cl_apj_rt_api=>ty_catalog_name
                                             job_text     TYPE cl_apj_rt_api=>ty_job_text DEFAULT 'Job'
                                   EXPORTING jobname      TYPE cl_apj_rt_api=>ty_jobname
                                             jobcount     TYPE cl_apj_rt_api=>ty_jobcount
                                             ret_messages TYPE cl_apj_rt_api=>tt_bapiret2 .
    CLASS-METHODS get_current_job_name RETURNING VALUE(result) TYPE cl_apj_rt_api=>ty_jobname.

protected section.
private section.
ENDCLASS.



CLASS ZCL_OS_APPL_JOB_UTIL IMPLEMENTATION.


  METHOD get_current_job_name.
    TRY.
        " Get info about the current running job
        cl_apj_rt_api=>get_job_runtime_info( IMPORTING ev_jobname   = result
                                                       ev_jobcount  = DATA(jobcount)
                                                       ev_stepcount = DATA(stepcount) ).
      CATCH cx_apj_rt.
        " handle exception
    ENDTRY.
  ENDMETHOD.


  METHOD is_job_already_running.
    is_running = abap_false.
    TRY.
        " Get info about the current running job
        cl_apj_rt_api=>get_job_runtime_info( IMPORTING ev_jobname   = DATA(jobname)
                                                       ev_jobcount  = DATA(jobcount)
                                                       ev_stepcount = DATA(stepcount) ).

        DATA(existing_job_list) = cl_apj_rt_api=>find_jobs_with_jce( catalog ).
        LOOP AT existing_job_list INTO DATA(ex_job)
             WHERE     jobname   = jobname
                   AND jobcount <> jobcount
                   AND status    = 'R'.
          is_running = abap_true.
        ENDLOOP.

      CATCH cx_apj_rt.
        " handle exception
    ENDTRY.
  ENDMETHOD.


  METHOD schedule_job_now.
    GET TIME STAMP FIELD DATA(now).

    " Check first if the job can be scheduled
    TRY.
        DATA(can_schedule) = cl_apj_rt_api=>can_schedule_job( iv_job_template_name = template
                                                              iv_catalog_name      = catalog
                                                              iv_jobowner          = sy-uname
                                                              iv_jobuser           = sy-uname ).
        IF can_schedule = abap_false.
          RETURN.
        ENDIF.

        cl_apj_rt_api=>schedule_job( EXPORTING iv_job_template_name = template
                                               iv_job_text          = job_text
                                               is_start_info        = VALUE #( start_immediately = abap_true
                                                                               timestamp         = now )
                                               iv_username          = sy-uname
*                                               is_end_info          =
                                               is_scheduling_info   = VALUE #( periodic_granularity = '' periodic_value = 1 timezone = cl_abap_context_info=>get_user_time_zone( ) )
*                                               it_job_parameter_value =
*                                               iv_jobname           =
*                                               iv_jobcount          =
                                               iv_with_message_table = abap_true
                                     IMPORTING
                                               ev_jobname           = jobname
                                               ev_jobcount          = jobcount
                                               et_message           = ret_messages ).
      CATCH cx_apj_rt cx_abap_context_info_error  INTO DATA(exp).
        " handle exception
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
