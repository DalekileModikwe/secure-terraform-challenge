data "aws_region" "current" {}

module "api_name" {
  source = "../generic_naming"

  project_name         = var.project_name
  resource_type_name   = "aws-api-gateway-rest-api"
  environment_name     = var.environment_name
  provider_alias_name  = var.provider_alias_name
  optional_descriptors = [var.api_descriptor]
}

resource "aws_api_gateway_rest_api" "this" {
  name        = module.api_name.name
  description = var.description
  policy      = var.resource_policy_json

  endpoint_configuration {
    types            = [var.endpoint_type]
    vpc_endpoint_ids = var.endpoint_type == "PRIVATE" ? var.vpc_endpoint_ids : null
  }

  tags = merge(var.tags, { Name = module.api_name.name })
}

resource "aws_api_gateway_resource" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = var.path_part
}

resource "aws_api_gateway_method" "post" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.this.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.this.id
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
}

resource "aws_cloudwatch_log_group" "access_logs" {
  name              = "/aws/apigateway/${module.api_name.name}/${var.stage_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  triggers = {
    redeployment = sha1(jsonencode([aws_api_gateway_resource.this.id, aws_api_gateway_method.post.id, aws_api_gateway_integration.lambda.id, var.resource_policy_json]))
  }
  lifecycle { create_before_destroy = true }
}

resource "aws_api_gateway_stage" "this" {
  rest_api_id          = aws_api_gateway_rest_api.this.id
  deployment_id        = aws_api_gateway_deployment.this.id
  stage_name           = var.stage_name
  xray_tracing_enabled = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.access_logs.arn
    format          = var.access_log_format
  }

  tags = merge(var.tags, { Name = "${module.api_name.name}-${var.stage_name}" })
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}
