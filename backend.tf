# Partial config: bucket, key, endpoint and credentials come from backend.hcl
#   terraform init -backend-config=backend.hcl
terraform {
  backend "s3" {
    use_path_style              = true
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
    use_lockfile                = true
  }
}
