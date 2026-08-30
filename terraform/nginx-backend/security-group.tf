# ============================================================
# Security Group for Nginx Backend ECS Tasks
# ============================================================

resource "aws_security_group" "backend" {
  name        = "terraform-nginx-backend-sg"
  description = "Security group for Nginx backend ECS tasks"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # ----------------------------------------------------------
  # Allow HTTP only from the Internal ALB
  # ----------------------------------------------------------

  ingress {
    description     = "HTTP from Internal ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [data.terraform_remote_state.alb.outputs.alb_security_group_id]
  }

  # ----------------------------------------------------------
  # Outbound
  # ----------------------------------------------------------

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-nginx-backend-sg"
  }
}