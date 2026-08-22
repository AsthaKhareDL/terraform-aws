# ============================================================
# ECS Cluster
# ============================================================

resource "aws_ecs_cluster" "example" {
  name = "terraform-ecs-cluster"
}


# ============================================================
# IAM Role for ECS EC2 Instance
# ============================================================

resource "aws_iam_role" "ecs_instance_role" {
  name = "terraform-ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ecs_ssm" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ============================================================
# ECS EC2 IAM Policy
# ============================================================

resource "aws_iam_role_policy_attachment" "ecs_instance_role" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}


# ============================================================
# Instance Profile
# ============================================================

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}


# ============================================================
# Security Group for ECS EC2
# ============================================================

resource "aws_security_group" "ecs_instance" {
  name        = "terraform-ecs-instance-sg"
  description = "Security group for ECS EC2 instance"

  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description = "HTTP for Nginx"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-ecs-instance-sg"
  }
}
