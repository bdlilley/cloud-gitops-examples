terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # explicit dependency versions prevent breakage from new releases 
      version = "4.52.0"
    }
  }
  backend "s3" {
    # bucket and key get set from wrapper script b/c tf doesn't support vars here
    bucket = "_"
    key    = "_"
    region = "us-east-2"
  }

}

# this is the default provider for all modules; multi-region modules have aliased providers
# for different regions
provider "aws" {
  region = "us-east-2"
  # default tags get applied to all resources that accept tags
  default_tags {
    tags = var.tags
  }
}