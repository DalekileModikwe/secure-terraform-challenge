# These alarms stay in a dedicated solution module so the root file can express
# "monitor this solution" without carrying the metric dimensions inline.
resource "aws_cloudwatch_metric_alarm" "public_lambda_errors" {
  alarm_name          = "${var.project_name}-aws-cloudwatch-alarm-${var.environment_name}-${var.provider_alias_name}-public-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alert when the public broker Lambda records any errors."
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_topic_arn == null ? [] : [var.alarm_topic_arn]
  ok_actions          = var.alarm_topic_arn == null ? [] : [var.alarm_topic_arn]

  dimensions = { FunctionName = var.public_lambda_function_name }
}

resource "aws_cloudwatch_metric_alarm" "isolated_lambda_errors" {
  alarm_name          = "${var.project_name}-aws-cloudwatch-alarm-${var.environment_name}-${var.provider_alias_name}-isolated-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alert when the isolated sensitive-processing Lambda records any errors."
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_topic_arn == null ? [] : [var.alarm_topic_arn]
  ok_actions          = var.alarm_topic_arn == null ? [] : [var.alarm_topic_arn]

  dimensions = { FunctionName = var.isolated_lambda_function_name }
}

resource "aws_cloudwatch_metric_alarm" "public_api_5xx" {
  alarm_name          = "${var.project_name}-aws-cloudwatch-alarm-${var.environment_name}-${var.provider_alias_name}-public-api-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alert when the public API begins returning 5XX errors."
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_topic_arn == null ? [] : [var.alarm_topic_arn]
  ok_actions          = var.alarm_topic_arn == null ? [] : [var.alarm_topic_arn]

  dimensions = {
    ApiName = var.public_api_name
    Stage   = var.public_api_stage_name
  }
}
