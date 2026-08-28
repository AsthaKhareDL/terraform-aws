terraform {
  backend "s3" {
    bucket = "terra-state-aws"
    key    = "nginx-backend/terraform.tfstate"
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
# Nginx Backend ECR Repository
# ============================================================
