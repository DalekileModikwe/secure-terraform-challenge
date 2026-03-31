output "invoke_url" {
  description = "Base invoke URL for the API stage."
  value       = "https://${aws_api_gateway_rest_api.this.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.this.stage_name}"
}

output "execution_arn" {
  description = "Execution ARN used by resource policies and Lambda permissions."
  value       = aws_api_gateway_rest_api.this.execution_arn
}

output "stage_arn" {
  description = "Stage ARN used by WAF associations."
  value       = aws_api_gateway_stage.this.arn
}

output "api_name" {
  description = "API Gateway name."
  value       = aws_api_gateway_rest_api.this.name
}
