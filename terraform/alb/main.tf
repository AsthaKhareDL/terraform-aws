terraform {
  backend "s3" {
    bucket = "terra-state-aws"
    key    = "alb/terraform.tfstate"
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
# Internal Application Load Balancer
# ============================================================

resource "aws_lb" "internal" {
  name               = "terraform-internal-alb"
  internal           = true
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = data.terraform_remote_state.vpc.outputs.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "terraform-internal-alb"
  }
}

