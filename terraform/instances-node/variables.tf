variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "port_ingress" {
  description = "Value of the port ingress for the server SG"
  type        = string
  default     = "3000"
}

variable "aws_amis" {
  description = "AMI ID of Ubuntu 22.04 LTS"
  type        = map
  default     = {
    "us-east-1" = "ami-0c7217cdde317cfec"
    "us-west-2" = "ami-08f7912c15ca96832"
  }
}

variable "instance_profile" {
  description = "Value of the instance profile for the intances"
  type        = string
  default     = "LabInstanceProfile"
}

variable "key" {
  description = "Value of the key pair for the SSH connection to the instance"
  type        = string
  default     = "vockey"
}

variable "client_number" {
  description = "Value of the number of client instances"
  type = number
  default = 2
}