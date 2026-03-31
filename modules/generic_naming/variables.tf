variable "project_name" {
  type        = string
  description = "Project identifier used at the start of the generated resource name."
}

variable "resource_type_name" {
  type        = string
  description = "Resource type segment. Example: aws-lambda-function, aws-api-gateway-rest-api, aws-s3-bucket."
}

variable "environment_name" {
  type        = string
  description = "Deployment environment segment. Example: dev, test, beta, prod."
}

variable "provider_alias_name" {
  type        = string
  description = "Provider alias or region segment. Example: primary, dr, af-south-1, us-east-1."
  default     = null
}

variable "optional_descriptors" {
  type        = list(string)
  description = "Additional descriptors appended after the environment and provider alias. Example: [\"public-api\"], [\"isolated\", \"processor\"]."
  default     = []
}

variable "index" {
  type        = string
  description = "Optional final index or sequence marker. Example: 1, a, 3."
  default     = null
}
