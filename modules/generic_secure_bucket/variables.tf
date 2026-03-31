variable "project_name" {
  type        = string
  description = "Project identifier used in bucket naming."
}

variable "environment_name" {
  type        = string
  description = "Deployment environment name."
}

variable "provider_alias_name" {
  type        = string
  description = "Provider alias or region segment used in the bucket name."
}

variable "bucket_descriptor" {
  type        = string
  description = "Extra descriptor appended to the generated bucket name so globally unique names can remain human-readable."
}

variable "force_destroy" {
  type        = bool
  description = "Whether Terraform may delete non-empty buckets. Keep false for shared or production data buckets."
  default     = false
}

variable "versioning_enabled" {
  type        = bool
  description = "Whether bucket versioning should be enabled."
  default     = true
}

variable "lifecycle_rules" {
  type = list(object({
    id                                 = string
    enabled                            = bool
    transitions                        = list(object({ days = number, storage_class = string }))
    expiration_days                    = optional(number)
    noncurrent_version_expiration_days = optional(number)
  }))
  description = "Lifecycle rules for retention and storage transitions."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the bucket resources."
  default     = {}
}
