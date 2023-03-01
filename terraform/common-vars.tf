variable "stackVersion" {
  type        = string
  description = "version string used in all resource names"
}

variable "moduleName" {
  type        = string
  description = "name of current module, used in all resource names"
}

variable "tags" {
  default = {
    "created-by" = "benji_lilley"
    "team"       = "product"
    "purpose"    = "product-development"
  }
}

variable "commonVpcConfigs" {

}

variable "vpcConfigs" {

}

variable "argocd" {
  default = {
    enabled : true
    apps : {}
  }
}

variable "ISTIO_HUB" {
  default = "set-variable-in-module"
}

locals {
  resourcePrefix = "${var.stackVersion}-${var.moduleName}"
}

