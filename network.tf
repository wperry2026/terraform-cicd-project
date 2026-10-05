#-----------------------------------
# 1. Virtual Private Cloud (VPC)
#-----------------------------------
resource "aws_vpc" "main" {
  cidr_block           = "20.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "todoapp-vpc"
  }
}

#-----------------------------------
# 2. Internet Gateway (IGW)
#-----------------------------------
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "todoapp-igw"
  }
}

#-----------------------------------
# 3. Public Subnet
#-----------------------------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "20.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-4a"

  tags = {
    Name = "todoapp-public-subnet"
  }
}

#-----------------------------------
# 4. Route Table for Public Subnet
#-----------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "todoapp-public-route-table"
  }
}

#-----------------------------------
# 5. Route Table Association for Public Subnet
#-----------------------------------
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

#-----------------------------------
# 6. Security Group for HTTP Access
#-----------------------------------
resource "aws_security_group" "http_sg" {
  name        = "allow-http"
  description = "Allow inbound HTTP traffic from public internet"
  vpc_id      = aws_vpc.main.id

  # Inbound HTTP rule
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound all traffic rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    ="-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "todoapp-http-sg"
  }
}