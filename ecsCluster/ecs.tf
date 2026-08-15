# ============================================================
# ECS Cluster
# ============================================================

resource "aws_ecs_cluster" "example" {
  name = "terraform-ecs-cluster"
}


# ============================================================
# ECS Optimized Amazon Linux AMI
# ============================================================

data "aws_ami" "ecs_optimized" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
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
  vpc_id      = aws_vpc.example.id

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


# ============================================================
# ECS Launch Template
# ============================================================

resource "aws_launch_template" "ecs" {
  name_prefix   = "terraform-ecs-"
  image_id      = data.aws_ami.ecs_optimized.id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  vpc_security_group_ids = [
    aws_security_group.ecs_instance.id
  ]

  user_data = base64encode(<<-EOF
    #!/bin/bash

    echo "ECS_CLUSTER=${aws_ecs_cluster.example.name}" >> /etc/ecs/ecs.config
  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "terraform-ecs-instance"
    }
  }
}


# ============================================================
# ECS Auto Scaling Group
# ============================================================

resource "aws_autoscaling_group" "ecs" {
  name = "terraform-ecs-asg"

  min_size         = 1
  desired_capacity = 1
  max_size         = 1

  vpc_zone_identifier = [
    aws_subnet.asg_subnet_new.id
  ]

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "terraform-ecs-instance"
    propagate_at_launch = true
  }
}