terraform {
  required_version = "1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.2.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  default = "ap-northeast-1"
}

variable "aws_account_id" {
  type = string
}

