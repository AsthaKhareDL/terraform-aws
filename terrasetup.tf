terraform {
  backend "s3" {
    bucket = "terra-state-aws"
    key    = "terraform/state/terraform.tfstate"
    region = "us-east-1"
  }
}