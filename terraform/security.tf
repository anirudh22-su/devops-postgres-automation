###########################################
# SECURITY GROUPS FOR ONECLICK INFRA
###########################################

# Bastion Security Group
resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg"
  vpc_id = aws_vpc.new.id

  # Allow SSH ONLY from existing EC2 public IP
  ingress {
    description = "SSH from existing EC2"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr] # already includes /32
  }

  # Allow SSH OUT to all of new private VPC
  egress {
    description = "SSH to private subnets"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.50.0.0/16"]
  }

  # Allow internet outbound (for apt update, ansible, etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# DB Security Group
resource "aws_security_group" "db_sg" {
  name   = "db-sg"
  vpc_id = aws_vpc.new.id

  # Allow PostgreSQL from new VPC
  ingress {
    description = "PostgreSQL Access"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.50.0.0/16"]
  }

  # Allow SSH ONLY from Bastion SG
  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
