locals {
  region      = "us-east-1"
  environment = "stage"
  s3_bucket   = "tf-profound-stag-state"
}

remote_state {
  backend = "s3"

  config = {
    bucket       = "${local.s3_bucket}"
    key          = "${path_relative_to_include()}/terraform.tfstate"
    region       = "${local.region}"
    encrypt      = true
    use_lockfile = true
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "provider" {
  path      = "providers.tf"
  if_exists = "overwrite"

  contents = <<-EOT
    provider "aws" {
      region = "${local.region}"

      default_tags {
        tags = {
          Maintainer = "Ruben Ricaurte: ricaurtef@gmail.com."
          ManagedBy  = "Terraform."
        }
      }
    }
  EOT
}
