terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # explicit dependency versions prevent breakage from new releases 
      version = "4.52.0"
    }
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}