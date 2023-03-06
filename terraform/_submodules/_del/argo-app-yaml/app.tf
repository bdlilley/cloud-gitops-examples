output "manifest" {
  value = templatefile(
               "${path.module}/app.tftpl",
               {
                name = var.name
                repo = var.repo
                path = var.path
                revision = var.revision
                valueFiles = var.valueFiles
                values = yamldecode(<<EOT
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
                )
               })
}

