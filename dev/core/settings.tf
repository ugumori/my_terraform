terraform {
  backend "s3" {
    bucket = "terraform-artifact.ugumori"
    region = "ap-northeast-1"
    key = "tfstate/dev/core.tfstate"
  }
}

locals {
  env = "dev"
  region = var.region
  aws_account_id = var.aws_account_id
}
