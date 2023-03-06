
data "aws_eks_cluster" "eks" {
  depends_on = [
    module.eks
  ]
  name = module.eks.eks.name
}

data "aws_eks_cluster_auth" "eks" {
  depends_on = [
    module.eks
  ]
  name = module.eks.eks.name
}

# provider "kubernetes" {
#   config_path    = "~/.kube/config"
#   config_context = "arn:aws:eks:us-east-2:931713665590:cluster/solo-v0-eks-1region-cluster"
#   # host                   = data.aws_eks_cluster.eks.endpoint
#   # cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
#   # token                  = data.aws_eks_cluster_auth.eks.token
# }

# provider "helm" {
#   kubernetes {
#     config_path    = "~/.kube/config"
#     config_context = "arn:aws:eks:us-east-2:931713665590:cluster/solo-v0-eks-1region-cluster"
#     # host                   = data.aws_eks_cluster.eks.endpoint
#     # cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
#     # token                  = data.aws_eks_cluster_auth.eks.token
#   }

# }