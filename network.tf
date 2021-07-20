resource "aws_vpc" "vpc" {
  cidr_block           = local.vpc_ipblock
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(map("Name", join("-", [local.env, local.project, "vpc"])), map("ResourceType", "VPC"), local.common_tags)
  //  lifecycle {
  //    prevent_destroy = true
  //  }
}

################## Internet Gateway ######################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(map("Name", "${local.env}-${local.project}-igw"), map("ResourceType", "IGW"), local.common_tags)
  //  lifecycle {
  //    prevent_destroy = true
  //  }
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
  tags              = merge(map("Name", join("-", [local.env, local.project, "private-subnet-1a"])), map("ResourceType", "SUBNET"), map("kubernetes.io/cluster/${local.env}-${local.project}-eks-cluster", "shared"), local.common_tags)
  availability_zone = "ap-southeast-1a"
}

resource "aws_subnet" "private-subnet-1b" {
  cidr_block        = local.private_subnet_1b
  vpc_id            = aws_vpc.vpc.id
  tags              = merge(map("Name", join("-", [local.env, local.project, "private-subnet-1b"])), map("ResourceType", "SUBNET"),map("kubernetes.io/cluster/${local.env}-${local.project}-eks-cluster", "shared"), local.common_tags)
  availability_zone = "ap-southeast-1b"
}

resource "aws_subnet" "private-subnet-1c" {
  cidr_block        = local.private_subnet_1c
  vpc_id            = aws_vpc.vpc.id
  tags              = merge(map("Name", join("-", [local.env, local.project, "private-subnet-1c"])), map("ResourceType", "SUBNET"), map("kubernetes.io/cluster/${local.env}-${local.project}-eks-cluster", "shared"), local.common_tags)
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

############### NAT Gateway ###############
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public-subnet-1a.id
  tags          = merge(map("Name", "${local.env}-${local.project}-natgw"), map("ResourceType", "NATGW"), local.common_tags)
  //  lifecycle {
  //    prevent_destroy = true
  //  }
}

# elastic IP for natgw
resource "aws_eip" "eip" {
  vpc  = true
  tags = merge(map("Name", "${local.env}-${local.project}-natgw-eip"), map("ResourceType", "EIP"), local.common_tags)
  //  lifecycle {
  //    prevent_destroy = true
  //  }
}

############### Route Table ###############

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(map("Name", "${local.env}-${local.project}-public-route-table"), map("ResourceType", "PublicRouteTable"), local.common_tags)
  //  lifecycle {
  //    prevent_destroy = true
  //  }
}

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(map("Name", "${local.env}-${local.project}-private-route-table"), map("ResourceType", "PrivateRouteTable"), local.common_tags)
  //  lifecycle {
  //    prevent_destroy = true
  //  }
}

resource "aws_route" "public-route-table-igw-route" {
  route_table_id         = aws_route_table.public-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "route-with-ngw" {
  route_table_id         = aws_route_table.private-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw.id
}

resource "aws_route_table_association" "public-subnet-1a" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.public-subnet-1a.id
}

resource "aws_route_table_association" "public-subnet-1b" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.public-subnet-1b.id
}

resource "aws_route_table_association" "public-subnet-1c" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.public-subnet-1c.id
}

resource "aws_route_table_association" "private-subnet-1a" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.private-subnet-1a.id
}

resource "aws_route_table_association" "private-subnet-1b" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.private-subnet-1b.id
}

resource "aws_route_table_association" "private-subnet-1c" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.private-subnet-1c.id
}