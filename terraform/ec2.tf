###########################################
# AMI Lookup (Ubuntu 22.04 LTS)
###########################################
data "aws_ami" "ubuntu" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

###########################################
# Bastion Host (public subnet)
###########################################
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.bastion_type
  subnet_id              = aws_subnet.public_a.id
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "bastion-host"
  }
}

###########################################
# PostgreSQL Primary Node (private subnet A)
###########################################
resource "aws_instance" "primary_db" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.db_type
  subnet_id              = aws_subnet.private_a.id
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = {
    Name = "postgres-primary"
  }
}

###########################################
# PostgreSQL Replica Node (private subnet C)
###########################################
resource "aws_instance" "replica_db" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.db_type
  subnet_id              = aws_subnet.private_b.id
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = {
    Name = "postgres-replica"
  }
}
