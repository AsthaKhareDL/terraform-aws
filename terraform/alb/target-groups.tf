
# ============================================================
# Target Group - nginx1
# ============================================================

resource "aws_lb_target_group" "nginx1" {
  name        = "nginx1-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"

  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name = "nginx1-target-group"
  }
}

# ============================================================
# Target Group - nginx2
# ============================================================

resource "aws_lb_target_group" "nginx2" {
  name        = "nginx2-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"

  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name = "nginx2-target-group"
  }
}

