resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"

  enable_dns_hostnames = true

  tags = {
    Name = "${var.name}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_eip" "nat_gw" {
  tags = {
    Name = "${var.name}-nat-gw-eip"
  }
}

data "aws_availability_zones" "available" {
    state = "available"
}

locals {
  subnet_len = 2
}

resource "aws_subnet" "public" {
  count = local.subnet_len
  vpc_id = aws_vpc.this.id

  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  cidr_block = cidrsubnet(
    aws_vpc.this.cidr_block,
    8,
    count.index + 1
  )

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public-sn-${count.index}",
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_subnet" "private" {
  count = local.subnet_len
  vpc_id = aws_vpc.this.id

  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  cidr_block = cidrsubnet(
    aws_vpc.this.cidr_block,
    8,
    count.index + local.subnet_len + 1
  )

  tags = {
    Name = "${var.name}-private-sn-${count.index}",
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_nat_gateway" "this" {
  subnet_id = aws_subnet.public[0].id
  allocation_id = aws_eip.nat_gw.id

  depends_on = [ aws_internet_gateway.this ]
  tags = {
    Name = "${var.name}-nat-gw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-public-rt"
  }
}

resource "aws_route" "egress_public" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count = local.subnet_len
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public[count.index].id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-private-rt"
  }
}

resource "aws_route" "egress_private" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "private" {
  count = local.subnet_len
  route_table_id = aws_route_table.private.id
  subnet_id = aws_subnet.private[count.index].id
}