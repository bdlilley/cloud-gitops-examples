module "eks-us-east-1" {
  depends_on = [
    module.vpc-us-east-1,
    aws_vpc_peering_connection_accepter.peer
  ]
  source       = "../_submodules/eks-cluster"
  stackVersion = var.stackVersion
  moduleName   = var.moduleName
  tags         = var.tags
  region       = "us-east-1"
  cluster = {
    name             = "redis-us-east-1"
    version          = "1.25"
    securityGroupIds = local.vpclocals["us-east-1"].securityGroupIds
    subnetIds        = local.vpclocals["us-east-1"].subnetIds
  }

  argocd = {
    name     = "aoa-${module.eks.eks.name}"
    repo     = "https://github.com/bensolo-io/cloud-gitops-examples.git"
    revision = "main"
    path     = "argocd/argocd-aoa"
    valueFiles = [
      "values-aws-core-infra.yaml"
    ]
  }

  nodeGroups = {
    default = {
      min_size        = 1
      max_size        = 2
      desired_size    = 1
      instance_types  = ["m5.large"]
      commonClusterSg = module.us-east-2.commonSecurityGroup.id
    }
  }

  providers = {
    aws = aws.us-east-1
  }
}

output "eks-us-east-1" {
  value = module.eks-us-east-1
}
