@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view on variables'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZOS_C_JOB_TRACER_content
  as projection on ZOS_I_JOB_TRACER_content
{
  key TraceUuid,
  key OrderInTrace,
      VariableName,
      VariableContent,

      /* Associations */
      _variable : redirected to parent ZOS_C_JOB_TRACER_VARIABLES,
      _tracer : redirected to ZOS_C_JOB_TRACER
}
