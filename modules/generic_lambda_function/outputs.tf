output "function_name" {
  description = "Lambda function name."
  value       = aws_lambda_function.this.function_name
}

output "invoke_arn" {
  description = "Lambda invoke ARN."
  value       = aws_lambda_function.this.invoke_arn
}

output "role_arn" {
  description = "Execution role ARN."
  value       = module.execution_role.role_arn
}
