data "aws_iam_policy_document" "private_api_resource_policy" {
  statement {
    sid = "AllowInvokeFromApprovedVpcEndpoint"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["execute-api:Invoke"]
    resources = ["arn:${var.partition}:execute-api:${var.primary_region}:${var.account_id}:*/*"]
  }

  statement {
    sid    = "DenyInvokeOutsideApprovedVpcEndpoint"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["execute-api:Invoke"]
    resources = ["arn:${var.partition}:execute-api:${var.primary_region}:${var.account_id}:*/*"]
    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpce"
      values   = [var.execute_api_vpc_endpoint_id]
    }
  }
}

module "isolated_lambda" {
  source = "../generic_lambda_function"

  project_name        = var.project_name
  environment_name    = var.environment_name
  provider_alias_name = var.provider_alias_name
  function_descriptor = "isolated-processor"
  description         = "Processes sensitive payloads inside isolated subnets and persists the sanitized result to S3."
  filename            = var.isolated_lambda_zip_path
  source_code_hash    = var.isolated_lambda_source_code_hash
  handler             = "isolated_handler.lambda_handler"
  runtime             = "python3.12"
  timeout_seconds     = var.isolated_lambda_timeout_seconds
  memory_size_mb      = var.isolated_lambda_memory_mb
  subnet_ids          = var.isolated_subnet_ids
  security_group_ids  = [var.isolated_lambda_security_group_id]
  environment_variables = merge(
    {
      LOG_LEVEL    = "INFO"
      BUCKET_NAME  = var.processed_data_bucket_id
      SERVICE_NAME = "${var.project_name}-${var.environment_name}-isolated-processor"
    },
    var.isolated_lambda_environment_variables
  )
  sensitive_environment_variables = var.isolated_lambda_sensitive_environment_variables
  log_retention_days              = var.log_retention_days
  inline_policies = [{
    name = "write-processed-data"
    policy_json = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:PutObjectAcl", "s3:PutObjectTagging"]
        Resource = "${var.processed_data_bucket_arn}/*"
      }]
    })
  }]
  tags = var.tags
}

module "private_api" {
  source = "../generic_api_gateway_rest_lambda"

  project_name         = var.project_name
  environment_name     = var.environment_name
  provider_alias_name  = var.provider_alias_name
  api_descriptor       = "private-api"
  description          = "Internal API Gateway entry point for the isolated Lambda tier."
  endpoint_type        = "PRIVATE"
  path_part            = var.private_api_path
  stage_name           = var.private_api_stage_name
  lambda_function_name = module.isolated_lambda.function_name
  lambda_invoke_arn    = module.isolated_lambda.invoke_arn
  resource_policy_json = data.aws_iam_policy_document.private_api_resource_policy.json
  vpc_endpoint_ids     = [var.execute_api_vpc_endpoint_id]
  log_retention_days   = var.log_retention_days
  access_log_format = jsonencode({
    requestId      = "$context.requestId"
    ip             = "$context.identity.sourceIp"
    requestTime    = "$context.requestTime"
    httpMethod     = "$context.httpMethod"
    routeKey       = "$context.resourcePath"
    status         = "$context.status"
    responseLength = "$context.responseLength"
  })
  tags = var.tags
}

module "public_lambda" {
  source = "../generic_lambda_function"

  project_name        = var.project_name
  environment_name    = var.environment_name
  provider_alias_name = var.provider_alias_name
  function_descriptor = "private-tier-broker"
  description         = "Accepts public API requests, performs coarse validation, and relays only approved data to the isolated private API."
  filename            = var.public_lambda_zip_path
  source_code_hash    = var.public_lambda_source_code_hash
  handler             = "public_handler.lambda_handler"
  runtime             = "python3.12"
  timeout_seconds     = var.public_lambda_timeout_seconds
  memory_size_mb      = var.public_lambda_memory_mb
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [var.private_lambda_security_group_id]
  environment_variables = merge(
    {
      LOG_LEVEL       = "INFO"
      PRIVATE_API_URL = "${module.private_api.invoke_url}/${var.private_api_path}"
    },
    var.public_lambda_environment_variables
  )
  sensitive_environment_variables = var.public_lambda_sensitive_environment_variables
  log_retention_days              = var.log_retention_days
  tags                            = var.tags
}

module "public_api" {
  source = "../generic_api_gateway_rest_lambda"

  project_name         = var.project_name
  environment_name     = var.environment_name
  provider_alias_name  = var.provider_alias_name
  api_descriptor       = "public-api"
  description          = "Regional API Gateway entry point exposed to clients and protected by WAF."
  endpoint_type        = "REGIONAL"
  path_part            = var.public_api_path
  stage_name           = var.public_api_stage_name
  lambda_function_name = module.public_lambda.function_name
  lambda_invoke_arn    = module.public_lambda.invoke_arn
  log_retention_days   = var.log_retention_days
  access_log_format = jsonencode({
    requestId      = "$context.requestId"
    ip             = "$context.identity.sourceIp"
    requestTime    = "$context.requestTime"
    httpMethod     = "$context.httpMethod"
    routeKey       = "$context.resourcePath"
    status         = "$context.status"
    responseLength = "$context.responseLength"
    wafResponse    = "$context.wafResponseCode"
  })
  tags = var.tags
}

module "public_api_waf" {
  count  = var.enable_waf ? 1 : 0
  source = "../generic_waf_web_acl"

  project_name           = var.project_name
  environment_name       = var.environment_name
  provider_alias_name    = var.provider_alias_name
  web_acl_descriptor     = "public-api"
  metric_name_suffix     = "public-api"
  associate_resource_arn = module.public_api.stage_arn
  tags                   = var.tags
}
