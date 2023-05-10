variable "moduleName" {
  type        = string
  description = "name of current module, used in all resource names"
}

variable "stackVersion" {
  type        = string
  description = "version string used in all stack resource names"
}

variable "tags" {
  default = {
    "created-by" = "benji_lilley"
    "team"       = "product"
    "purpose"    = "product-development"
  }
}

variable "region" {
}

variable "cluster" {
}

variable "argocd" {
  # type = object({
  #   valueFiles = optional(list(string))
  # })
  default = {
    valueFiles = []
  }
}

variable "secrets" {
  default = []
}

variable "remoteAccess" {
  default = {}
}

variable "nodeGroups" {
  default = {}
}

locals {
  resourcePrefix = "${var.stackVersion}-${var.moduleName}"
}
