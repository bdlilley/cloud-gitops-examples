

resource "helm_release" "argocd" {
  depends_on = [
    module.eks_managed_node_group
  ]

  count            = var.argocd.enabled ? 1 : 0
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.23.5"
  namespace        = "argocd"
  create_namespace = true
  timeout          = 300

  values = [<<EOT
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
    module.eks_managed_node_group,
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
    global:
      external-secrets:
        serviceAccount:
          create: true
          name: external-secrets
          annotations:
            eks.amazonaws.com/role-arn: ${module.iam-assumable-role-ext-secrets.iam_role_arn}
      aws-load-balancer-controller:
        clusterName: ${aws_eks_cluster.eks.name}
        serviceAccount:
          create: true
          name: aws-load-balancer-controller
          annotations:
            eks.amazonaws.com/role-arn: ${module.iam-assumable-role-aws-lb-controller.iam_role_arn}
EOT
  ]
}

