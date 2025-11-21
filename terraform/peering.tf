# Get existing VPC
data "aws_vpc" "existing" {
  id = var.existing_vpc_id
}

resource "aws_vpc_peering_connection" "peer" {
  vpc_id      = aws_vpc.new.id
  peer_vpc_id = data.aws_vpc.existing.id
  auto_accept = true
  tags        = { Name = "peering-new-to-existing" }
}

resource "aws_route" "new_to_existing" {
  route_table_id            = aws_route_table.private_rt.id
  destination_cidr_block    = data.aws_vpc.existing.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

data "aws_route_tables" "existing_rts" {
  filter {
    name   = "vpc-id"
    values = [var.existing_vpc_id]
  }
}

resource "aws_route" "existing_to_new" {
  count = length(data.aws_route_tables.existing_rts.ids) > 0 ? 1 : 0

  route_table_id            = data.aws_route_tables.existing_rts.ids[0]
  destination_cidr_block    = aws_vpc.new.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}
