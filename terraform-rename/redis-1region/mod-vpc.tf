

module "us-east-2" {
  source           = "../_submodules/vpc"
  vpcConfig        = var.vpcConfigs["us-east-2"]
  stackVersion     = var.stackVersion
  moduleName       = var.moduleName
  tags             = var.tags
  commonVpcConfigs = var.commonVpcConfigs
  region           = "us-east-2"
}

output "vpcs" {
  value = {
    "us-east-2" : module.us-east-2,
  }
}
