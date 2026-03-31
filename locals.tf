locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.availability_zone_count)

  common_tags = merge(
    {
      environment = var.environment_name
      project     = var.project_name
      workload    = "microservices-platform"
    },
    var.tags
  )

  provider_alias_name = replace(data.aws_region.current.name, "/[^a-z0-9-]/", "-")
  dr_provider_alias   = replace(var.dr_region, "/[^a-z0-9-]/", "-")

  public_api_path  = "ingest"
  private_api_path = "process"
}
