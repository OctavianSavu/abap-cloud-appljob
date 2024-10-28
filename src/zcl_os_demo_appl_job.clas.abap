CLASS zcl_os_demo_appl_job DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_apj_dt_exec_object.
    INTERFACES if_apj_rt_exec_object.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_os_demo_appl_job IMPLEMENTATION.

  METHOD if_apj_dt_exec_object~get_parameters.
  ENDMETHOD.

  METHOD if_apj_rt_exec_object~execute.
    " === This is a DEMO job execution - it will execute just some dummy checks ===
    DATA(jobname) = 'DADFA4A4FB7D1EEFA493B5DE17E5CFA6'.
*    TRY.
*        cl_apj_rt_api=>get_job_runtime_info( IMPORTING ev_jobname = DATA(jobname) ).
*      CATCH cx_apj_rt.
*        "handle exception
*    ENDTRY.

    zcl_os_job_log=>set_info_for_current_session( obj  = 'ZOS_DEMO_JOB'
                                                  sobj = 'JOB_LOG'
                                                  xid  = CONV #( jobname ) ).

    zcl_os_job_log=>log( )->add_message( severity = if_bali_constants=>c_severity_error
                                         id       = 'ZOS_DEMO_JOB'
                                         number   = '002' )->save_log( ).  "This is a demo success message.

    " I. First we want to make sure that this job is not running already
    IF zcl_os_appl_job_util=>is_job_already_running( 'ZOS_C_DEMO_JOB' ) = abap_true.
      zcl_os_job_log=>log( )->add_free_text(
          text     = |An instance of this job is already running. This will be SKIPPED!|
          severity = if_bali_constants=>c_severity_warning )->save_log( ).
      RETURN.
    ENDIF.

    zcl_os_job_log=>log( )->add_message( severity = if_bali_constants=>c_severity_error
                                         id       = 'ZOS_DEMO_JOB'
                                         number   = '001' )->save_log( ).  "This is a demo error message. Nothing to worry about.

*    " Demo Step 1 - I want to discover the total booking fees taken by agencies in each existing currencies
*    SELECT FROM /DMO/I_Travel_M
*      FIELDS agency_id          AS AgencyId,
*             \_Agency-Name      AS AgencyName,
*             currency_code      AS Currency,
*             SUM( booking_fee ) AS TotalFee
*      WHERE booking_fee > 0
*      GROUP BY agency_id, \_Agency-Name, currency_code
*      ORDER BY currency,
*               totalfee DESCENDING
*      INTO TABLE @DATA(agencies_fees).
*
*    " Demo Step 2 - I want to discover what is the maximum booking fee registered by an agncy in EUR
*    DATA(agency_max_fee) = VALUE #( agencies_fees[ currency = 'EUR' ] OPTIONAL ).
*
*    " Demo Step 3 - I want to get all the information about the agency that took the biggest booing fee in total in EUR
*    SELECT SINGLE FROM /DMO/I_Agency
*      FIELDS *
*      WHERE AgencyID = @agency_max_fee-agencyid
*      INTO @DATA(agency_max_fee_info).

    COMMIT WORK.
  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.
    DATA parameters TYPE if_apj_rt_exec_object=>tt_templ_val.
    me->if_apj_rt_exec_object~execute( it_parameters = parameters ).
*CATCH cx_apj_rt_content.

    RETURN.
    " Schedule the demo job now
    zcl_os_appl_job_util=>schedule_job_now( EXPORTING template     = 'ZOS_T_DEMO_JOB'
                                                      catalog      = 'ZOS_C_DEMO_JOB'
                                                      job_text     = 'This is a demo job - test'
                                            IMPORTING jobname      = DATA(jobname)
                                                      jobcount     = DATA(jobcount)
                                                      ret_messages = DATA(ret_messages) ).
    out->write( jobname ).
    out->write( jobcount ).
    out->write( ret_messages ).

  ENDMETHOD.

ENDCLASS.
