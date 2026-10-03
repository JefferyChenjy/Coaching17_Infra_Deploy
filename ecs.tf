
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 7.5.0"

  cluster_name = "${local.prefix}-ecs"
  cluster_capacity_providers = ["FARGATE"]

  services = {
    YOUR-TASKDEFINITION-NAME = { #task definition and service name -> #Change
      cpu    = 512
      memory = 1024
      container_definitions = {
        YOUR-CONTAINER-NAME = { #container name -> Change
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