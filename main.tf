# Create the VPC
resource "aws_vpc" "xfusion_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.KKE_VPC_NAME
  }
}

# Create Subnet with Depends_On Dependency
resource "aws_subnet" "xfusion_subnet" {
  vpc_id            = aws_vpc.xfusion_vpc.id
  cidr_block        = var.subnet_cidr
  availability_zone = "us-east-1a"

  # Explicit dependency declaration
  depends_on = [
    aws_vpc.xfusion_vpc
  ]

  tags = {
    Name = var.KKE_SUBNET_NAME
  }
}