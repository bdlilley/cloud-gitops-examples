variable "argocd" {
  default = {
    enabled : true
    apps : {}
  }
}

variable "irsa" {
  default = {}
}

variable "eksClusterName" {
}

variable "ISTIO_HUB" {
  default = "set-variable-in-module"
}