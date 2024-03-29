output "irsa" {
  value = {
    aws-lb-controller    = module.iam-assumable-role-aws-lb-controller.iam_role_arn
    ext-secrets          = module.iam-assumable-role-ext-secrets.iam_role_arn
    gloo-mgmt-server     = module.iam-assumable-role-gloo-mgmt-server.iam_role_arn
    gloo-edge-proxy      = module.iam-assumable-role-gloo-edge-proxy.iam_role_arn
    istio-ingressgateway = module.iam-assumable-role-istio-ingressgateway.iam_role_arn
  }
}