terraform {
  backend "s3" {
    bucket = "terraform-artifact.ugumori"
    region = "ap-northeast-1"
    key = "tfstate/dev/core.tfstate"
  }
}
