data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

data "archive_file" "public_lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda-src/public_handler.py"
  output_path = "${path.module}/public-handler.zip"
}

data "archive_file" "isolated_lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda-src/isolated_handler.py"
  output_path = "${path.module}/isolated-handler.zip"
}
