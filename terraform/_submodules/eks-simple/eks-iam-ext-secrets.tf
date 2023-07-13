module "iam-assumable-role-ext-secrets" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  # version                       = "~> v2.6.0"
  create_role                   = true
  role_name                     = "${var.resourcePrefix}-${var.cluster.name}-ext-secrets"
  provider_url                  = replace(aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.ext-secrets.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:external-secrets:external-secrets"]
}

resource "aws_iam_policy" "ext-secrets" {
  name        = "${var.resourcePrefix}-${var.cluster.name}-ext-secrets"
  path        = "/"
  description = "sync secrets manager to k8s"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : [
            "secretsmanager:GetResourcePolicy",
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
            "secretsmanager:ListSecretVersionIds"
          ],
          "Resource" : ["arn:aws:secretsmanager:*:${data.aws_caller_identity.current.account_id}:secret:*"]
        }
      ]
  })
}

