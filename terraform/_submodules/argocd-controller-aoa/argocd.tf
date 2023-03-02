
resource "helm_release" "argocd" {
  count = var.argocd.enabled ? 1 : 0

  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.23.5"
  namespace        = "argocd"
  create_namespace = true
  timeout          = 300

  values = [<<EOT
bump: 1
dex:
  enabled: false
notifications:
  enabled: false
EOT
  ]
}

resource "helm_release" "argocd-aoa" {
  for_each = var.argocd.apps
  depends_on = [
    helm_release.argocd
  ]

  name             = "aoa-${each.key}"
  chart            = "${path.module}/../argocd-app-bootstrap"
  namespace        = "argocd"
  create_namespace = true
  timeout          = 600

  values = [<<EOT
repoURL: ${each.value.repo}
targetRevision: ${each.value.revision}
path: ${each.value.path}
helm:
  valueFiles: ${jsonencode(each.value.valueFiles)}
  values:
    bump: 1
    global:
      external-secrets:
        serviceAccount:
          create: true
          name: external-secrets
          annotations:
            eks.amazonaws.com/role-arn: ${var.irsa.ext-secrets}
      aws-load-balancer-controller:
        clusterName: ${var.eksClusterName}
        serviceAccount:
          create: true
          name: aws-load-balancer-controller
          annotations:
            eks.amazonaws.com/role-arn: ${var.irsa.aws-lb-controller}
      gloo-mesh-enterprise:
        glooMeshMgmtServer:
          serviceAccount:
            extraAnnotations:
              eks.amazonaws.com/role-arn: ${var.irsa.gloo-mgmt-server}
EOT
  ]
}

