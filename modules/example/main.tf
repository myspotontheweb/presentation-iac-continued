#######################################################################
# create main vpc
#######################################################################

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.vpc_name}"
  }
}

######################################################################
# Create public and private subnets
######################################################################

resource "aws_subnet" "public" {
  count      = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)
 
  tags = {
    Name = join(" ", [var.vpc_name, "public subnet ${count.index + 1}"])
  }
}
 
resource "aws_subnet" "private" {
  count      = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)
 
  tags = {
    Name = join(" ", [var.vpc_name, "private subnet ${count.index + 1}"])
  }
}

#############################################
# create internet gateway
#############################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = join("-", [var.vpc_name, "igw"])
  }
}

#############################################
# create nat gateways
#############################################

resource "aws_eip" "nat_ips" {
  count      = length(aws_subnet.private)
  domain     = "vpc"
  tags = {
    Name = join(" ", [var.vpc_name, "Nat gateway", count.index])
  }
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat" {
  count         = length(aws_subnet.private)
  subnet_id     = aws_subnet.public[count.index].id
  allocation_id = aws_eip.nat_ips[count.index].id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = join("-", [var.vpc_name, "nat", count.index])
  }
}

#############################################
# create additional route tables
#############################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
 
  tags = {
    Name = join(" ", [var.vpc_name, "Public route table"])
  }
}

resource "aws_route_table" "private" {
  count  = length(aws_nat_gateway.nat)
  vpc_id = aws_vpc.main.id
 
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }
 
  tags = {
    Name = join(" ", [var.vpc_name, "Private route table", count.index])
  }
}

##################################
# subnets route table associations
##################################

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

######################################
# Setup EC2 Instance Connect Endpoints
######################################

resource "aws_ec2_instance_connect_endpoint" "endpoint" {
  count = var.instance_connect_endpoint_enabled ? 1 : 0
  subnet_id = aws_subnet.private[0].id
  tags = {
    Name = join(" ", [var.vpc_name, "ec2 instance endpoint", 0])
  }
}