output "bucket_id" {
  description = "Primary processed-data bucket name."
  value       = module.data_bucket.bucket_id
}

output "bucket_arn" {
  description = "Primary processed-data bucket ARN."
  value       = module.data_bucket.bucket_arn
}

output "dr_bucket_id" {
  description = "Disaster recovery bucket name when replication is enabled."
  value       = var.enable_cross_region_replication ? module.dr_data_bucket[0].bucket_id : null
}
