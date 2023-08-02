module "vpc-us-east-1" {
  source = "../../terraform-modules/vpc-simple"
  # source           = "git::https://github.com/bdlilley/cloud-gitops-examples.git//terraform-modules/vpc-simple?ref=main"
  vpcConfig        = var.vpcConfigs["us-east-1"]
  resourcePrefix   = var.resourcePrefix
  tags             = var.tags
  commonVpcConfigs = var.commonVpcConfigs
  region           = "us-east-1"
}

resource "aws_security_group" "common-us-east-1" {
  name        = "${var.resourcePrefix}-common"
  description = "common sg"
  vpc_id      = module.vpc-us-east-1.vpc.id

  ingress {
    description = "all from vpc"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.vpc-us-east-1.vpc.cidr_block]
  }

  egress {
    description = "all to vpc"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.vpc-us-east-1.vpc.cidr_block]
  }

  egress {
    description = "https to internet"
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.resourcePrefix}-common"
  }
}