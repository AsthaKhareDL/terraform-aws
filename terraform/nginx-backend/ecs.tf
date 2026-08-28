# ============================================================
# Nginx Backend ECS Task Definition
# ============================================================

resource "aws_ecs_task_definition" "nginx_backend" {
  family                   = "nginx-backend"
  network_mode             = "bridge"
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
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}


# ============================================================
# Nginx Backend ECS Service
# ============================================================

resource "aws_ecs_service" "nginx_backend" {
  name            = "nginx-backend-service"
  cluster         = data.terraform_remote_state.ecs_cluster.outputs.ecs_cluster_id
  task_definition = aws_ecs_task_definition.nginx_backend.arn

  desired_count = 1
  launch_type   = "EC2"

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  service_registries {
    registry_arn   = data.terraform_remote_state.service_discovery.outputs.backend_service_arn
    container_name = "nginx-backend"
    container_port = 80
  }
}