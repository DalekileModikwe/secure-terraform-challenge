data "aws_partition" "current" {}

module "function_name" {
  source = "../generic_naming"

  project_name         = var.project_name
  resource_type_name   = "aws-lambda-function"
  environment_name     = var.environment_name
  provider_alias_name  = var.provider_alias_name
  optional_descriptors = [var.function_descriptor]
}

module "execution_role" {
  source = "../generic_iam_role"

  project_name        = var.project_name
  environment_name    = var.environment_name
  provider_alias_name = var.provider_alias_name
  role_descriptor     = var.function_descriptor
  assume_role_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
  managed_policy_arns = concat(
    ["arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"],
    var.managed_policy_arns
  )
  inline_policies = var.inline_policies
  tags            = var.tags
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${module.function_name.name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_lambda_function" "this" {
  function_name    = module.function_name.name
  description      = var.description
  filename         = var.filename
  source_code_hash = var.source_code_hash
  role             = module.execution_role.role_arn
  handler          = var.handler
  runtime          = var.runtime
  timeout          = var.timeout_seconds
  memory_size      = var.memory_size_mb

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  environment {
    variables = merge(var.environment_variables, nonsensitive(var.sensitive_environment_variables))
  }

  tracing_config { mode = "Active" }
  tags = merge(var.tags, { Name = module.function_name.name })

  depends_on = [aws_cloudwatch_log_group.this]
}
