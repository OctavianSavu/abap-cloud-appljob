@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Job tracer - gathered variables'
@Metadata.ignorePropagatedAnnotations: true
define view entity zos_i_job_tracer_variables
  as select from zos_job_tracer_p
  association to parent zos_i_job_tracer         as _tracer on $projection.TraceUuid = _tracer.TraceUuid
  composition [1..1] of ZOS_I_JOB_TRACER_content as _content
{
  key trace_uuid       as TraceUuid,
  key order_in_trace   as OrderInTrace,
      variable_name    as VariableName,
      variable_content as VariableContent,
      recorded_at      as RecordedAt,

      // Make association public
      _tracer,
      _content
}
