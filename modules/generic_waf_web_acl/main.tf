module "web_acl_name" {
  source = "../generic_naming"

  project_name         = var.project_name
  resource_type_name   = "aws-wafv2-web-acl"
  environment_name     = var.environment_name
  provider_alias_name  = var.provider_alias_name
  optional_descriptors = [var.web_acl_descriptor]
}

resource "aws_wafv2_web_acl" "this" {
  name        = module.web_acl_name.name
  description = "Managed-rule WAF baseline for the public API."
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.metric_name_suffix}-acl"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "aws-managed-common"
    priority = 1
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.metric_name_suffix}-common"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "aws-managed-known-bad-inputs"
    priority = 2
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.metric_name_suffix}-bad-inputs"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "aws-managed-ip-reputation"
    priority = 3
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.metric_name_suffix}-ip-reputation"
      sampled_requests_enabled   = true
    }
  }

  tags = merge(var.tags, { Name = module.web_acl_name.name })
}

resource "aws_wafv2_web_acl_association" "this" {
  resource_arn = var.associate_resource_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}
