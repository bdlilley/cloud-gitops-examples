######################################################################
# VPC submodules

# the two vpcs are created using sub-module for two reasons:
# 1. the module code will not be complicated by for_each loops
#    to create vpc
# 2. terraform doesn't allow vars in provider refs, so the explicit
#    ref must be used here
module "vpc-us-east-1" {
  source           = "../_submodules/vpc"
  vpcConfig        = var.vpcConfigs["us-east-1"]
  stackVersion     = var.stackVersion
  moduleName       = var.moduleName
  tags             = var.tags
  commonVpcConfigs = var.commonVpcConfigs
  region           = "us-east-1"
  providers = {
    # this is why we can't use for_each = var.vpcConfigs
    aws = aws.us-east-1
  }
}

module "vpc-us-east-2" {
  source           = "../_submodules/vpc"
  vpcConfig        = var.vpcConfigs["us-east-2"]
  stackVersion     = var.stackVersion
  moduleName       = var.moduleName
  tags             = var.tags
  commonVpcConfigs = var.commonVpcConfigs
  region           = "us-east-2"
  providers = {
    # this is why we can't use for_each = var.vpcConfigs
    aws = aws.us-east-2
  }
}

output "vpcs" {
  value = {
    "us-east-1" : module.vpc-us-east-1,
    "us-east-2" : module.vpc-us-east-2,
  }
}

######################################################################
# peering - requesting VPC (us-east-2)
resource "aws_vpc_peering_connection" "requester" {
  provider    = aws.us-east-2
  peer_vpc_id = module.vpc-us-east-1.vpc.id
  peer_region = "us-east-1"
  vpc_id      = module.vpc-us-east-2.vpc.id
  auto_accept = false
  tags = {
    Side = "Requester"
  }
}

resource "aws_vpc_peering_connection_options" "requester" {
  provider                  = aws.us-east-2
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

######################################################################
# peering - requesting VPC (us-east-1)
resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = aws.us-east-1
  vpc_peering_connection_id = aws_vpc_peering_connection.requester.id
  auto_accept               = true
  accepter {
    allow_remote_vpc_dns_resolution = true
  }
  tags = {
    Side = "Accepter"
  }
}