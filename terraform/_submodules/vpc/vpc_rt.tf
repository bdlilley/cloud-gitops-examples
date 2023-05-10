resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${local.resourcePrefix}-public"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = { for i, sn in var.vpcConfig.publicNets : i => sn }
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat1.id
  }

  tags = {
    Name = "${local.resourcePrefix}-private"
  }
}

resource "aws_route_table_association" "private" {
  for_each       = { for i, sn in var.vpcConfig.privateNets : i => sn }
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private.id
}