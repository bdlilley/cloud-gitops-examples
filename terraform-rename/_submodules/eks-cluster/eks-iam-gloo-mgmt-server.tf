module "iam-assumable-role-gloo-mgmt-server" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  create_role                   = true
  role_name                     = "${local.resourcePrefix}-${var.cluster.name}-gloo-mgmt-server"
  provider_url                  = replace(aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.gloo-mgmt-server.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:gloo-mesh:gloo-mesh-mgmt-server"]
}

resource "aws_iam_policy" "gloo-mgmt-server" {
  name        = "${local.resourcePrefix}-${var.cluster.name}-gloo-mgmt-server"
  path        = "/"
  description = "discover lambda functions"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : [
            "lambda:listFunctions"
          ],
          "Resource" : ["*"]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "sts:assumeRole"
          ],
          "Resource" : ["*"]
        }
      ]
  })
}

