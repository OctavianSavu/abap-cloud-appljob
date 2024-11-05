@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Job tracer - gathered variables'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZOS_I_JOB_TRACER_content
  as select from zos_job_tracer_p
  association        to parent zos_i_job_tracer_variables as _variable on  $projection.TraceUuid    = _variable.TraceUuid
                                                                       and $projection.OrderInTrace = _variable.OrderInTrace
  association [1..1] to zos_i_job_tracer                  as _tracer   on  $projection.TraceUuid = _tracer.TraceUuid
{
  key trace_uuid       as TraceUuid,
  key order_in_trace   as OrderInTrace,
      variable_name    as VariableName,
      variable_content as VariableContent,

      // Make association public
      _variable,
      _tracer
}
