terraform {
  backend "s3" {
    bucket = "terra-state-aws"
    key    = "service-discovery/terraform.tfstate"
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

# ------------------------------------------------------------
# Read VPC state
# ------------------------------------------------------------

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "terra-state-aws"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

# ------------------------------------------------------------
# Private DNS Namespace
# ------------------------------------------------------------

resource "aws_service_discovery_private_dns_namespace" "test" {
  name = "test.local"

  vpc = data.terraform_remote_state.vpc.outputs.vpc_id
}

# ------------------------------------------------------------
# Backend Service Discovery
# ------------------------------------------------------------

resource "aws_service_discovery_service" "nginx" {
  name = "nginxService"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.test.id

    dns_records {
      ttl  = 15
      type = "SRV"
    }
  }
}