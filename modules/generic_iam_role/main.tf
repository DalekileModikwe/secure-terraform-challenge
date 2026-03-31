resource "aws_iam_role" "this" {
  name               = "${var.project_name}-aws-iam-role-${var.environment_name}-${var.provider_alias_name}-${var.role_descriptor}"
  assume_role_policy = var.assume_role_policy_json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each   = toset(var.managed_policy_arns)
  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "inline" {
  for_each = { for policy in var.inline_policies : policy.name => policy }
  name     = each.value.name
  role     = aws_iam_role.this.id
  policy   = each.value.policy_json
}
