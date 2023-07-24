module "iam-assumable-role-argocd" {
  source                       = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  create_role                  = true
  role_name                    = "${var.resourcePrefix}-${var.cluster.name}-argocd"
  provider_url                 = replace(aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")
  oidc_subjects_with_wildcards = ["system:serviceaccount:argocd:argocd-*"]
}
