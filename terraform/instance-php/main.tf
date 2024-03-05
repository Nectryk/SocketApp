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

resource "aws_security_group" "sg_web_alb" {
  name   = "web-app-lb-sg"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_security_group" "sg_web_server" {
  name   = "web-app-sg"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_web_alb.id]
  }
  // connectivity to ubuntu mirrors is required to run `apt-get update` and `apt-get install apache2`
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_cache" {
  name   = "cache-sg"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  ingress {
    from_port       = 11211
    to_port         = 11211
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_web_server.id]
  }
  // connectivity to ubuntu mirrors is required to run `apt-get update` and `apt-get install apache2`
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "web_app_lb" {
  name               = "web-app-lb-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_web_alb.id]
  subnets            = [for subnet in data.terraform_remote_state.vpc.outputs.public_subnet_info : subnet.id]
}

resource "aws_lb_target_group" "web_app_alb_tg" {
  name     = "web-app-lb-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id
}

resource "aws_lb_listener" "web_app_front_end" {
  load_balancer_arn = aws_lb.web_app_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_app_alb_tg.arn
  }
}

resource "aws_launch_template" "web_app_launch_templ" {
  name_prefix   = "web_app_launch_templ"
  image_id      = lookup(var.aws_amis, var.aws_region) # To note: AMI is specific for each region
  instance_type = "t2.micro"
  user_data     = base64encode(<<-EOF
#!/bin/bash

sudo apt update
sudo apt install apache2 php-mysql php8.1 libapache2-mod-php composer mysql-client php8.1-xml php-memcached -y

echo "<?php return array ('AWS_ACCESS_KEY_ID' => '${local.credentials_json.access_key_id}', 'AWS_SECRET_ACCESS_KEY' => '${local.credentials_json.secret_access_key}', 'AWS_SESSION_TOKEN' => '${local.credentials_json.session_token}', 'CLUSTER_ENDPOINT' => '${aws_elasticache_cluster.web_cache.cluster_address}') ?>" > /var/www/html/config.php


cd /var/www/html/ 
sudo chown ubuntu ../html/
sudo rm index.html
sudo git clone https://github.com/Nectryk/SocketApp.git
sudo cp -r SocketApp/TCP_IP_PHP/* SocketApp/clientRegister.sql .
sudo -u ubuntu composer install
sudo mysql -u admin -psecret09 -h ${split(":", data.terraform_remote_state.rds.outputs.db_endpoint)[0]} < clientRegister.sql

sudo systemctl restart apache2
              EOF
              )
  key_name      = var.key
  iam_instance_profile {
    name = var.instance_profile
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups = [aws_security_group.sg_web_server.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "web-app-instance"
    }
  }
}

resource "aws_autoscaling_group" "web_app_asg" {
  desired_capacity          = 1
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"

  target_group_arns = [aws_lb_target_group.web_app_alb_tg.arn]

  vpc_zone_identifier = [ # Creating EC2 instances in private subnet
    for subnet in data.terraform_remote_state.vpc.outputs.private_subnet_info : subnet.id
  ]

  launch_template {
    id      = aws_launch_template.web_app_launch_templ.id
    version = "$Latest"
  }
}

resource "aws_elasticache_subnet_group" "cache_subnet" {
  name       = "cache-subnet"
  subnet_ids = [for subnet in data.terraform_remote_state.vpc.outputs.private_subnet_info : subnet.id]
}

resource "aws_elasticache_cluster" "web_cache" {
  cluster_id = "web-app-cache"
  engine = "memcached"
  node_type = "cache.t3.micro"
  num_cache_nodes = 1
  parameter_group_name = "default.memcached1.6" 
  port = 11211
  security_group_ids = [ aws_security_group.sg_cache.id ]
  subnet_group_name = aws_elasticache_subnet_group.cache_subnet.name
}