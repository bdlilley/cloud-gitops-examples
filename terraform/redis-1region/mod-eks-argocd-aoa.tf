
module "argocd-aoa" {
  depends_on = [
    module.eks,
    kubernetes_secret.redis-tester
  ]

  source         = "../_submodules/argocd-controller-aoa"
  irsa           = module.eks.irsa
  eksClusterName = module.eks.eks.name
  argocd = {
    enabled = true
    apps = {
      my-cluster = {
        repo     = "https://github.com/bensolo-io/cloud-gitops-examples.git"
        revision = "main"
        path     = "argocd/argocd-aoa"
        valueFiles = [
          "values-aws-core-infra.yaml",
          "values-redis-tester.yaml"
        ]
      }
    }
  }
}
