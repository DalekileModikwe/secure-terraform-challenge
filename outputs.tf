output "public_api_url" {
  description = "Invoke URL for the customer-facing API resource."
  value       = module.solution_compute.public_api_url
}

output "private_api_url" {
  description = "Invoke URL for the private API resource. Reachability still depends on the execute-api VPC endpoint and private subnets."
  value       = module.solution_compute.private_api_url
}

output "processed_data_bucket_name" {
  description = "Primary S3 bucket that stores processed sensitive payloads."
  value       = module.solution_storage.bucket_id
}

output "dr_processed_data_bucket_name" {
  description = "Secondary-region S3 bucket that receives replicated objects when disaster recovery replication is enabled."
  value       = module.solution_storage.dr_bucket_id
}

output "vpc_id" {
  description = "ID of the workload VPC."
  value       = module.solution_network.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs used by the broker Lambda."
  value       = module.solution_network.private_subnet_ids
}

output "isolated_subnet_ids" {
  description = "Isolated subnet IDs used by the sensitive-processing Lambda."
  value       = module.solution_network.isolated_subnet_ids
}
