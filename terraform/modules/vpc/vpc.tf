data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "eks_vpc" {
  cidr_block = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.eks_vpc.id
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id       = aws_vpc.eks_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# Associate subnets with the route table
resource "aws_route_table_association" "this" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.eks_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "eks_subnet" {
  count                   = var.subnet_count
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = var.auto_assign

  tags = {
    "kubernetes.io/role/elb" = 1
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
}

