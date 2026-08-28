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
# ECS Launch Template
# ============================================================

resource "aws_launch_template" "ecs" {
  name_prefix = "terraform-ecs-"

  image_id = data.aws_ami.ecs_optimized.id

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

  lifecycle {
    ignore_changes = [
      user_data
    ]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "terraform-ecs-instance"
    }
  }
}