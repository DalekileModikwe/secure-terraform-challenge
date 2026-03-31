variable "project_name" {
  type        = string
  description = "Project identifier used in IAM role naming."
}

variable "environment_name" {
  type        = string
  description = "Deployment environment name."
}

variable "provider_alias_name" {
  type        = string
  description = "Provider alias or region segment used in IAM role naming."
}

variable "role_descriptor" {
  type        = string
  description = "Descriptor appended to the generated IAM role name. Example: public-lambda, replication, private-api."
}

variable "assume_role_policy_json" {
  type        = string
  description = "Assume role policy document in JSON format."
}

variable "managed_policy_arns" {
  type        = list(string)
  description = "Managed IAM policies to attach to the role."
  default     = []
}

variable "inline_policies" {
  type = list(object({
    name        = string
    policy_json = string
  }))
  description = "Inline IAM policies attached to the role."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to IAM role resources."
  default     = {}
}
