# ============================================================
# Security Group for ECS EC2 Instance
# ============================================================

resource "aws_security_group" "ecs_instance" {
  name        = "terraform-ecs-instance-sg"
  description = "Security group for ECS EC2 instance"

  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  # Backend Nginx
  ingress {
    description = "HTTP for Nginx Backend"

    from_port = 80
    to_port   = 80

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  # Nginx Proxy
  ingress {
    description = "HTTP for Nginx Proxy"

    from_port = 8080
    to_port   = 8080

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound traffic
  egress {
    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-ecs-instance-sg"
  }
}