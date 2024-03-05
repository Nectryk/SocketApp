terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

locals {
  credentials_json = jsondecode(data.aws_ssm_parameter.aws_credentials.value)
}

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "${path.module}/../vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "rds" {
  backend = "local"

  config = {
    path = "${path.module}/../rds/terraform.tfstate"
  }
}

data "aws_ssm_parameter" "aws_credentials" {
  name = "/dev/AWS_CREDENTIALS"
  with_decryption = true
}

resource "aws_security_group" "sg_node_server" {
  name   = "node-server-sg"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  ingress {
    from_port   = var.port_ingress
    to_port     = var.port_ingress
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  // connectivity to ubuntu mirrors is required to run `apt-get update` and `apt-get install apache2`
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_node_client" {
  name   = "node-client-sg"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  // connectivity to ubuntu mirrors is required to run `apt-get update` and `apt-get install apache2`
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "node_server_instance" {
  ami                         = lookup(var.aws_amis, var.aws_region)
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.sg_node_server.id]
  subnet_id                   = data.terraform_remote_state.vpc.outputs.private_subnet_info[0].id
  iam_instance_profile        = var.instance_profile
  key_name                    = var.key
  associate_public_ip_address = false
  user_data                   = templatefile("server_user_data.tftpl", { access_key_id = local.credentials_json.access_key_id, 
  secret_access_key = local.credentials_json.secret_access_key, session_token = local.credentials_json.session_token})
  tags = {
    Name = "node-server-instance"
  }
}

resource "aws_instance" "node_client_instance" {
  count = var.client_number
  ami                         = lookup(var.aws_amis, var.aws_region)
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.sg_node_client.id]
  subnet_id                   = data.terraform_remote_state.vpc.outputs.private_subnet_info[count.index % length(data.terraform_remote_state.vpc.outputs.private_subnet_info)].id
  iam_instance_profile        = var.instance_profile
  key_name                    = var.key
  associate_public_ip_address = false
  user_data                   = templatefile("client_user_data.tftpl", { access_key_id = local.credentials_json.access_key_id, 
  secret_access_key = local.credentials_json.secret_access_key, session_token = local.credentials_json.session_token, 
  server_ip = aws_instance.node_server_instance.private_ip, port_ingress = var.port_ingress})
  tags = {
    Name = "node-client-instance"
  }
  depends_on = [ aws_instance.node_server_instance ]
}