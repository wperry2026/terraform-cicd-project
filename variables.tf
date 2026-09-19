variable "KKE_VPC_NAME" {
  description = "Name tag for the VPC"
  type        = string
}

variable "KKE_SUBNET_NAME" {
  description = "Name tag for the Subnet"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the Subnet"
  type        = string
  default     = "10.0.1.0/24"
}