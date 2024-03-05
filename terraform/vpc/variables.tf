variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "Value of the name tag for the VPC"
  type        = string
  default     = "main"
}

variable "cidr_block" {
  description = "Value of the CIDR for the VPC"
  type        = string
  default     = "10.16.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.16.1.0/24", "10.16.2.0/24"]
}



variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["10.16.3.0/24", "10.16.4.0/24"]
}