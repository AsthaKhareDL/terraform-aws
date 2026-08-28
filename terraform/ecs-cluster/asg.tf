# ============================================================
# ECS Auto Scaling Group
# ============================================================

resource "aws_autoscaling_group" "ecs" {
  name = "terraform-ecs-asg"

  min_size         = 1
  desired_capacity = 1
  max_size         = 1

  vpc_zone_identifier = [
    data.terraform_remote_state.vpc.outputs.public_subnet_id
  ]

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key   = "Name"
    value = "terraform-ecs-instance"

    propagate_at_launch = true
  }
}