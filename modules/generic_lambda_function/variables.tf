variable "project_name" {
  type        = string
  description = "Project identifier used in Lambda resource names."
}

variable "environment_name" {
  type        = string
  description = "Deployment environment name."
}

variable "provider_alias_name" {
  type        = string
  description = "Provider alias or region segment used in Lambda resource names."
}

variable "function_descriptor" {
  type        = string
  description = "Descriptor appended to the generated Lambda function name. Example: public-api, isolated-processor."
}

variable "description" {
  type        = string
  description = "Human-readable Lambda description."
}

variable "filename" {
  type        = string
  description = "Path to the deployment package zip file."
}

variable "source_code_hash" {
  type        = string
  description = "Base64-encoded SHA256 hash of the deployment package."
}

variable "handler" {
  type        = string
  description = "Lambda handler string. Example: app.lambda_handler, public_handler.lambda_handler."
}

variable "runtime" {
  type        = string
  description = "Lambda runtime. Example: python3.12, nodejs22.x."
}

variable "timeout_seconds" {
  type        = number
  description = "Lambda timeout in seconds."
}

variable "memory_size_mb" {
  type        = number
  description = "Lambda memory size in MiB."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets attached to the Lambda VPC configuration."
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security groups attached to the Lambda VPC configuration."
}

variable "environment_variables" {
  type        = map(string)
  description = "Non-sensitive environment variables."
  default     = {}
}

variable "sensitive_environment_variables" {
  type        = map(string)
  description = "Sensitive environment variables. Prefer secret references over raw secret values whenever possible."
  default     = {}
  sensitive   = true
}

variable "managed_policy_arns" {
  type        = list(string)
  description = "Managed IAM policy ARNs attached to the execution role."
  default     = []
}

variable "inline_policies" {
  type = list(object({
    name        = string
    policy_json = string
  }))
  description = "Inline IAM policies attached to the Lambda execution role."
  default     = []
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch Logs retention period."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to Lambda resources."
  default     = {}
}
