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