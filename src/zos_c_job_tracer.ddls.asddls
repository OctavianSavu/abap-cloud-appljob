@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption view'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZOS_C_JOB_TRACER
  provider contract transactional_query
  as projection on zos_i_job_tracer
{
  key TraceUuid,
      ClassName,
      JobCatalog,
      JobName,
      JobCount,
      JobStepcount,
      CreatedBy,
      CreatedAt,
      /* Associations */
      _variables : redirected to composition child ZOS_C_JOB_TRACER_VARIABLES
}
