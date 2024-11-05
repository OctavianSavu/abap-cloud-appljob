@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Job tracer entries'
@Metadata.ignorePropagatedAnnotations: true
define root view entity zos_i_job_tracer
  as select from zos_job_tracer_h
  composition [1..*] of zos_i_job_tracer_variables as _variables 
{
  key trace_uuid    as TraceUuid,
      class_name    as ClassName,
      job_catalog   as JobCatalog,
      job_name      as JobName,
      job_count     as JobCount,
      job_stepcount as JobStepcount,
      created_by    as CreatedBy,
      created_at    as CreatedAt,

      _variables
}
