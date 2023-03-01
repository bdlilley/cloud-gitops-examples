
locals {
  vpclocals = {
    "us-east-1" : {
      subnetIds : [for sn in module.vpc-us-east-1.privateSubnets : sn.id]
      securityGroupIds : [
        module.vpc-us-east-1.commonSecurityGroup.id,
        module.vpc-us-east-1.interfaceSecurityGroup.id,
      ]
    }
    "us-east-2" : {
      subnetIds : [for sn in module.vpc-us-east-2.privateSubnets : sn.id]
      securityGroupIds : [
        module.vpc-us-east-2.commonSecurityGroup.id,
        module.vpc-us-east-2.interfaceSecurityGroup.id,
      ]
    }
  }

}