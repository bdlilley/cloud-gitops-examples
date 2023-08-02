locals {
  eks-default-kubernetesClusterName = "default"
  eks-default-nodeGroupConfig = {
    min_size        = 0
    max_size        = 4
    desired_size    = 1
    instance_types  = ["m5.2xlarge"]
    commonClusterSg = aws_security_group.common-us-east-1.id
  }
  eks-default-subnetIds        = [for sn in module.vpc-us-east-1.privateSubnets : sn.id]
  eks-default-securityGroupIds = [aws_security_group.common-us-east-1.id]
  argocd-destination-server = "https://kubernetes.default.svc"
}

module "eks-default" {
  source = "../../terraform-modules/eks-simple"
  # source         = "git::https://github.com/bdlilley/cloud-gitops-examples.git//terraform-modules/eks-simple?ref=main"
  resourcePrefix = var.resourcePrefix
  tags           = var.tags

  cluster = {
    name             = local.eks-default-kubernetesClusterName
    version          = var.kubernetesVersion
    securityGroupIds = local.eks-default-securityGroupIds
    subnetIds        = local.eks-default-subnetIds
  }

  nodeGroups = {
    default = local.eks-default-nodeGroupConfig
  }
}

output "eks" {
  value = module.eks-default
}

output "argocd-destination-server" {
  value = local.argocd-destination-server
}

locals {
  updateKubeconfig = <<EOT
  aws eks update-kubeconfig --name ${module.eks-default.eks.name} 
  kubectl config rename-context ${module.eks-default.eks.arn} default
  EOT
}

output "update-kubeconfig" {
  value = local.updateKubeconfig
}

module "irsa-argocd-default-controller" {
  source                       = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  create_role                  = true
  role_name                    = "${var.resourcePrefix}-default-argocd-controller"
  provider_url                 = replace(module.eks-default.eks.identity[0].oidc[0].issuer, "https://", "")
  # in single cluster setups do not need to add policies
  # role_policy_arns             = [aws_iam_policy.default.arn]
  oidc_subjects_with_wildcards = ["system:serviceaccount:argocd:argocd-*"]
}

output "irsa-argocd-controller-arn" {
  value = module.irsa-argocd-default-controller.iam_role_arn
}