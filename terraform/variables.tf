###############################################
# VARIABLES FOR ONECLICK INFRA
###############################################

# AWS Region
variable "region" {
  type    = string
  default = "ap-northeast-1"
}

# Existing EC2 (Jenkins server) in default VPC
variable "existing_vpc_id" {
  type    = string
  default = "vpc-0edd2709b91e3f98f"
}

# Existing EC2 IPs (required for SG and routing)
variable "existing_ec2_public_ip" {
  type    = string
  default = "52.192.196.205"
}

variable "existing_ec2_private_ip" {
  type    = string
  default = "172.31.42.78"
}

###############################################
# NEW VPC CIDRs
###############################################
variable "vpc_cidr" {
  type    = string
  default = "10.50.0.0/16"
}

variable "public_a" {
  type    = string
  default = "10.50.1.0/24"
}

variable "private_a" {
  type    = string
  default = "10.50.2.0/24"
}

variable "public_b" {
  type    = string
  default = "10.50.3.0/24"
}

variable "private_b" {
  type    = string
  default = "10.50.4.0/24"
}

###############################################
# AVAILABILITY ZONES
###############################################
variable "az1" {
  type    = string
  default = "ap-northeast-1a"
}

variable "az2" {
  type    = string
  default = "ap-northeast-1c"
}

###############################################
# SSH + INSTANCE TYPES
###############################################
variable "ssh_key_name" {
  type    = string
  default = "jenkins"
}

# Allowed SSH only from existing EC2 public IP
variable "allowed_ssh_cidr" {
  type    = string
  default = "52.192.196.205/32"
}

variable "bastion_type" {
  type    = string
  default = "t3.micro"
}

variable "db_type" {
  type    = string
  default = "t3.small"
}
