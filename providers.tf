provider "aws" {
  region = var.primary_region

  default_tags {
    tags = local.common_tags
  }
}

provider "aws" {
  alias  = "dr"
  region = var.dr_region

  default_tags {
    tags = merge(
      local.common_tags,
      {
        disaster_recovery_region = var.dr_region
      }
    )
  }
}
