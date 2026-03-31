variable "project_name" {
  type        = string
  description = "Project identifier used as the first segment in resource names. Example: terraform-demo, payments-platform, customer-api."
  default     = "terraform-demo"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,30}$", var.project_name))
    error_message = "project_name must be 3-30 characters, lowercase, and use letters, numbers, or hyphens."
  }
}

variable "environment_name" {
  type        = string
  description = "Deployment environment name. Examples: dev, test, beta, prod."
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "beta", "prod"], var.environment_name)
    error_message = "environment_name must be one of: dev, test, beta, prod."
  }
}

variable "primary_region" {
  type        = string
  description = "Primary AWS region that hosts the workload account deployment. Example: af-south-1, eu-west-1, us-east-1."
  default     = "af-south-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-\\d$", var.primary_region))
    error_message = "primary_region must look like a valid AWS region name such as af-south-1 or us-east-1."
  }
}

variable "dr_region" {
  type        = string
  description = "Secondary AWS region reserved for backup copies and disaster recovery assets. Example: eu-west-1, eu-central-1, us-west-2."
  default     = "eu-west-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-\\d$", var.dr_region)) && var.dr_region != var.primary_region
    error_message = "dr_region must be a valid AWS region name and must differ from primary_region."
  }
}

variable "availability_zone_count" {
  type        = number
  description = "Number of Availability Zones to use for the VPC. Typical values: 2 for cost-aware environments, 3 for larger production footprints."
  default     = 2

  validation {
    condition     = var.availability_zone_count >= 2 && var.availability_zone_count <= 3
    error_message = "availability_zone_count must be between 2 and 3."
  }
}

variable "vpc_cidr" {
  type        = string
  description = "Primary CIDR block for the workload VPC. Example: 10.42.0.0/16."
  default     = "10.42.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets that host only shared edge components such as NAT gateways. Provide one entry per Availability Zone. Example: [\"10.42.0.0/24\", \"10.42.1.0/24\"]."
  default     = ["10.42.0.0/24", "10.42.1.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) >= 2 && alltrue([for cidr in var.public_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "public_subnet_cidrs must contain at least two valid IPv4 CIDR blocks."
  }
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets that allow controlled internet egress via NAT. Provide one entry per Availability Zone. Example: [\"10.42.10.0/24\", \"10.42.11.0/24\"]."
  default     = ["10.42.10.0/24", "10.42.11.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) >= 2 && alltrue([for cidr in var.private_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "private_subnet_cidrs must contain at least two valid IPv4 CIDR blocks."
  }
}

variable "isolated_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for isolated subnets with no default route to the internet. Provide one entry per Availability Zone. Example: [\"10.42.20.0/24\", \"10.42.21.0/24\"]."
  default     = ["10.42.20.0/24", "10.42.21.0/24"]

  validation {
    condition     = length(var.isolated_subnet_cidrs) >= 2 && alltrue([for cidr in var.isolated_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "isolated_subnet_cidrs must contain at least two valid IPv4 CIDR blocks."
  }
}

variable "nat_gateway_per_az" {
  type        = bool
  description = "Whether to create one NAT gateway per Availability Zone. false reduces cost, true improves zonal resilience for egress-dependent workloads."
  default     = false
}

variable "public_api_stage_name" {
  type        = string
  description = "Stage name for the customer-facing API Gateway stage. Example: v1, live, prod."
  default     = "v1"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{2,20}$", var.public_api_stage_name))
    error_message = "public_api_stage_name must be 2-20 characters and use letters, numbers, underscores, or hyphens."
  }
}

variable "private_api_stage_name" {
  type        = string
  description = "Stage name for the internal API Gateway stage that fronts the isolated Lambda. Example: internal, svc, private."
  default     = "internal"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{2,20}$", var.private_api_stage_name))
    error_message = "private_api_stage_name must be 2-20 characters and use letters, numbers, underscores, or hyphens."
  }
}

variable "log_retention_days" {
  type        = number
  description = "Retention period for application and API access logs in CloudWatch Logs. Common values: 90, 180, 365."
  default     = 90

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.log_retention_days)
    error_message = "log_retention_days must be one of the supported CloudWatch Logs retention values."
  }
}

variable "public_lambda_timeout_seconds" {
  type        = number
  description = "Timeout for the public Lambda function that brokers requests into the private tier. Typical values: 10-30 seconds."
  default     = 15

  validation {
    condition     = var.public_lambda_timeout_seconds >= 3 && var.public_lambda_timeout_seconds <= 900
    error_message = "public_lambda_timeout_seconds must be between 3 and 900."
  }
}

variable "isolated_lambda_timeout_seconds" {
  type        = number
  description = "Timeout for the isolated Lambda function that handles sensitive processing and S3 writes. Typical values: 10-60 seconds."
  default     = 30

  validation {
    condition     = var.isolated_lambda_timeout_seconds >= 3 && var.isolated_lambda_timeout_seconds <= 900
    error_message = "isolated_lambda_timeout_seconds must be between 3 and 900."
  }
}

variable "public_lambda_memory_mb" {
  type        = number
  description = "Memory allocation for the public Lambda function in MiB. Common values: 256, 512, 1024."
  default     = 256

  validation {
    condition     = var.public_lambda_memory_mb >= 128 && var.public_lambda_memory_mb <= 10240
    error_message = "public_lambda_memory_mb must be between 128 and 10240."
  }
}

variable "isolated_lambda_memory_mb" {
  type        = number
  description = "Memory allocation for the isolated Lambda function in MiB. Common values: 256, 512, 1024."
  default     = 512

  validation {
    condition     = var.isolated_lambda_memory_mb >= 128 && var.isolated_lambda_memory_mb <= 10240
    error_message = "isolated_lambda_memory_mb must be between 128 and 10240."
  }
}

variable "enable_waf" {
  type        = bool
  description = "Whether to attach an AWS WAF web ACL to the public API Gateway stage."
  default     = true
}

variable "enable_cross_region_replication" {
  type        = bool
  description = "Whether to create a disaster recovery S3 bucket in the secondary region and replicate processed objects to it."
  default     = true
}

variable "alarm_topic_arn" {
  type        = string
  description = "Optional SNS topic ARN for operational alarms. Leave null when the environment has not wired an on-call notification topic yet."
  default     = null
  nullable    = true

  validation {
    condition     = var.alarm_topic_arn == null || can(regex("^arn:aws[a-z-]*:sns:[a-z0-9-]+:\\d{12}:.+$", var.alarm_topic_arn))
    error_message = "alarm_topic_arn must be null or a valid SNS topic ARN."
  }
}

variable "tags" {
  type        = map(string)
  description = "Additional tags merged into every resource. Example keys: owner, cost-center, data-classification."
  default = {
    managed-by = "terraform"
    repository = "terraform-demo"
  }
}

variable "public_lambda_environment_variables" {
  type        = map(string)
  description = "Non-sensitive environment variables merged into the public Lambda configuration."
  default     = {}
}

variable "public_lambda_sensitive_environment_variables" {
  type        = map(string)
  description = "Sensitive environment variables for the public Lambda function. Prefer Secrets Manager references when possible, but this input is available for unavoidable bootstrap cases."
  default     = {}
  sensitive   = true
}

variable "isolated_lambda_environment_variables" {
  type        = map(string)
  description = "Non-sensitive environment variables merged into the isolated Lambda configuration."
  default     = {}
}

variable "isolated_lambda_sensitive_environment_variables" {
  type        = map(string)
  description = "Sensitive environment variables for the isolated Lambda function. Prefer Secrets Manager references when possible, but this input is available for unavoidable bootstrap cases."
  default     = {}
  sensitive   = true
}
