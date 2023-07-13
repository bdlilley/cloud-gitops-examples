variable "tags" {
  # default = {
  #   "created-by" = "benji_lilley"
  #   "team"       = "product"
  #   "purpose"    = "product-development"
  # }
}

variable "region" {
}

variable "cluster" {
}

variable "remoteAccess" {
  default = {}
}

variable "nodeGroups" {
  default = {}
}

variable "resourcePrefix" {
  type        = string
  description = "name of current module, used in all resource names"
}
