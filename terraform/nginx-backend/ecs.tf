
# ============================================================
# Nginx Backend Task Definition
# ============================================================

resource "aws_ecs_task_definition" "nginx_backend" {
  family                   = "nginx-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]

  container_definitions = jsonencode([
    {
      name      = "nginx-backend"
      image     = "${aws_ecr_repository.nginx_backend.repository_url}:${var.image_tag}"
      essential = true
      memory    = 256

      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}

# ============================================================
# Nginx 1 ECS Service
# ============================================================

resource "aws_ecs_service" "nginx1" {
  name            = "nginx1-service"
  cluster         = data.terraform_remote_state.ecs_cluster.outputs.ecs_cluster_id
  task_definition = aws_ecs_task_definition.nginx_backend.arn

  desired_count = 1
  launch_type   = "EC2"

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  network_configuration {
    subnets = [
      data.terraform_remote_state.vpc.outputs.public_subnet_id,
      data.terraform_remote_state.vpc.outputs.public_subnet_2_id
    ]

    security_groups = [
      aws_security_group.backend.id
    ]

    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = data.terraform_remote_state.alb.outputs.nginx1_target_group_arn
    container_name   = "nginx-backend"
    container_port   = 80
  }
}

# ============================================================
# Nginx 2 ECS Service
# ============================================================

resource "aws_ecs_service" "nginx2" {
  name            = "nginx2-service"
  cluster         = data.terraform_remote_state.ecs_cluster.outputs.ecs_cluster_id
  task_definition = aws_ecs_task_definition.nginx_backend.arn

  desired_count = 1
  launch_type   = "EC2"

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  network_configuration {
    subnets = [
      data.terraform_remote_state.vpc.outputs.public_subnet_id,
      data.terraform_remote_state.vpc.outputs.public_subnet_2_id
    ]

    security_groups = [
      aws_security_group.backend.id
    ]

    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = data.terraform_remote_state.alb.outputs.nginx2_target_group_arn
    container_name   = "nginx-backend"
    container_port   = 80
  }
}
