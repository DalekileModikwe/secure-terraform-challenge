module "data_bucket" {
  source = "../generic_secure_bucket"

  project_name        = var.project_name
  environment_name    = var.environment_name
  provider_alias_name = var.provider_alias_name
  bucket_descriptor   = "processed-data-${var.account_id}"
  force_destroy       = false
  versioning_enabled  = true
  lifecycle_rules = [{
    id                                 = "retain-90-days"
    enabled                            = true
    transitions                        = []
    expiration_days                    = null
    noncurrent_version_expiration_days = 90
  }]
  tags = var.tags
}

module "dr_data_bucket" {
  count = var.enable_cross_region_replication ? 1 : 0

  source    = "../generic_secure_bucket"
  providers = { aws = aws.dr }

  project_name        = var.project_name
  environment_name    = var.environment_name
  provider_alias_name = var.dr_provider_alias_name
  bucket_descriptor   = "processed-data-dr-${var.account_id}"
  force_destroy       = false
  versioning_enabled  = true
  lifecycle_rules = [{
    id                                 = "retain-365-days"
    enabled                            = true
    transitions                        = []
    expiration_days                    = null
    noncurrent_version_expiration_days = 365
  }]
  tags = var.tags
}

data "aws_iam_policy_document" "s3_replication_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

module "replication_role" {
  count  = var.enable_cross_region_replication ? 1 : 0
  source = "../generic_iam_role"

  project_name            = var.project_name
  environment_name        = var.environment_name
  provider_alias_name     = var.provider_alias_name
  role_descriptor         = "s3-replication"
  assume_role_policy_json = data.aws_iam_policy_document.s3_replication_assume_role.json
  inline_policies = [{
    name = "s3-replication"
    policy_json = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["s3:GetReplicationConfiguration", "s3:ListBucket"]
          Effect   = "Allow"
          Resource = module.data_bucket.bucket_arn
        },
        {
          Action   = ["s3:GetObjectVersionForReplication", "s3:GetObjectVersionAcl", "s3:GetObjectVersionTagging"]
          Effect   = "Allow"
          Resource = "${module.data_bucket.bucket_arn}/*"
        },
        {
          Action   = ["s3:ReplicateObject", "s3:ReplicateDelete", "s3:ReplicateTags", "s3:ObjectOwnerOverrideToBucketOwner"]
          Effect   = "Allow"
          Resource = "${module.dr_data_bucket[0].bucket_arn}/*"
        }
      ]
    })
  }]
  tags = var.tags
}

resource "aws_s3_bucket_replication_configuration" "data_bucket" {
  count  = var.enable_cross_region_replication ? 1 : 0
  bucket = module.data_bucket.bucket_id
  role   = module.replication_role[0].role_arn

  rule {
    id     = "replicate-all-processed-data"
    status = "Enabled"
    filter {}
    destination {
      bucket        = module.dr_data_bucket[0].bucket_arn
      storage_class = "STANDARD"
    }
  }

  depends_on = [module.data_bucket, module.dr_data_bucket]
}
