variable "project_name" {
  type        = string
  description = "Project identifier used in storage resource names."
}

variable "environment_name" {
  type        = string
  description = "Deployment environment name."
}

variable "provider_alias_name" {
  type        = string
  description = "Provider alias or region segment used in storage resource names."
}

variable "dr_provider_alias_name" {
  type        = string
  description = "Provider alias or region segment used for disaster recovery storage names."
}

variable "account_id" {
  type        = string
  description = "AWS account ID used to help produce globally unique bucket names."
}

variable "enable_cross_region_replication" {
  type        = bool
  description = "Whether to create a second-region bucket and enable replication."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to storage resources."
  default     = {}
}
