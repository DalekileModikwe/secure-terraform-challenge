variable "project_name" {
  type        = string
  description = "Project identifier used in resource names."
}

variable "environment_name" {
  type        = string
  description = "Deployment environment name. Example: dev, test, beta, prod."
}

variable "provider_alias_name" {
  type        = string
  description = "Provider alias or region segment used in resource names."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block assigned to the VPC."
}

variable "availability_zones" {
  type        = list(string)
  description = "Ordered list of Availability Zones used to place subnets."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets with NAT egress."
}

variable "isolated_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for isolated subnets with no default internet route."
}

variable "nat_gateway_per_az" {
  type        = bool
  description = "Whether to create one NAT gateway per Availability Zone."
}

variable "enable_dns_support" {
  type        = bool
  description = "Whether the VPC should support DNS resolution."
  default     = true
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Whether the VPC should assign public DNS hostnames where relevant."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to VPC resources."
  default     = {}
}
