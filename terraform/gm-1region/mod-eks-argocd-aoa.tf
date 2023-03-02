
module "argocd-aoa" {
  depends_on = [
    module.eks,
    kubernetes_secret.gloo-mesh,
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
          "values-gm-2.3.0-beta1-istio-1.16-SIMPLE.yaml",
          "values-redis-tester.yaml"
        ]
      }
    }
  }
}

resource "kubernetes_namespace" "gloo-mesh" {
  depends_on = [
    module.eks,
  ]
  metadata {
    name = "gloo-mesh"
  }
}

resource "kubernetes_secret" "gloo-mesh" {
  depends_on = [
    module.eks,
  ]
  metadata {
    name      = "gloo-mesh-license"
    namespace = kubernetes_namespace.gloo-mesh.metadata[0].name
  }

  data = {
    gloo-gateway-license-key = var.GLOO_MESH_GATEWAY_LICENSE_KEY
    gloo-mesh-license-key    = var.GLOO_MESH_LICENSE_KEY
    gloo-network-license-key = var.GLOO_NETWORK_LICENSE_KEY
    gloo-trial-license-key   = var.GLOO_TRIAL_LICENSE_KEY
  }
}


resource "kubernetes_secret" "redis-tester" {
  depends_on = [
    module.eks,
  ]
  metadata {
    name      = "redis-config"
    namespace = "default"
  }

  data = {
    token   = var.redis_auth
    address = "${aws_elasticache_replication_group.redis.primary_endpoint_address}:${aws_elasticache_replication_group.redis.port}"
  }
}