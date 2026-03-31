variable "project_name" {
  type        = string
  description = "Project identifier used in API Gateway resource names."
}

variable "environment_name" {
  type        = string
  description = "Deployment environment name."
}

variable "provider_alias_name" {
  type        = string
  description = "Provider alias or region segment used in API Gateway names."
}

variable "api_descriptor" {
  type        = string
  description = "Descriptor appended to the generated API name. Example: public-api, private-api."
}

variable "description" {
  type        = string
  description = "Human-readable API Gateway description."
}

variable "endpoint_type" {
  type        = string
  description = "API Gateway endpoint type. Valid values: REGIONAL or PRIVATE."

  validation {
    condition     = contains(["REGIONAL", "PRIVATE"], var.endpoint_type)
    error_message = "endpoint_type must be REGIONAL or PRIVATE."
  }
}

variable "path_part" {
  type        = string
  description = "Single resource path segment exposed by the API. Example: ingest, process, internal."
}

variable "stage_name" {
  type        = string
  description = "Stage name exposed by the API."
}

variable "lambda_function_name" {
  type        = string
  description = "Name of the Lambda function integrated with the API."
}

variable "lambda_invoke_arn" {
  type        = string
  description = "Lambda invoke ARN used by the API integration."
}

variable "resource_policy_json" {
  type        = string
  description = "Optional API Gateway resource policy JSON. Use this for private APIs that need explicit source restrictions."
  default     = null
  nullable    = true
}

variable "vpc_endpoint_ids" {
  type        = list(string)
  description = "VPC endpoint IDs associated with a PRIVATE API."
  default     = []
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch Logs retention period for API access logs."
}

variable "access_log_format" {
  type        = string
  description = "JSON access log format used by the stage."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to API resources."
  default     = {}
}
