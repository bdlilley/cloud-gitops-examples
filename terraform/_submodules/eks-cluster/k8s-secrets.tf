locals {
  secrets = { for s in var.secrets : "${s.name}-${s.namespace}" => merge(s, {
    "yaml" = <<-EOT
apiVersion: v1
${yamlencode({ lookup(s, "encoded", false) ? "data" : "stringData" : s.data })}
kind: Secret
metadata:
  name: ${s.name}
  namespace: ${s.namespace}
type: ${try(s.type, "Opaque")}
EOT
  }) }

}


resource "null_resource" "secrets" {
  for_each = local.secrets

  triggers = {
    hash      = sha1(each.value.yaml)
    cluster   = aws_eks_cluster.eks.name
    namespace = each.value.namespace
    name      = each.value.name
    arn       = aws_eks_cluster.eks.arn
    region = var.region
  }

  # external commands are required to keep the eks cluster creation and k8s resource creation 
  # in the same module; if you were to use the eks auth resource and kubernetes provider here, it would
  # work the first time the cluster is created, but after that session expires it will no longer be to
  # reach your cluster unless you point epxlicitly to local kubeconfig
  provisioner "local-exec" {
    command = <<-EOC
KUBECONFIG=$${HOME}/.kube/${aws_eks_cluster.eks.name} AWS_REGION=${self.triggers.region} aws eks update-kubeconfig --name ${self.triggers.cluster} 
%{if try(each.value.createNamespace, false)}KUBECONFIG=$${HOME}/.kube/${aws_eks_cluster.eks.name} AWS_REGION=${self.triggers.region}  kubectl create namespace ${each.value.namespace}  || true %{endif}
KUBECONFIG=$${HOME}/.kube/${aws_eks_cluster.eks.name} AWS_REGION=${self.triggers.region}  kubectl apply --context ${local.theContext} -f - <<EOT
${each.value.yaml}
EOT
EOC
  }
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOD
KUBECONFIG=$${HOME}/.kube/${self.triggers.cluster} AWS_REGION=${self.triggers.region}  aws eks update-kubeconfig --name ${self.triggers.cluster}
KUBECONFIG=$${HOME}/.kube/${self.triggers.cluster} AWS_REGION=${self.triggers.region} kubectl delete secret ${self.triggers.name} -n ${self.triggers.namespace} --context ${self.triggers.arn} || true
  EOD
  }
}

# locals {
#   argoEnabled = length(var.argocd.valueFiles) > 0

#   kubectl = <<EOT
# aws eks update-kubeconfig --name ${aws_eks_cluster.eks.name}
# kubectl create ns argocd
# kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/master/manifests/install.yaml -n argocd
# kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd
# kubectl apply -f - <<EOM
# ${local.manifest}
# EOM
# EOT

#   kubectlTrigger = "${sha1(local.manifest)}-${sha1(local.kubectl)}"

#   manifest = templatefile(
#     "${path.module}/app.tftpl",
#     {
#       name       = aws_eks_cluster.eks.name
#       repo       = var.argocd.repo
#       path       = var.argocd.path
#       revision   = var.argocd.revision
#       valueFiles = var.argocd.valueFiles
#       values = yamldecode(<<EOT
#     global:
#       external-secrets:
#         serviceAccount:
#           create: true
#           name: external-secrets
#           annotations:
#             eks.amazonaws.com/role-arn: ${module.iam-assumable-role-ext-secrets.iam_role_arn}
#       aws-load-balancer-controller:
#         clusterName: ${aws_eks_cluster.eks.name}
#         serviceAccount:
#           create: true
#           name: aws-load-balancer-controller
#           annotations:
#             eks.amazonaws.com/role-arn: ${module.iam-assumable-role-aws-lb-controller.iam_role_arn}
#       gloo-mesh-enterprise:
#         glooMeshMgmtServer:
#           serviceAccount:
#             extraAnnotations:
#               eks.amazonaws.com/role-arn: ${module.iam-assumable-role-gloo-mgmt-server.iam_role_arn}
# EOT
#   ) })


# }


