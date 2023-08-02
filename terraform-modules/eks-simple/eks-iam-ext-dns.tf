module "iam-assumable-role-ext-dns" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  # version                       = "~> v2.6.0"
  create_role                   = true
  role_name                     = "${var.resourcePrefix}-${var.cluster.name}-ext-dns"
  provider_url                  = replace(aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.ext-dns.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:external-dns"]
}

resource "aws_iam_policy" "ext-dns" {
  name        = "${var.resourcePrefix}-${var.cluster.name}-ext-dns"
  path        = "/"
  description = "manage dns records"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "route53:ChangeResourceRecordSets"
          ],
          "Resource" : [
            "arn:aws:route53:::hostedzone/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "route53:ListHostedZones",
            "route53:ListResourceRecordSets",
            "route53:ListTagsForResource"
          ],
          "Resource" : [
            "*"
          ]
        }
      ]
  })
}

