module "iam-assumable-role-istio-ingressgateway" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  create_role                   = true
  role_name                     = "${local.resourcePrefix}-${var.cluster.name}-istio-ingressgateway"
  provider_url                  = replace(aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.istio-ingressgateway.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:gloo-mesh-gateways:istio-ingressgateway-service-account"]
}

resource "aws_iam_policy" "istio-ingressgateway" {
  name        = "${local.resourcePrefix}-${var.cluster.name}-istio-ingressgateway"
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
            "lambda:Invoke"
          ],
          "Resource" : ["*"]
        }
      ]
  })
}

