# ============================================================
# Security Group for Internal ALB
# ============================================================

resource "aws_security_group" "alb" {
  name        = "terraform-internal-alb-sg"
  description = "Security group for internal application load balancer"

  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  # ==========================================================
  # HTTP
  # ==========================================================

  ingress {
    description = "HTTP from VPC"

    from_port = 80
    to_port   = 80

    protocol = "tcp"

    cidr_blocks = [
      data.terraform_remote_state.vpc.outputs.vpc_cidr
    ]
  }

  # ==========================================================
  # Outbound
  # ==========================================================

  egress {
    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-internal-alb-sg"
  }
}
