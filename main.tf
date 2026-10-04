provider "aws" {
  region = "us-east-1"
}
terraform {
  backend "s3" {
    bucket = "sctp-tfstate-ce13"
    key    = "jeffery_coaching/terraform.tfstate"
    region = "us-east-1"
  }
}

locals {
  prefix = "jeffery-coaching17"
 }

data "aws_ami" "amazon_linux2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"] 
  }

  filter {
    name   = "architecture"
    values = ["x86_64"] # Use "arm64" if using a Graviton instance type like t4g
  }
}


data "aws_vpc" "main" {
  id = "vpc-071dc429d54e64259"
}

data "aws_subnet" "public" {
  id = "subnet-07fe08d5909e677db"
}

data "aws_caller_identity" "current" {

}

data "aws_region" "current" {

}


resource "aws_security_group" "allow_ssh" {
  name        = "${local.prefix}-security-group" 
  description = "Allow SSH inbound"
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"  
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}



resource "aws_ecr_repository" "ecr" {
  name         = "${local.prefix}-ecr"
  force_delete = true
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 7.5.0"

  cluster_name = "${local.prefix}-ecs"
  cluster_capacity_providers = ["FARGATE"]

  services = {
    jeffery-coaching17-task = { #task definition and service name -> #Change
      cpu    = 512
      memory = 1024
      container_definitions = {
        jeffery-coaching17-container = { #container name -> Change
          essential = true
          image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.prefix}-ecr:latest"
          port_mappings = [
            {
              containerPort = 8080
              protocol      = "tcp"
            }
          ]
        }
      }
      assign_public_ip                   = true
      deployment_minimum_healthy_percent = 100
      subnet_ids                   = [data.aws_subnet.public.id] #List of subnet IDs to use for your tasks
      security_group_ids           = [] #Create a SG resource and pass it here
    }
  }
}

#jeffery-coaching17-ecs