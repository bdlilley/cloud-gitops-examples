provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
  # default tags get applied to all resources that accept tags
  default_tags {
    tags = var.tags
  }
}

provider "aws" {
  alias  = "us-east-2"
  region = "us-east-2"
  # default tags get applied to all resources that accept tags
  default_tags {
    tags = var.tags
  }
}