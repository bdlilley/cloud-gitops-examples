
module "eks_managed_node_group" {
  for_each = var.nodeGroups

  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"

  name = substr("${var.moduleName}-${each.key}", 0, 14)

  cluster_name    = aws_eks_cluster.eks.name
  cluster_version = aws_eks_cluster.eks.version

  subnet_ids = var.cluster.subnetIds

  cluster_primary_security_group_id = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
  vpc_security_group_ids            = concat(var.cluster.securityGroupIds, [each.value.commonClusterSg])

  min_size     = 1
  max_size     = 2
  desired_size = 1

  # remote_access = var.remoteAccess

  instance_types = each.value.instance_types

  iam_role_additional_policies = {
    ssmcore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ssmfull = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
  }

  labels = {
    stackVersion = var.stackVersion
  }
}
