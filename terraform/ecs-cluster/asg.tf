resource "aws_autoscaling_group" "ecs" {
  name = "terraform-ecs-asg"

  min_size         = 2
  desired_capacity = 2
  max_size         = 2

  vpc_zone_identifier = data.terraform_remote_state.vpc.outputs.public_subnet_ids

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