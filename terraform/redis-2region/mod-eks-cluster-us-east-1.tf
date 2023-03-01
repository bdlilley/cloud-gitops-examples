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
  providers = {
    aws = aws.us-east-1
  }
}

output "eks-us-east-1" {
  value = module.eks-us-east-1
}

module "eks_managed_node_group-us-east-1" {
  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"

  name = var.stackVersion

  cluster_name    = module.eks-us-east-1.eks.name
  cluster_version = module.eks-us-east-1.eks.version

  subnet_ids = local.vpclocals["us-east-1"].subnetIds

  cluster_primary_security_group_id = module.vpc-us-east-1.commonSecurityGroup.id
  vpc_security_group_ids            = local.vpclocals["us-east-1"].securityGroupIds

  min_size     = 1
  max_size     = 2
  desired_size = 1

  instance_types = ["m5.large"]

  labels = {
    stackVersion = var.stackVersion
  }
  providers = {
    aws = aws.us-east-1
  }
}
