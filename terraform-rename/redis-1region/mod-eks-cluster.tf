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

  argocd = {
    name     = "aoa-${module.eks.eks.name}"
    repo     = "https://github.com/bensolo-io/cloud-gitops-examples.git"
    revision = "main"
    path     = "argocd/argocd-aoa"
    valueFiles = [
      "values-aws-core-infra.yaml",
      "values-redis-tester.yaml"
    ]
  }

  # this should only be used for foundational bootstrapping secrets - we should just
  # use ext-secrets from within an argo install for infrastructure components
  secrets = [
    {
      name      = "redis-config"
      namespace = "default"
      data = {
        token = var.redis_auth
        host  = aws_elasticache_replication_group.redis.primary_endpoint_address
        port  = aws_elasticache_replication_group.redis.port
      }
    }
  ]

  nodeGroups = {
    default = {
      min_size        = 1
      max_size        = 2
      desired_size    = 1
      instance_types  = ["m5.large"]
      commonClusterSg = module.us-east-2.commonSecurityGroup.id
    }
  }
}

output "eks" {
  value = module.eks
}

