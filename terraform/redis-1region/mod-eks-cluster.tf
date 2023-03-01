locals {
  subnetIds = [for sn in module.us-east-2.privateSubnets : sn.id]
  securityGroupIds = [
    module.us-east-2.commonSecurityGroup.id,
    module.us-east-2.interfaceSecurityGroup.id,
  ]
}

module "eks" {
  source       = "../_submodules/eks-cluster"
  stackVersion = var.stackVersion
  moduleName   = var.moduleName
  tags         = var.tags
  region       = "us-east-2"
  cluster = {
    name             = "redis-tester"
    version          = "1.25"
    securityGroupIds = local.securityGroupIds
    subnetIds        = local.subnetIds
  }
}

output "eks" {
  value = module.eks
}

module "eks_managed_node_group" {
  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"

  name = var.stackVersion

  cluster_name    = module.eks.eks.name
  cluster_version = module.eks.eks.version

  subnet_ids = local.subnetIds

  cluster_primary_security_group_id = module.us-east-2.commonSecurityGroup.id
  vpc_security_group_ids            = local.securityGroupIds

  min_size     = 1
  max_size     = 2
  desired_size = 1

  instance_types = ["m5.large"]

  labels = {
    stackVersion = var.stackVersion
  }
}
