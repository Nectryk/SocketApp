variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
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
  description = "Value of the instance profile for the PHP app"
  type        = string
  default     = "LabInstanceProfile"
}

variable "key" {
  description = "Value of the key pair for the SSH connection to the instance"
  type        = string
  default     = "vockey"
}
