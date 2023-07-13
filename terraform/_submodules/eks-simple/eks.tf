resource "aws_eks_cluster" "eks" {
  name     = "${local.resourcePrefix}-${var.cluster.name}"
  role_arn = aws_iam_role.eks.arn

  version = var.cluster.version
  vpc_config {
    subnet_ids              = var.cluster.subnetIds
    security_group_ids      = var.cluster.securityGroupIds
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster,
    aws_iam_role_policy_attachment.eks-vpc,
    aws_cloudwatch_log_group.eks,
  ]

  enabled_cluster_log_types = ["api", "controllerManager", "scheduler"]
}

output "eks" {
  value = aws_eks_cluster.eks
}

resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${local.resourcePrefix}-${var.cluster.name}/cluster"
  retention_in_days = 7
}