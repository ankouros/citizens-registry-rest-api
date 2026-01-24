# --------------------
# VPC (VIRTUAL PRIVATE CLOUD)
# --------------------
resource "aws_vpc" "main" {
  # Single VPC to clearly scope the lab environment.
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "citizens-registry-vpc"
  }
}

# --------------------
# INTERNET GATEWAY
# --------------------
resource "aws_internet_gateway" "igw" {
  # Required for public access to the load balancer.
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "citizens-registry-igw"
  }
}

# --------------------
# PUBLIC SUBNET (LOAD BALANCER)
# --------------------
resource "aws_subnet" "public" {
  # Public subnet for the ALB to receive inbound traffic.
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name = "public-subnet"
  }
}

# --------------------
# PRIVATE SUBNET (REST + DB)
# --------------------
resource "aws_subnet" "private" {
  # Private subnet for REST and DB to avoid public exposure.
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "private-subnet"
  }
}

# --------------------
# PUBLIC ROUTE TABLE
# --------------------
resource "aws_route_table" "public_rt" {
  # Route table that allows Internet access via the IGW.
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_assoc" {
  # Associate the public subnet with the public route table.
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# --------------------
# PRIVATE ROUTE TABLE
# --------------------
resource "aws_route_table" "private_rt" {
  # Private routing without 0.0.0.0/0 to avoid direct exposure.
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private_assoc" {
  # Associate the private subnet with the private route table.
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}

# --------------------
# SECOND PUBLIC SUBNET (ALB REQUIREMENT)
# --------------------
resource "aws_subnet" "public_b" {
  # Second public subnet in another AZ, required by the ALB.
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}b"

  tags = {
    Name = "public-subnet-b"
  }
}

resource "aws_route_table_association" "public_assoc_b" {
  # Associate the second public subnet with the same public route table.
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}
