resource "aws_vpc" "vpc" {
  cidr_block           = local.vpc_ipblock
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(map("Name", join("-", [local.env, local.project, "vpc"])), map("ResourceType", "VPC"), local.common_tags)
  lifecycle {
    prevent_destroy = true
  }
}

################## SUBNET ######################

resource "aws_subnet" "public-subnet-1a" {
  cidr_block        = local.public_subnet_1a
  vpc_id            = aws_vpc.vpc.id
  tags              = merge(map("Name", join("-", [local.env, local.project, "public-subnet-1a"])), map("ResourceType", "SUBNET"), local.common_tags)
  availability_zone = "ap-southeast-1a"
}

resource "aws_subnet" "public-subnet-1b" {
  cidr_block        = local.public_subnet_1b
  vpc_id            = aws_vpc.vpc.id
  tags              = merge(map("Name", join("-", [local.env, local.project, "public-subnet-1b"])), map("ResourceType", "SUBNET"), local.common_tags)
  availability_zone = "ap-southeast-1b"
}

resource "aws_subnet" "public-subnet-1c" {
  cidr_block        = local.public_subnet_1c
  vpc_id            = aws_vpc.vpc.id
  tags              = merge(map("Name", join("-", [local.env, local.project, "public-subnet-1c"])), map("ResourceType", "SUBNET"), local.common_tags)
  availability_zone = "ap-southeast-1c"
}

resource "aws_subnet" "private-subnet-1a" {
  cidr_block        = local.private_subnet_1a
  vpc_id            = aws_vpc.vpc.id
  tags              = merge(map("Name", join("-", [local.env, local.project, "private-subnet-1a"])), map("ResourceType", "SUBNET"), local.common_tags)
  availability_zone = "ap-southeast-1a"
}

resource "aws_subnet" "private-subnet-1b" {
  cidr_block        = local.private_subnet_1b
  vpc_id            = aws_vpc.vpc.id
  tags              = merge(map("Name", join("-", [local.env, local.project, "private-subnet-1b"])), map("ResourceType", "SUBNET"), local.common_tags)
  availability_zone = "ap-southeast-1b"
}

resource "aws_subnet" "private-subnet-1c" {
  cidr_block        = local.private_subnet_1c
  vpc_id            = aws_vpc.vpc.id
  tags              = merge(map("Name", join("-", [local.env, local.project, "private-subnet-1c"])), map("ResourceType", "SUBNET"), local.common_tags)
  availability_zone = "ap-southeast-1c"
}

############### Security Group ###############

resource "aws_security_group" "eks-cluster-sg" {
  name        = "${local.env}-${local.project}-eks-cluster-sg"
  description = "Security Group For EKS Cluster Mangemen"
  vpc_id      = aws_vpc.vpc.id
  tags        = merge(map("Name", join("-", [local.env, local.project, "eks-cluster-sg"])), map("ResourceType", "SECURITYGROUP"), local.common_tags)

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "Allow pods to communicate with the cluster API Server"
    cidr_blocks = [aws_subnet.private-subnet-1a.cidr_block, aws_subnet.private-subnet-1b.cidr_block, aws_subnet.private-subnet-1c.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    description = "Allow all"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    ignore_changes = [ingress, egress]
  }
}

resource "aws_security_group" "eks-worker-node-sg" {
  name        = "${local.env}-${local.project}-eks-worker-node-sg"
  description = "EKS worker node security group"
  vpc_id      = aws_vpc.vpc.id
  tags        = merge(map("Name", join("-", [local.env, local.project, "eks-worker-node-sg"])), map("ResourceType", "SECURITYGROUP"), local.common_tags)

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    description = "Allow all traffic"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    description = "Allow all"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    ignore_changes = [ingress, egress]
  }
}

############### Security Group ###############