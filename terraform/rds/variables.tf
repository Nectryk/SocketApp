variable "subnet_group_name" {
  description = "Value of the name tag for the Subnet group"
  type        = string
  default     = "DB subnet group"
}

variable "db_name" {
  description = "Name of the DB for RDS"
  type        = string
  default     = "clientRegister"
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "allow_cidr_block" {
  description = "CIDR block to allow access to the DB"
  type        = string
  default     = "10.16.0.0/16"
}
