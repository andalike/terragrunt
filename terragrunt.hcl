locals {
    workspace = read_terragrunt_config(find_in_parent_folders("workspace.hcl"))
    regional_vars = yamldecode(file(find_in_parent_folders("region.yaml")))
    aws_region      = local.regional_vars.region
}

inputs = {
  region = "ap-south-1"
}

generate "provider" {
    path = "provider.tf"
    if_exists = "overwrite_terragrunt"
    contents = <<-EOF

    provider "aws" {
        region = "${local.aws_region}"
        access_key="AKIAVFQXBKORKSSU4JPQ"
        secret_key="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"
    }
    EOF    
}

generate "backend" {
    path = "backend.tf"
    if_exists = "overwrite_terragrunt"
    contents = <<-EOF
    terraform {
        backend "s3" {
            bucket         = "terraformstate17092023"
            key            = "${path_relative_to_include()}/terraform.tfstate"
            region         = "ap-south-1"
            encrypt        = true
            dynamodb_table = "internal-asset-ap-south-1-terraform-state-lock-db-355456865186"
        }
    }
    EOF
}

remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket         = "terraformstate17092023"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "internal-asset-ap-south-1-terraform-state-lock-db-355456865186"
  }
}

