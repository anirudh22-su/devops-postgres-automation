resource "aws_vpc" "new" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "oneclick-new-vpc" }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.new.id
  cidr_block              = var.public_a
  availability_zone       = var.az1
  map_public_ip_on_launch = true
  tags                    = { Name = "public-a" }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.new.id
  cidr_block        = var.private_a
  availability_zone = var.az1
  tags              = { Name = "private-a" }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.new.id
  cidr_block              = var.public_b
  availability_zone       = var.az2
  map_public_ip_on_launch = true
  tags                    = { Name = "public-b" }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.new.id
  cidr_block        = var.private_b
  availability_zone = var.az2
  tags              = { Name = "private-b" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.new.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.new.id
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "pub_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "pub_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.new.id
}

resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "priv_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "priv_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rt.id
}
