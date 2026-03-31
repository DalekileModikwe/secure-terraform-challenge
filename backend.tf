terraform {
  # Keep the backend block intentionally partial so each workload account can
  # supply its own state bucket, lock table, and key prefix without editing code.
  backend "s3" {}
}
