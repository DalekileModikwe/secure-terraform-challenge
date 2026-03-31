output "vpc_id" {
  description = "ID of the workload VPC."
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = module.vpc.private_subnet_ids
}

output "isolated_subnet_ids" {
  description = "Isolated subnet IDs."
  value       = module.vpc.isolated_subnet_ids
}

output "private_route_table_ids" {
  description = "Private route table IDs."
  value       = module.vpc.private_route_table_ids
}

output "isolated_route_table_ids" {
  description = "Isolated route table IDs."
  value       = module.vpc.isolated_route_table_ids
}

output "private_lambda_security_group_id" {
  description = "Security group for the private broker Lambda."
  value       = aws_security_group.private_lambda.id
}

output "isolated_lambda_security_group_id" {
  description = "Security group for the isolated Lambda."
  value       = aws_security_group.isolated_lambda.id
}

output "execute_api_vpc_endpoint_id" {
  description = "Interface VPC endpoint ID for execute-api."
  value       = aws_vpc_endpoint.execute_api.id
}
