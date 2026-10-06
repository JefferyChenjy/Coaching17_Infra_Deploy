## Provider
provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.34"
    }
  }

  ## backend
  backend "s3" {
    bucket = "sctp-tfstate-ce13"
    key    = "jeffery_s3/jeffery-coach17-terraform.tfstate"
    region = "us-east-1"
    # S3 lockfiles disabled: bucket policy denies s3:DeleteObject for students,
    # so Terraform can create the .tflock but never release it.
    use_lockfile = false
  }

  required_version = ">= 1.10.0"
}

locals {
  prefix = "jeffery-coach17"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_subnet" "ecs" {
  id = "subnet-07fe08d5909e677db" # Change to your subnet ID 00b4c98869b996d86
}

resource "aws_security_group" "ecs" {
  name   = "${local.prefix}-ecs-sg"
  vpc_id = data.aws_subnet.ecs.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
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
    jeffery-ecs-td = { #task definition and service name -> #Change
      cpu    = 512
      memory = 1024
      container_definitions = {
        jeffery-container = { #container name -> Change
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
      subnet_ids                   = [data.aws_subnet.ecs.id] #List of subnet IDs to use for your tasks
      security_group_ids           = [aws_security_group.ecs.id] #Create a SG resource and pass it here
    }
  }
}
