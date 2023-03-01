terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # explicit dependency versions prevent breakage from new releases 
      version = "4.52.0"
    }
  }
}

data "aws_eks_cluster" "eks" {
  depends_on = [
    aws_eks_cluster.eks
  ]
  name = aws_eks_cluster.eks.name
}

data "aws_eks_cluster_auth" "eks" {
  depends_on = [
    aws_eks_cluster.eks
  ]
  name = aws_eks_cluster.eks.name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}