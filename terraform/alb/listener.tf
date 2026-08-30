
# ============================================================
# Internal ALB Listener
# ============================================================

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.internal.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "No matching nginx backend"
      status_code  = "404"
    }
  }
}

# ============================================================
# nginx1.test.local
# ============================================================

resource "aws_lb_listener_rule" "nginx1" {
  listener_arn = aws_lb_listener.http.arn

  priority = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx1.arn
  }

  condition {
    host_header {
      values = ["nginx1.test.local"]
    }
  }
}

# ============================================================
# nginx2.test.local
# ============================================================

resource "aws_lb_listener_rule" "nginx2" {
  listener_arn = aws_lb_listener.http.arn

  priority = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx2.arn
  }

  condition {
    host_header {
      values = ["nginx2.test.local"]
    }
  }
}

