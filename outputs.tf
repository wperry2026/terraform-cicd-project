output "kke_vpc_name" {
  description = "The name of the VPC"
  value       = aws_vpc.xfusion_vpc.tags["Name"]
}

output "kke_subnet_name" {
  description = "The name of the Subnet"
  value       = aws_subnet.xfusion_subnet.tags["Name"]
}