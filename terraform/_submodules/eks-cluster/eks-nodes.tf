
module "eks_managed_node_group" {
  for_each = var.nodeGroups

  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"

  name = "${var.stackVersion}-${each.key}"

  cluster_name    = aws_eks_cluster.eks.name
  cluster_version = aws_eks_cluster.eks.version

  subnet_ids = var.cluster.subnetIds

  cluster_primary_security_group_id = each.value.commonClusterSg
  vpc_security_group_ids            = var.cluster.securityGroupIds

  min_size     = 1
  max_size     = 2
  desired_size = 1

  instance_types = each.value.instance_types

  labels = {
    stackVersion = var.stackVersion
  }
}
