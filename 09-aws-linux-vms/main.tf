data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az = var.availability_zone != null ? var.availability_zone : data.aws_availability_zones.available.names[0]
}

# Latest Amazon Linux 2023 AMI (arm64 / Graviton)
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "private-vms-vpc"
  })
}

# Private subnet (no internet gateway or NAT)
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr
  availability_zone       = local.az
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "private-subnet"
  })
}

# Route table with only local route (no 0.0.0.0/0)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "private-rt"
  })
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Security group: no inbound and no outbound internet access
# Setting egress = [] removes the default allow-all egress rule
resource "aws_security_group" "private_vms" {
  name_prefix = "private-linux-vms-"
  description = "Isolated private VMs - no internet access"
  vpc_id      = aws_vpc.main.id

  # No ingress rules = deny all inbound
  # Explicit empty egress removes the default 0.0.0.0/0 allow
  egress = []

  tags = merge(var.tags, {
    Name = "private-vms-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# EC2 instances
resource "aws_instance" "linux" {
  count = var.instance_count

  ami                         = var.ami_id != null ? var.ami_id : data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.private_vms.id]
  associate_public_ip_address = false
  key_name                    = var.key_name

  # Optional: basic user data for hostname
  user_data = <<-EOF
    #!/bin/bash
    hostnamectl set-hostname linux-vm-${count.index + 1}
  EOF

  tags = merge(var.tags, {
    Name = "linux-vm-${count.index + 1}"
  })

  lifecycle {
    ignore_changes = [user_data]
  }
}
