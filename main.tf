##############################################################
#
# Network layer
#
##############################################################

module "solution_network" {
  source = "./modules/solution_network"

  project_name          = var.project_name
  environment_name      = var.environment_name
  provider_alias_name   = local.provider_alias_name
  primary_region        = var.primary_region
  vpc_cidr              = var.vpc_cidr
  availability_zones    = local.azs
  public_subnet_cidrs   = slice(var.public_subnet_cidrs, 0, var.availability_zone_count)
  private_subnet_cidrs  = slice(var.private_subnet_cidrs, 0, var.availability_zone_count)
  isolated_subnet_cidrs = slice(var.isolated_subnet_cidrs, 0, var.availability_zone_count)
  nat_gateway_per_az    = var.nat_gateway_per_az
  tags                  = local.common_tags
}

##############################################################
#
# Storage layer
#
##############################################################

module "solution_storage" {
  source = "./modules/solution_storage"
  providers = {
    aws    = aws
    aws.dr = aws.dr
  }

  project_name                    = var.project_name
  environment_name                = var.environment_name
  provider_alias_name             = local.provider_alias_name
  dr_provider_alias_name          = local.dr_provider_alias
  account_id                      = data.aws_caller_identity.current.account_id
  enable_cross_region_replication = var.enable_cross_region_replication
  tags                            = local.common_tags
}

##############################################################
#
# Compute layer
#
##############################################################

module "solution_compute" {
  source = "./modules/solution_compute"

  project_name                                    = var.project_name
  environment_name                                = var.environment_name
  provider_alias_name                             = local.provider_alias_name
  primary_region                                  = var.primary_region
  account_id                                      = data.aws_caller_identity.current.account_id
  partition                                       = data.aws_partition.current.partition
  private_api_stage_name                          = var.private_api_stage_name
  public_api_stage_name                           = var.public_api_stage_name
  private_api_path                                = local.private_api_path
  public_api_path                                 = local.public_api_path
  private_subnet_ids                              = module.solution_network.private_subnet_ids
  isolated_subnet_ids                             = module.solution_network.isolated_subnet_ids
  private_lambda_security_group_id                = module.solution_network.private_lambda_security_group_id
  isolated_lambda_security_group_id               = module.solution_network.isolated_lambda_security_group_id
  execute_api_vpc_endpoint_id                     = module.solution_network.execute_api_vpc_endpoint_id
  processed_data_bucket_id                        = module.solution_storage.bucket_id
  processed_data_bucket_arn                       = module.solution_storage.bucket_arn
  public_lambda_zip_path                          = data.archive_file.public_lambda.output_path
  public_lambda_source_code_hash                  = data.archive_file.public_lambda.output_base64sha256
  isolated_lambda_zip_path                        = data.archive_file.isolated_lambda.output_path
  isolated_lambda_source_code_hash                = data.archive_file.isolated_lambda.output_base64sha256
  public_lambda_timeout_seconds                   = var.public_lambda_timeout_seconds
  isolated_lambda_timeout_seconds                 = var.isolated_lambda_timeout_seconds
  public_lambda_memory_mb                         = var.public_lambda_memory_mb
  isolated_lambda_memory_mb                       = var.isolated_lambda_memory_mb
  public_lambda_environment_variables             = var.public_lambda_environment_variables
  public_lambda_sensitive_environment_variables   = var.public_lambda_sensitive_environment_variables
  isolated_lambda_environment_variables           = var.isolated_lambda_environment_variables
  isolated_lambda_sensitive_environment_variables = var.isolated_lambda_sensitive_environment_variables
  enable_waf                                      = var.enable_waf
  log_retention_days                              = var.log_retention_days
  tags                                            = local.common_tags
}

##############################################################
#
# Monitoring layer
#
##############################################################

module "solution_monitoring" {
  source = "./modules/solution_monitoring"

  project_name                  = var.project_name
  environment_name              = var.environment_name
  provider_alias_name           = local.provider_alias_name
  public_lambda_function_name   = module.solution_compute.public_lambda_function_name
  isolated_lambda_function_name = module.solution_compute.isolated_lambda_function_name
  public_api_name               = module.solution_compute.public_api_name
  public_api_stage_name         = var.public_api_stage_name
  alarm_topic_arn               = var.alarm_topic_arn
}
