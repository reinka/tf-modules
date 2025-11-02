resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "public" {
  for_each = {
    for k, subnet in var.subnets_config :
    k => subnet if subnet.public
  }

  vpc_id = aws_vpc.this.id
  cidr_block = cidrsubnet(
    aws_vpc.this.cidr_block, 
    each.value.cidr_newbits, 
    each.value.cidr_netnum
  )
  availability_zone = element(
    data.aws_availability_zones.available.names,
    each.value.az_idx
  )

  map_public_ip_on_launch = each.value.public

  tags = {Name = each.value.name}
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = {
    for k, subnet in var.subnets_config :
    k => subnet if subnet.public 
  }
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public[each.key].id
}