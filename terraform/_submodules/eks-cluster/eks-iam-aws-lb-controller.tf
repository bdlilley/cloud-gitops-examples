module "iam-assumable-role-aws-lb-controller" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  # version                       = "~> v2.6.0"
  create_role                   = true
  role_name                     = "${local.resourcePrefix}-${var.cluster.name}-aws-lb-controller"
  provider_url                  = replace(aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")
  role_policy_arns              = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/AWSLoadBalancerControllerIAMPolicy"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
}

