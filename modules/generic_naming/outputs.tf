output "name" {
  description = "Resource name that follows the required project-resource-environment-provider-descriptor-index convention."
  value       = join("-", local.normalized_segments)
}
