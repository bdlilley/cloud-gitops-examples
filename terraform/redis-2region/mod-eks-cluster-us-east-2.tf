
module "eks-us-east-2" {
  depends_on = [
    module.vpc-us-east-2,
    aws_vpc_peering_connection_accepter.peer
  ]
  source       = "../_submodules/eks-cluster"
  stackVersion = var.stackVersion
  moduleName   = var.moduleName
  tags         = var.tags
  region       = "us-east-2"
  cluster = {
    name             = "redis-us-east-2"
    version          = "1.25"
    securityGroupIds = local.vpclocals["us-east-2"].securityGroupIds
    subnetIds        = local.vpclocals["us-east-2"].subnetIds
  }
  providers = {
    aws = aws.us-east-2
  }
}

output "eks-us-east-2" {
  value = module.eks-us-east-2
}

module "eks_managed_node_group-us-east-2" {
  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"

  name = var.stackVersion

  cluster_name    = module.eks-us-east-2.eks.name
  cluster_version = module.eks-us-east-2.eks.version

  subnet_ids = local.vpclocals["us-east-2"].subnetIds

  cluster_primary_security_group_id = module.vpc-us-east-2.commonSecurityGroup.id
  vpc_security_group_ids            = local.vpclocals["us-east-2"].securityGroupIds

  min_size     = 1
  max_size     = 2
  desired_size = 1

  instance_types = ["m5.large"]

  labels = {
    stackVersion = var.stackVersion
  }
  providers = {
    aws = aws.us-east-2
  }
}
