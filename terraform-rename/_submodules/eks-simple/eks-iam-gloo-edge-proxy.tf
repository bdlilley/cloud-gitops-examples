module "iam-assumable-role-gloo-edge-proxy" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  create_role                   = true
  role_name                     = "${var.resourcePrefix}-${var.cluster.name}-gloo-edge-proxy"
  provider_url                  = replace(aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.gloo-edge-proxy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:gloo-system:gateway-proxy"]
}

resource "aws_iam_policy" "gloo-edge-proxy" {
  name        = "${var.resourcePrefix}-${var.cluster.name}-gloo-edge-proxy"
  path        = "/"
  description = "list and invoke lambda functions"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : [
            "lambda:listFunctions",
            "lambda:InvokeFunction"
          ],
          "Resource" : ["*"]
        }
      ]
  })
}

