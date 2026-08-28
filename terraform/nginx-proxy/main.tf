terraform {
  backend "s3" {
    bucket = "terra-state-aws"
    key    = "nginx-proxy/terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# ============================================================
# Read VPC Terraform State
# ============================================================

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "terra-state-aws"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

# ============================================================
# Read ECS Cluster Terraform State
# ============================================================

data "terraform_remote_state" "ecs_cluster" {
  backend = "s3"

  config = {
    bucket = "terra-state-aws"
    key    = "ecs-cluster/terraform.tfstate"
    region = "us-east-1"
  }
}

# ============================================================
# Read Service Discovery Terraform State
# ============================================================

data "terraform_remote_state" "service_discovery" {
  backend = "s3"

  config = {
    bucket = "terra-state-aws"
    key    = "service-discovery/terraform.tfstate"
    region = "us-east-1"
  }
}

# ============================================================
# Existing ECR Repository
# ============================================================

data "aws_ecr_repository" "nginx_proxy" {
  name = "nginx-proxy"
}

# ============================================================
# Nginx Proxy Task Definition
# ============================================================

resource "aws_ecs_task_definition" "nginx_proxy" {
  family                   = "nginx-proxy"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]

  container_definitions = jsonencode([
    {
      name      = "nginx-proxy"
      image     = "${data.aws_ecr_repository.nginx_proxy.repository_url}:${var.image_tag}"
      essential = true
      memory    = 256

      portMappings = [
        {
          containerPort = 80
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
    }
  ])
}

# ============================================================
# Nginx Proxy ECS Service
# ============================================================

resource "aws_ecs_service" "nginx_proxy" {
  name            = "nginx-proxy-service"
  cluster         = data.terraform_remote_state.ecs_cluster.outputs.ecs_cluster_id
  task_definition = aws_ecs_task_definition.nginx_proxy.arn

  desired_count = 1
  launch_type   = "EC2"

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

 
}