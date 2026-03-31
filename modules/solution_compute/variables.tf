variable "project_name" {
  type        = string
  description = "Project identifier used in compute resource names."
}

variable "environment_name" {
  type        = string
  description = "Deployment environment name."
}

variable "provider_alias_name" {
  type        = string
  description = "Provider alias or region segment used in compute resource names."
}

variable "primary_region" {
  type        = string
  description = "Primary AWS region used for execute-api policy ARNs."
}

variable "account_id" {
  type        = string
  description = "AWS account ID used in resource policies."
}

variable "partition" {
  type        = string
  description = "AWS partition used in resource policies. Example: aws, aws-us-gov."
}

variable "private_api_stage_name" {
  type        = string
  description = "Stage name for the internal API."
}

variable "public_api_stage_name" {
  type        = string
  description = "Stage name for the public API."
}

variable "private_api_path" {
  type        = string
  description = "Path segment exposed by the private API."
}

variable "public_api_path" {
  type        = string
  description = "Path segment exposed by the public API."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs used by the broker Lambda."
}

variable "isolated_subnet_ids" {
  type        = list(string)
  description = "Isolated subnet IDs used by the sensitive-processing Lambda."
}

variable "private_lambda_security_group_id" {
  type        = string
  description = "Security group ID for the broker Lambda."
}

variable "isolated_lambda_security_group_id" {
  type        = string
  description = "Security group ID for the isolated Lambda."
}

variable "execute_api_vpc_endpoint_id" {
  type        = string
  description = "VPC endpoint ID allowed to invoke the private API."
}

variable "processed_data_bucket_id" {
  type        = string
  description = "S3 bucket name that stores processed data."
}

variable "processed_data_bucket_arn" {
  type        = string
  description = "S3 bucket ARN that stores processed data."
}

variable "public_lambda_zip_path" {
  type        = string
  description = "Path to the zipped public Lambda deployment package."
}

variable "public_lambda_source_code_hash" {
  type        = string
  description = "Source code hash for the public Lambda package."
}

variable "isolated_lambda_zip_path" {
  type        = string
  description = "Path to the zipped isolated Lambda deployment package."
}

variable "isolated_lambda_source_code_hash" {
  type        = string
  description = "Source code hash for the isolated Lambda package."
}

variable "public_lambda_timeout_seconds" {
  type        = number
  description = "Timeout for the public Lambda."
}

variable "isolated_lambda_timeout_seconds" {
  type        = number
  description = "Timeout for the isolated Lambda."
}

variable "public_lambda_memory_mb" {
  type        = number
  description = "Memory size for the public Lambda."
}

variable "isolated_lambda_memory_mb" {
  type        = number
  description = "Memory size for the isolated Lambda."
}

variable "public_lambda_environment_variables" {
  type        = map(string)
  description = "Non-sensitive environment variables for the public Lambda."
  default     = {}
}

variable "public_lambda_sensitive_environment_variables" {
  type        = map(string)
  description = "Sensitive environment variables for the public Lambda."
  default     = {}
  sensitive   = true
}

variable "isolated_lambda_environment_variables" {
  type        = map(string)
  description = "Non-sensitive environment variables for the isolated Lambda."
  default     = {}
}

variable "isolated_lambda_sensitive_environment_variables" {
  type        = map(string)
  description = "Sensitive environment variables for the isolated Lambda."
  default     = {}
  sensitive   = true
}

variable "enable_waf" {
  type        = bool
  description = "Whether to attach a WAF ACL to the public API."
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch Logs retention period."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to compute resources."
  default     = {}
}
