output "public_api_url" {
  description = "Invoke URL for the customer-facing API resource."
  value       = "${module.public_api.invoke_url}/${var.public_api_path}"
}

output "private_api_url" {
  description = "Invoke URL for the private API resource."
  value       = "${module.private_api.invoke_url}/${var.private_api_path}"
}

output "public_lambda_function_name" {
  description = "Name of the broker Lambda."
  value       = module.public_lambda.function_name
}

output "isolated_lambda_function_name" {
  description = "Name of the isolated Lambda."
  value       = module.isolated_lambda.function_name
}

output "public_api_name" {
  description = "Name of the public API Gateway."
  value       = module.public_api.api_name
}
