@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view on variables'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZOS_C_JOB_TRACER_VARIABLES
  as projection on zos_i_job_tracer_variables
{
  key TraceUuid,
  key OrderInTrace,
      VariableName,
      VariableContent,
      RecordedAt,

      /* Associations */
      _tracer  : redirected to parent ZOS_C_JOB_TRACER,
      _content : redirected to composition child ZOS_C_JOB_TRACER_content
}
