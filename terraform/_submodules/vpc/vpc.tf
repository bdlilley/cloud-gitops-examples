
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpcConfig.cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { "Name" : "${local.resourcePrefix}-${var.region}" }
}

output "vpc" {
  value = aws_vpc.vpc
}

resource "aws_subnet" "private" {
  for_each = { for i, sn in var.vpcConfig.privateNets : i => sn }

  vpc_id               = aws_vpc.vpc.id
  cidr_block           = each.value.cidr
  availability_zone_id = try(each.value.zoneId, null)

  tags = {
    Name                              = "${local.resourcePrefix}-private-${try(each.value.zoneId, "")}"
    "kubernetes.io/role/internal-elb" = 1
  }
}

output "privateSubnets" {
  value = aws_subnet.private
}

resource "aws_subnet" "public" {
  for_each = { for i, sn in var.vpcConfig.publicNets : i => sn }

  vpc_id               = aws_vpc.vpc.id
  cidr_block           = each.value.cidr
  availability_zone_id = try(each.value.zoneId, null)

  tags = {
    Name = "${local.resourcePrefix}-public-${try(each.value.zoneId, "")}"
  }
}

output "publicSubnets" {
  value = aws_subnet.public
}

resource "aws_vpc_endpoint" "interface" {
  for_each = { for i, val in var.commonVpcConfigs.interfaceEndpoints : val => 1 }

  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region}.${each.key}"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [for sn in aws_subnet.private : sn.id]
  security_group_ids = [
    aws_security_group.interface.id,
  ]

  private_dns_enabled = true
}


resource "aws_security_group" "interface" {
  name        = "${local.resourcePrefix}-interface"
  description = "vpc endpiont interfaces"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "all from client"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  tags = {
    Name = "${local.resourcePrefix}-interface"
  }
}

output "interfaceSecurityGroup" {
  value = aws_security_group.interface
}

resource "aws_vpc_endpoint" "gateway" {
  for_each = { for i, val in var.commonVpcConfigs.gatewayEndpoints : val => 1 }

  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region}.${each.key}"
  vpc_endpoint_type = "Gateway"
}

resource "aws_vpc_endpoint_route_table_association" "gateway" {
  for_each = { for i, val in var.commonVpcConfigs.gatewayEndpoints : val => 1 }

  route_table_id  = aws_route_table.private.id
  vpc_endpoint_id = aws_vpc_endpoint.gateway[each.key].id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = local.resourcePrefix
  }
}

resource "aws_eip" "nat1" {
  vpc = true
}

resource "aws_nat_gateway" "nat1" {
  allocation_id     = aws_eip.nat1.allocation_id
  connectivity_type = "public"
  subnet_id         = aws_subnet.public[0].id
}


resource "aws_security_group" "common" {
  name        = "${local.resourcePrefix}-common"
  description = "common multi-cluster SG"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "all from private"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8", "192.168.0.0/16"]
  }

  egress {
    description = "all to private"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8", "192.168.0.0/16"]
  }

  egress {
    description = "https to internet"
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.resourcePrefix}-common"
  }
}

output "commonSecurityGroup" {
  value = aws_security_group.common
}

