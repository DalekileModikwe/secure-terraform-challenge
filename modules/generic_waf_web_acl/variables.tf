variable "project_name" {
  type        = string
  description = "Project identifier used in WAF resource names."
}

variable "environment_name" {
  type        = string
  description = "Deployment environment name."
}

variable "provider_alias_name" {
  type        = string
  description = "Provider alias or region segment used in WAF resource names."
}

variable "web_acl_descriptor" {
  type        = string
  description = "Descriptor appended to the WAF web ACL name."
}

variable "metric_name_suffix" {
  type        = string
  description = "CloudWatch metric suffix for the WAF ACL and rules."
}

variable "associate_resource_arn" {
  type        = string
  description = "ARN of the regional resource associated with the web ACL."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to WAF resources."
  default     = {}
}
