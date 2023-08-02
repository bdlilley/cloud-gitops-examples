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
    name             = "cluster"
    version          = "1.25"
    securityGroupIds = local.securityGroupIds
    subnetIds        = local.subnetIds
  }

  nodeGroups = {
    default = {
      min_size        = 1
      max_size        = 2
      desired_size    = 1
      instance_types  = ["m5.2xlarge"]
      commonClusterSg = module.us-east-2.commonSecurityGroup.id
    }
  }
}

output "eks" {
  value = module.eks
}
