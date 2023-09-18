include {
    path = find_in_parent_folders()
}

terraform {
    source="git::https://github.com/andalike/terrascan.git//terraform-aws-vpc?ref=main"
}

locals {
  regional_vars             = yamldecode(file(find_in_parent_folders("region.yaml")))
}

inputs = {
  name = "my-vpc1"
  cidr = "10.0.0.0/18"

  azs             = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}