variable "project_name" {
  type        = string
  description = "Project identifier used in monitoring resource names."
}

variable "environment_name" {
  type        = string
  description = "Deployment environment name."
}

variable "provider_alias_name" {
  type        = string
  description = "Provider alias or region segment used in monitoring resource names."
}

variable "public_lambda_function_name" {
  type        = string
  description = "Name of the public broker Lambda function."
}

variable "isolated_lambda_function_name" {
  type        = string
  description = "Name of the isolated Lambda function."
}

variable "public_api_name" {
  type        = string
  description = "Name of the public API Gateway."
}

variable "public_api_stage_name" {
  type        = string
  description = "Stage name of the public API."
}

variable "alarm_topic_arn" {
  type        = string
  description = "Optional SNS topic ARN for alarm notifications."
  default     = null
  nullable    = true
}
